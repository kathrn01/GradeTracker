//
//  SyllabusItem+CoreDataClass.swift
//  GradeTracker
//
//  Created by Katharine K
//
//

import Foundation
import CoreData

@objc(SyllabusItem)
public class SyllabusItem: NSManagedObject {
    //initialize with data -- propagate error to the calling code to handle
    convenience init(viewContext: NSManagedObjectContext, course: Course, title: String, weight: Double, grade: Double?, dueDate: Date) throws {
        self.init(context: viewContext)
        self.id = UUID()
        self.course = course
        try self.setTitle(title)
        try self.setWeight(weight)
        self.dueDate = dueDate 
        if grade != nil { try setFinalGrade(grade!) }
        try viewContext.save()
    }
    
    /* -------------- FETCH  -------------- */
    //use to access stored syllabus items
    //got idea to keep fetch request in Model to minimize use in View from this repository:
    //https://github.com/gahntpo/Slipbox/blob/main/Shared/model/Folder%2Bhelper.swift
    static func fetchSyllItems(forCourse: Course) -> NSFetchRequest<SyllabusItem> {
        let request = NSFetchRequest<SyllabusItem>(entityName: "SyllabusItem") //all terms that exist
        request.sortDescriptors = [NSSortDescriptor(key: "dueDate", ascending: true)] //displayed by earliest due date
        request.predicate = NSPredicate(format: "course == %@", forCourse)
        return request
    }
    
    /* -------------- COMPUTED VARIABLE(S)  -------------- */
    //if item is graded, how many points towards final grade are achieved
    var percentageOfCourseGradeAchieved: Double {
        if finalGrade != -1 { return weight * (finalGrade/100) }
        return 0
    }
    
    /* -------------- SETTERS  -------------- */
    //propagates an error to the calling function if the title is empty or contains only whitespace characters
    func setTitle(_ newTitle: String) throws {
        if !newTitle.isEmpty && !newTitle.trimmingCharacters(in: .whitespaces).isEmpty { self.itemTitle = newTitle}
        else if newTitle.isEmpty { throw InvalidPropertySetter.titleEmpty }
        else if newTitle.trimmingCharacters(in: .whitespaces).isEmpty { throw InvalidPropertySetter.titleWhitespaces }
    }

    //propagates an error to the calling function if the syllabus item's weight is attempted to be set as negative
    func setWeight(_ newWeight: Double) throws {
        if newWeight != self.weight { //weight was updated
            if newWeight >= 0 { //valid
                let prevAchieved = percentageOfCourseGradeAchieved
                let weightDiff = newWeight - self.weight
                
                self.weight = newWeight //set weight to new weight
                
                course?.addTotalPoints(weightDiff) //add difference
                
                //if there is a grade assigned, update the percentage of the course completed and percentage achieved
                if finalGrade > -1 {
                    let gradeDiff = percentageOfCourseGradeAchieved - prevAchieved
                    course?.addAchievedPoints(gradeDiff)
                    course?.addCompletedPoints(weightDiff)
                }
            }
            else { throw InvalidPropertySetter.negativeValue }
//        print("New item. Total Course Points: \(course?.totalCoursePoints), totalCompleted: \(course?.totalPointsCompleted), totalAchieved: \(course?.totalPointsAchieved)")
        }
    }
    
    func setDueDate(_ date: Date) {
            self.dueDate = date
    }
    
    //propagates an error to the calling function if the syllabus item's final grade is attempted to be set as negative
    func setFinalGrade(_ grade: Double) throws {
        if grade != self.finalGrade { //the grade was updated
            if grade >= 0 { //valid
                let prevGrade = self.finalGrade //the current grade
                let prevAchieved = percentageOfCourseGradeAchieved //percentage achieved in course with current grade
                if prevGrade == -1 { course?.addTotalPoints(self.weight) } //if a grade is being assigned for the first time, add it's weight to the points completed in the course
                self.finalGrade = grade //set the new final grade
                
                let gradeDiff = percentageOfCourseGradeAchieved - prevAchieved
                let addToAchieved = (finalGrade > -1) ? (gradeDiff) : percentageOfCourseGradeAchieved //add the difference if a grade was already assigned
                course?.addAchievedPoints(addToAchieved) //add the percentage of the course achieved (or the difference from previous grade) to the course
            } else { throw InvalidPropertySetter.negativeValue }
        }
    }
    
    //removes the final grade if one was previously added
    func removeFinalGrade() {
        course?.removeCompletedPoints(self.weight)
        course?.removeAchievedPoints(percentageOfCourseGradeAchieved)
        self.finalGrade = -1
    }
}
