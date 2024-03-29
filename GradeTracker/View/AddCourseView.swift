//
//  AddCourseView.swift
//  GradeTracker
//
//  Created by Katharine K
//
// This view appears if the user selects "Add Course" in TermView

import SwiftUI
import CoreData 

struct AddCourseView: View {
    @Environment(\.managedObjectContext) private var viewContext //the view will update if the viewContext makes changes
    
    //determines whether this view is shown -- passed in from calling view as true, when user is done editing, becomes false
    @Binding var displayAddCourse: Bool
    
    var term: Term //passed in from TermView -- the term we're adding a course to
    
    //these state varables record user input for properties when creating a new course
    @State var newCourseName = ""
    @State var newCourseGoalGrade = ""
    @State var location = ""
    
    var body: some View {
        List { //fill in attributes
            Section(header: Text("Course Info")) {
                //in this section the user can add properties to the new course
                TextField("Course Title", text: $newCourseName)
                TextField("Goal Grade", text: $newCourseGoalGrade)
                    .keyboardType(.decimalPad)
            }
            Section(header: Text("Optional Info")) {
                //Course Location, etc
                TextField("Location", text: $location)
            }
            .textFieldStyle(PlainTextFieldStyle())
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle(Text("New Course"))
        .navigationBarTitleDisplayMode(.automatic)
        .navigationBarItems(leading: Button("Cancel", action: {
            resetUserInput()
        }), trailing: Button("Add", action: { //save info and add course to term
            //add the course to the list of courses for the term
            do {
                try term.addCourse(viewContext: viewContext, title: newCourseName, creditHrs: nil, goalGrade: Double(newCourseGoalGrade))
            } catch {
                print("Could not add course to term.")
            }
            resetUserInput()
        })
        .disabled(newCourseName.isEmpty || newCourseGoalGrade.isEmpty)) //cannot add a new course without a name or goal grade
    }
    
    private func resetUserInput() {
        displayAddCourse = false
        newCourseName = ""
        newCourseGoalGrade = ""
        location = ""
    }
}
