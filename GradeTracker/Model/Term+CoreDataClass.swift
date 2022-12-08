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
    
    //allow view to modify this and then save it to existing Term instance -- used in EditTermView
    //instructions from: https://developer.apple.com/tutorials/app-dev-training/creating-the-edit-view
    struct TermData {
        var title: String = ""
        var startDate: Date = Date()
        var endDate: Date = Date()
        var currentGPA: Double? = nil
        var goalGPA: Double? = nil
    }
    
    //computer property that returns a TermData instance with Term values -- used in EditTermView
    var termData: TermData {
        TermData(title: termTitle ?? "Untitled", startDate: startDate ?? Date(), endDate: endDate ?? Date(), currentGPA: currentGPA, goalGPA: goalGPA)
    }
    
    //updates term with data from view
    func update(from: TermData) throws {
        try setTitle(from.title)
        startDate = from.startDate
        endDate = from.endDate
        
        //TODO: ADD GPA MODIFICATIONS 
    }
    
    /* -------------- FETCH  -------------- */
    //use to access stored terms
    //got idea to keep fetch request in Model to minimize use in View from this repository:
    //https://github.com/gahntpo/Slipbox/blob/main/Shared/model/Folder%2Bhelper.swift
    static func fetchTerms() -> NSFetchRequest<Term> {
        let request = NSFetchRequest<Term>(entityName: "Term") //all terms that exist
        request.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: true)] //terms will always be displayed by start date priority
        return request
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
        self.markerColor!.red = red
        self.markerColor!.green = green
        self.markerColor!.blue = blue
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
