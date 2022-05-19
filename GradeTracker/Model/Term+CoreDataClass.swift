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
        if start != nil { try setStartDate(start!) }
        if end != nil { try setEndDate(end!) }
        if currGPA != nil { try setCurrentGPA(currGPA!) }
        if goalGPA != nil { try setGoalGPA (goalGPA!) }
    }
    
    /* -------------- SETTERS  -------------- */
    //propagates an error to the calling function if the title is empty or contains only whitespace characters
    func setTitle(_ newTitle: String) throws {
        if !newTitle.isEmpty && !newTitle.trimmingCharacters(in: .whitespaces).isEmpty { self.termTitle = newTitle}
        else if newTitle.isEmpty { throw InvalidPropertySetter.titleEmpty }
        else if newTitle.trimmingCharacters(in: .whitespaces).isEmpty { throw InvalidPropertySetter.titleWhitespaces }
    }
    
    func setMarkerColour(viewContext: NSManagedObjectContext, red: Double?, green: Double?, blue: Double?) {
        let markerColour = MarkerColour(context: viewContext)
        markerColour.red = red ?? 0
        markerColour.green = green ?? 0
        markerColour.blue = blue ?? 0
        self.markerColor = markerColour
    }
    
    /* -------------- NOT YET FUNCTIONAL --------------
     These methods are not yet used in the app, and must be tested and improved in a future iteration where they will be used in app.
     */
    
    func setStartDate(_ start: Date) throws {
        if endDate != nil {
            //the start date must be before or on the end date
            if endDate! <= start { throw InvalidDateRange.endBeforeStart }
        }
        self.startDate = start
    }
    
    func setEndDate(_ end: Date) throws {
        if startDate == nil {
            //if no start date is assigned, assign it to today by default if user attempts to add an end date
            self.startDate = Date()
        }
        //the end date must be after or on the start date
        if startDate! >= end { throw InvalidDateRange.startAfterEnd }
        self.endDate = end
    }
    
    func setCurrentGPA(_ currGPA: Double) throws {
        if currGPA < 0.0 { throw InvalidPropertySetter.negativeValue }
        self.currentGPA = currGPA
    }
    
    //if a goal GPA is set, the user has chosen automatic course goal setting based on a goal gpa 
    func setGoalGPA(_ goalGPA: Double) throws {
        if goalGPA < 0.0 { throw InvalidPropertySetter.negativeValue }
        self.goalGPA = goalGPA
    }
    
    /* -------------- END OF NOT YET FUNCTIONAL  -------------- */
    
    /* -------------- ADD & REMOVE COURSES -------------- */
    func addCourse(viewContext: NSManagedObjectContext, title: String, creditHrs: Double?, goalGrade: Double?) throws {
        self.addToCourseList(try Course(viewContext: viewContext, title: title, creditHrs: creditHrs, goalGrade: goalGrade))
    }
    
    func removeCourse(_ course: Course) {
        self.removeFromCourseList(course)
    }
    
    //TODO
    /* -------------- GOAL GPA LOGIC  --------------
    When the user sets a goal GPA, the goal grade for each course in the term (and it's syllabus items) is adjusted automaticaly*/
}
