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
    convenience init(viewContext: NSManagedObjectContext, title: String, weight: Double, finalGrade: Double?, course: Course, dueDate: Date) throws {
        self.init(context: viewContext)
        self.id = UUID()
        try self.setTitle(title)
        self.course = course
        try self.setWeight(weight)
        try setDueDate(dueDate)
        if finalGrade != nil { try setFinalGrade(finalGrade!) }
    }
    
    /* -------------- COMPUTED VARIABLE(S)  -------------- */
    //worth returns the percentage of the course that the syllabus item is worth
    //worth differs from weight, where weight is a static percentage, but if bonus syllabus items are given, ie. total possible grade is 110% -- the worth for each item shifts down slightly to accommodate and to take the extra available credit into consideration when calculating the target grade.
    var worth: Double {
        return (self.weight/(course?.totalCoursePoints ?? 100)) * 100
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
            course?.totalCoursePoints += (newWeight - self.weight) //add difference
            self.weight = newWeight
        }
        else { throw InvalidPropertySetter.negativeValue }
    }
    
    func setDueDate(_ date: Date) throws {
        //the due date must be in between the term's start and end dates (inclusive)
        if date >= course!.term!.startDate! && date <= course!.term!.endDate! {
            self.dueDate = date
        } else { throw InvalidDateRange.endBeforeStart }
    }
    
    //propagates an error to the calling function if the syllabus item's final grade is attempted to be set as negative
    func setFinalGrade(_ grade: Double) throws {
        if grade >= 0 {
            self.finalGrade = grade
        } else { throw InvalidPropertySetter.negativeValue }
    }
}
