//
//  Course+CoreDataClass.swift
//  GradeTracker
//
//  Created by Katharine K
//
//

import Foundation
import CoreData

@objc(Course)
public class Course: NSManagedObject {
    convenience init(viewContext: NSManagedObjectContext, title: String, creditHrs: Double?, goalGrade: Double?) throws {
        self.init(context: viewContext)
        self.id = UUID()
        try setTitle(title)
        if goalGrade != nil { try setGoalGrade(goalGrade!) }
        
        //totalCoursePoints, totalPointsCompleted, and totalPointsAchieved are all 0 by default upon creation of a new Course instance
        //totalCoursePoints = sum of weights of all syllabus items (must be >= 100 to calculate target grade)
        //totalPointsCompleted = sum of weights of all syllabus items that have been graded
        //totalPointsAchieved = current grade in the course based on syllabus items graded
        try viewContext.save()
    }
    
    /* -------------- FETCH  -------------- */
    //use to access stored courses
    //got idea to keep fetch request in Model to minimize use in View from this repository:
    //https://github.com/gahntpo/Slipbox/blob/main/Shared/model/Folder%2Bhelper.swift
    static func fetchCourses(_ predicate: NSPredicate) -> NSFetchRequest<Course> {
        let request = NSFetchRequest<Course>(entityName: "Course") //all terms that exist
        request.sortDescriptors = [NSSortDescriptor(key: "courseTitle", ascending: true)] //courses displayed in alphabetic order
        request.predicate = predicate //assign the given predicate
        return request
    }
    
    /* -------------- COMPUTED VARIABLE(S)  -------------- */
    //returns the target grade (as percentage) for incomplete syllabus items in order to achieve the goal grade for the course
    //the target grade for all incomplete syllabus items for a course are the same, so it is calculated in Course
    var targetGrade: Double? {
        //the target grade will return nil if existing syllabus items do not total  >= 100% worth of final grade (not enough data)
        if totalCoursePoints >= 100 {
            let totalPointsLeftToComplete = totalCoursePoints - totalPointsCompleted
            let totalPointsLeftToAchieve = goalGrade - totalPointsAchieved
            
            return ((totalPointsLeftToAchieve/totalPointsLeftToComplete) * 100)
        }
        return nil
    }
    
    /* -------------- SETTERS  -------------- */
    //propagates an error to the calling function if the title is empty or contains only whitespace characters
    func setTitle(_ newTitle: String) throws {
        if !newTitle.isEmpty && !newTitle.trimmingCharacters(in: .whitespaces).isEmpty { self.courseTitle = newTitle}
        else if newTitle.isEmpty { throw InvalidPropertySetter.titleEmpty }
        else if newTitle.trimmingCharacters(in: .whitespaces).isEmpty { throw InvalidPropertySetter.titleWhitespaces }
    }
    
    //the user has manually set a goal grade for the course
    //propagates an error to the calling function if the syllabus item's weight is attempted to be set as negative
    func setGoalGrade(_ goal: Double) throws {
        if goal >= 0 {
            self.goalGrade = goal
        }
        else { throw InvalidPropertySetter.negativeValue }
    }
    
    /* -------------- ADD & REMOVE SYLLABUS ITEMS  -------------- */
    //add a syllabus item to this course. propagates any errors (from SyllabusItem initializer) to calling code.
    func addSyllabusItem(viewContext: NSManagedObjectContext, title: String, weight: Double, finalGrade: Double?, dueDate: Date) throws {
        //if no errors, add the new item to the course's syllabus items
        self.addToSyllabusItems(try SyllabusItem(viewContext: viewContext, course: self, title: title, weight: weight, grade: finalGrade, dueDate: dueDate))
    }
    
    //remove a syllabus item from the course's syllabus items
    func removeSyllabusItem(_ item: SyllabusItem) {
        self.removeFromSyllabusItems(item)
        
        //adjust figures accordingly to correctly calculate target grade for remaining items
        self.totalCoursePoints -= item.weight
        self.totalPointsAchieved -= item.percentageOfCourseGradeAchieved 
        if item.finalGrade >= 0 { //if the item had been graded, remove the weight from points completed
            self.totalPointsCompleted -= item.weight
        }
    }
    
}
