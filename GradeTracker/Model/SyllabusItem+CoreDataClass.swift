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
        if finalGrade != nil { try setFinalGrade(finalGrade!) }
    }
    
    /* -------------- COMPUTED VARIABLE(S)  -------------- */
    //worth returns the percentage of the course that the syllabus item is worth
    //worth differs from weight, where weight is a static percentage, but if bonus syllabus items are given, ie. total possible grade is 110% -- the worth for each item shifts down slightly to accommodate and to take the extra available credit into consideration when calculating the target grade.
    var worth: Double {
        return (self.weight/course!.totalCoursePoints) * 100
    }
    
    //if a final grade has been assigned to this syllabus item,
    //percentageOfCourseGradeAchieved returns the percentage of the final grade in the course achieved by the final grade on this syllabus item based on it's worth
    var percentageOfCourseGradeAchieved: Double {
        if finalGrade != -1 { return worth * (finalGrade/100) }
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
//            let newWorth = newWeight/self.course!.totalCoursePoints
//            //if the syllabus item had already been given a final grade, update the course according to the new weight
//            if self.finalGrade != -1 {
//                //update totalCoursePoints (total possible points to be achieved in the course -- adding up to 100% or more) to reflect the new weight
//                course?.totalCoursePoints += (newWeight - self.weight) //add the difference
//
//                //update the totalPointsCompleted (the fraction of the course's syllabus items that have been given a final grade)
//                course?.totalPointsCompleted += (newWeight - self.weight)
//
//                //update the totalPointsAchieved (total points achieved based on final grade assigned to syllabus items)
//                let currentPoints = (newWorth * (self.finalGrade/100)) //the number of points by the previous weight
//                let newPoints = (newWorth * (self.finalGrade/100)) //the number of points by the new weight
//                course?.totalPointsAchieved += (newPoints - currentPoints) //add the difference
//            } else {
//                course?.totalCoursePoints += newWeight
//            }
            self.weight = newWeight
        }
        else { throw InvalidPropertySetter.negativeValue }
    }
    
    //propagates an error to the calling function if the syllabus item's final grade is attempted to be set as negative
    func setFinalGrade(_ grade: Double) throws {
        if grade >= 0 {
//            //if a final grade had already been added and is now being modified, remove the points previously added
//            if self.finalGrade != -1 {
//                //adjust totalPointsAchieved to reflect the new final grade
//                let currentPoints = self.worth  * (self.finalGrade/100)
//                let newPoints = self.worth * (grade/100)
//                course?.totalPointsAchieved += (newPoints - currentPoints) //add the difference
//            } else { //if this is the first final grade added for the syllabus item, add it's points according to it's weight to the course total
//                self.course?.totalPointsAchieved += (grade/100) * self.worth //this is how many points towards the course's final grade was achieved by this syllabus item's final grade
//                self.course?.totalPointsCompleted += self.weight //this fraction of the course has now been "completed"
//            }
            self.finalGrade = grade
        } else { throw InvalidPropertySetter.negativeValue }
    }
}
