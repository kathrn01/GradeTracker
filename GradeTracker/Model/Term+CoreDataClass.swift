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
    convenience init(viewContext: NSManagedObjectContext, title: String, start: Date?, end: Date?, currGPA: Double?, goalGPA: Double?, markerColour: [Double]) throws {
        self.init(context: viewContext)
        self.id = UUID()
        try setTitle(title)
        self.startDate = start
        self.endDate = end
        self.currentGPA = currGPA ?? -1
        self.goalGPA = goalGPA ?? -1
        if markerColour.count >= 3 {
            markerColor = MarkerColour(context: viewContext)//assign a marker colour to this term
            self.setMarkerColour(red: markerColour[0], green: markerColour[1], blue: markerColour[2]) //set rgb values based on selected or default colour
        }
        try viewContext.save()
    }
    
    /* -------------- SETTERS  -------------- */
    //propagates an error to the calling function if the title is empty or contains only whitespace characters
    func setTitle(_ newTitle: String) throws {
        if !newTitle.isEmpty && !newTitle.trimmingCharacters(in: .whitespaces).isEmpty { self.termTitle = newTitle } // title is set if contains non-whitespace characters
        else if newTitle.isEmpty { throw InvalidPropertySetter.titleEmpty } // error if empty
        else if newTitle.trimmingCharacters(in: .whitespaces).isEmpty { throw InvalidPropertySetter.titleWhitespaces } // error if only whitespace characters
    }
    
    //sets marker colour based on rgb values of selected or default colour
    func setMarkerColour(red: Double, green: Double, blue: Double) {
        self.markerColor?.red = red
        self.markerColor?.green = green
        self.markerColor?.blue = blue
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
