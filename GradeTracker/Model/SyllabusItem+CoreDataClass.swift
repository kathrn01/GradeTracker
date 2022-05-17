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
    convenience init(viewContext: NSManagedObjectContext, title: String, weight: Double, finalGrade: Double?, course: Course) throws {
        self.init(context: viewContext)
        self.id = UUID()
        try self.setTitle(title)
        self.course = course
        try self.setWeight(weight)
        course.pointsRemainingInCourse += self.worthWeight
        self.setFinalGrade(finalGrade ?? -1)
    }
    
    /* -------------- SETTERS  -------------- */
    //propagates an error to the calling function if the title is empty or contains only whitespace characters
    func setTitle(_ newTitle: String) throws {
        if !newTitle.isEmpty && !newTitle.trimmingCharacters(in: .whitespaces).isEmpty { self.itemTitle = newTitle}
        else if newTitle.isEmpty { throw InvalidPropertySetter.titleEmpty }
        else if newTitle.trimmingCharacters(in: .whitespaces).isEmpty { throw InvalidPropertySetter.titleWhitespaces }
    }

    //propagates an error to the calling function if the syllabus item's weight is attempted to be set as negative
    func setWeight(_ weight: Double) throws {
        if weight >= 0 {
            //if the syllabus item had already been given a final grade, update the course according to the new weight
            if self.finalGrade > -1 {
                //update the number of points achieved by the final grade in the course
                //remove the points from old weight
                self.course?.pointsAchieved -= (self.finalGrade/100) * worthWeight
                //add points from new weight
                self.course?.pointsAchieved += (self.finalGrade/100) * weight
                
                //update the number of points remaining in the course based on the new weight
                self.course?.pointsRemainingInCourse += self.worthWeight
                self.course?.pointsRemainingInCourse -= weight
            }
            self.worthWeight = weight
        }
        else { throw InvalidPropertySetter.negativeValue }
    }
    
    //propagates an error to the calling function if the syllabus item's final grade is attempted to be set as negative
    func setFinalGrade(_ grade: Double) {
        if grade >= 0 {
            //if a final grade had already been added and is now being modified, remove the points previously added
            if self.finalGrade > -1 { self.course?.pointsAchieved -= (self.finalGrade/100) * worthWeight }
    
            //subtract the weight of the item given a final grade from the points remaining in the course IF a final grade has NOT yet been given (don't want to subtract it twice if modifying final grade)
            if self.finalGrade == -1 { self.course?.pointsRemainingInCourse -= self.worthWeight }
            
            //add the number of points achieved by the final grade to the course
            self.course?.pointsAchieved += (grade/100) * worthWeight
            
            self.finalGrade = grade
        }
    }
}
