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
        course.totalCoursePoints += self.worthWeight //add weight of new syllabus item to total course points
        if finalGrade != nil { try setFinalGrade(finalGrade!) }
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
            if self.finalGrade != nil {
                //update totalCoursePoints to reflect the new weight
                course?.totalCoursePoints += (weight - self.worthWeight) //add the difference
                
                //update the totalPointsAchieved
                let currentPoints = (self.worthWeight * self.finalGrade) //the number of points by the previous weight
                let newPoints = (weight * self.finalGrade) //the number of points by the new weight
                course?.totalPointsAchieved += (newPoints - currentPoints) //add the difference
            }
            self.worthWeight = weight
        }
        else { throw InvalidPropertySetter.negativeValue }
    }
    
    //propagates an error to the calling function if the syllabus item's final grade is attempted to be set as negative
    func setFinalGrade(_ grade: Double) throws {
        if grade >= 0 {
            //if a final grade had already been added and is now being modified, remove the points previously added
            if self.finalGrade != nil {
                //adjust totalPointsAchieved to reflect the new final grade
                let currentPoints = (self.worthWeight * self.finalGrade)
                let newPoints = (self.worthWeight * grade)
                course?.totalPointsAchieved += (newPoints - currentPoints) //add the difference
            }
            self.finalGrade = grade
        } else { throw InvalidPropertySetter.negativeValue }
    }
}
