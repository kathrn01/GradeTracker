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
        if creditHrs != nil { try setCreditHours(creditHrs!) }
        if goalGrade != nil { try setGoalGrade(goalGrade!) }
    }
    
    /* -------------- COMPUTED VARIABLE(S)  --------------
     the target grade is re-computed whenever any syllabus item in the course's grade or weight is modified */
//    
//    //totalPointsAchieved is the percentage of the course's final grade that has been achieved (by syllabus items given a final grade)
//    private var totalPointsAchieved: Double {
//        var totalPointsAchieved = 0.0
//        (syllabusItems?.allObjects as? [SyllabusItem] ?? []).forEach({
//            if $0.finalGrade > -1 { //if the item has a final grade
//                totalPointsAchieved += $0.percentageOfCourseGradeAchieved
//            }
//        })
//        return totalPointsAchieved
//    }
//    
    //totalPointsCompleted is the percentage of the course's syllabus items that have been given a final grade
    //this is different from totalPointsAchieved, as it only takes into account the weight of the syllabus items given a final grade, not their final grade itself.
    var totalPointsCompleted: Double {
        var totalAchieved = 0.0
        var totalPointsCompleted = 0.0
        (syllabusItems?.allObjects as? [SyllabusItem] ?? []).forEach({
            if $0.finalGrade != -1 { //if the item has a final grade
                totalPointsCompleted += $0.weight
                totalAchieved += ($0.finalGrade/100) * $0.worth
            }
        })
        
        //update total points achieved 
        self.totalPointsAchieved += (totalAchieved - self.totalPointsAchieved) //add diff
        return totalPointsCompleted
    }
   
    //totalPointsToAchieve returns the difference between the points achieved in the course and the goal grade, to be used in calculating the target grade for incomplete syllabus items
    var totalPointsToAchieve: Double {
        return goalGrade - totalPointsAchieved
    }
    
    //totalPointsLeftToComplete is the difference between the total course points and the percentage that has been graded
    //in other words, the portion of the course left to complete/be graded
    var totalPointsLeftToComplete: Double {
        return totalCoursePoints - totalPointsCompleted
    }
    
    //returns the target grade (as percentage) for incomplete syllabus items in order to achieve the goal grade for the course
    var targetGrade: Double? {
        //the target grade will return nil if existing syllabus items do not total  >= 100% worth of final grade (not enough data)
        if totalCoursePoints >= 100 { return ((totalPointsToAchieve/totalPointsLeftToComplete) * 100) }
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
            self.goalGrade = goal }
        else { throw InvalidPropertySetter.negativeValue }
    }
    
    
    //this will be used in the future when goal GPA is/can be taken into account for the target grade of a course
    func setCreditHours(_ hours: Double) throws {
        if hours >= 0 { self.creditHours = hours }
        else { throw InvalidPropertySetter.negativeValue }
    }
    
    
    /* -------------- ADD & REMOVE SYLLABUS ITEMS  -------------- */
    //add a syllabus item to this course. propagates any errors (from SyllabusItem initializer) to calling code.
    func addSyllabusItem(viewContext: NSManagedObjectContext, title: String, weight: Double, finalGrade: Double?, dueDate: Date) throws {
        //if no errors, add the new item to the course's syllabus items
        addToSyllabusItems(try SyllabusItem(viewContext: viewContext, title: title, weight: weight, finalGrade: finalGrade, course: self, dueDate: dueDate))
    }
    
    //remove a syllabus item from the course's syllabus items
    func removeSyllabusItem(_ item: SyllabusItem) {
        do {
            try item.setWeight(0) //this will adjust the totalPointsAchieved and totalCoursePoints accordingly
            self.removeFromSyllabusItems(item)
        } catch {
            print("unable to remove syllabus item.")
        }
    }
    
    /* -------------- GOAL GRADE LOGIC --------------
     *Note: at the current phase of development, goalGPA is not being added to term, only manual goal grades for individual courses. The guidelines below are for future development goals.
     
     If a user manually sets a goal grade for a course, the target grades for the syllabus items in the course adjust accordingly.
     If the user instead set a goal GPA for the term, the goal grade will be calculated automatically to align with the GPA goal (user doesn't need to enter it)
     
     In the case where the user set a goal GPA for the term, and then manually changed a goal grade for an individual course in that term, the target grades for syllabus items will follow the new goal grade. (Goal grade for course set manually will override automatic goal set by goal GPA in the term)
     */
    
}
