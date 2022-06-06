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
    convenience init(viewContext: NSManagedObjectContext, course: Course, title: String, weight: Double, finalGrade: Double?, dueDate: Date) throws {
        self.init(context: viewContext)
        self.id = UUID()
        self.course = course
        try self.setTitle(title)
        try self.setWeight(weight)
        self.dueDate = dueDate 
        if finalGrade != nil { try setFinalGrade(finalGrade!) }
        try viewContext.save()
    }
    
    /* -------------- COMPUTED VARIABLE(S)  -------------- */
    //if a final grade has been assigned to this syllabus item, percentageOfCourseGradeAchieved returns the percentage of the final grade in the course achieved by the final grade on this syllabus item based on it's worth
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
        if newWeight >= 0 {
            let prevAchieved = percentageOfCourseGradeAchieved
            let weightDiff = newWeight - self.weight
            
            self.weight = newWeight //set weight to new weight
            
            course?.totalCoursePoints += weightDiff //add difference
            //if there is a grade assigned, update the percentage of the course completed and percentage achieved
            if finalGrade > -1 {
                course?.totalPointsAchieved += (percentageOfCourseGradeAchieved - prevAchieved)
                course?.totalPointsCompleted += weightDiff //add the difference
            }
        }
        else { throw InvalidPropertySetter.negativeValue }
    }
    
    func setDueDate(_ date: Date) {
            self.dueDate = date
    }
    
    //propagates an error to the calling function if the syllabus item's final grade is attempted to be set as negative
    func setFinalGrade(_ grade: Double) throws {
        if grade >= 0 {
            let prevGrade = self.finalGrade //the current grade
            let prevAchieved = percentageOfCourseGradeAchieved //percentage achieved in course with current grade
            if prevGrade == -1 { course?.totalPointsCompleted += weight } //if a grade is being assigned for the first time, add it's weight to the points completed in the course
            self.finalGrade = grade //set the new final grade
            let addToAchieved = (finalGrade > -1) ? (percentageOfCourseGradeAchieved - prevAchieved) : percentageOfCourseGradeAchieved //add the difference if a grade was already assigned
            course?.totalPointsAchieved += addToAchieved //add the percentage of the course achieved (or the difference from previous grade) to the course
        } else { throw InvalidPropertySetter.negativeValue }
    }
    
    //removes the final grade if one was previously added
    func removeFinalGrade() {
        course?.totalPointsAchieved -= percentageOfCourseGradeAchieved
        course?.totalPointsCompleted -= weight
        self.finalGrade = -1
    }
}
