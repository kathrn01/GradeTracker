//
//  Term+CoreDataClass.swift
//  GradeTracker
//
//  Created by Katharine K
//
//

import Foundation
import CoreData

@objc(Term)
public class Term: NSManagedObject {
    convenience init(viewContext: NSManagedObjectContext, title: String, start: Date?, end: Date?, currGPA: Double?, goalGPA: Double?) throws {
        self.init(context: viewContext)
        self.id = UUID()
        try setTitle(title)
        self.startDate = start
        self.endDate = end
        self.currentGPA = currGPA ?? -1
        self.goalGPA = goalGPA ?? -1
    }
    
    /* -------------- SETTERS  -------------- */
    //propagates an error to the calling function if the title is empty or contains only whitespace characters
    func setTitle(_ newTitle: String) throws {
        if !newTitle.isEmpty && !newTitle.trimmingCharacters(in: .whitespaces).isEmpty { self.termTitle = newTitle}
        else if newTitle.isEmpty { throw InvalidPropertySetter.titleEmpty }
        else if newTitle.trimmingCharacters(in: .whitespaces).isEmpty { throw InvalidPropertySetter.titleWhitespaces }
    }
    
    func setMarkerColour(red: Double?, green: Double?, blue: Double?) {
        let markerColour = MarkerColour()
        markerColour.red = red ?? 0
        markerColour.green = green ?? 0
        markerColour.blue = blue ?? 0
        self.markerColor = markerColour
    }
    
    /* -------------- ADD & REMOVE COURSES -------------- */
    func addCourse(viewContext: NSManagedObjectContext, title: String, creditHrs: Double?, goalGrade: Double?) throws {
        //create course and add to list
        self.addToCourseList(try Course(viewContext: viewContext, title: title, creditHrs: creditHrs, goalGrade: goalGrade))
    }
    
    func removeCourse(_ course: Course) {
        self.removeFromCourseList(course)
    }
    
}
