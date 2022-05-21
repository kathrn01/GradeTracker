//
//  EditCourseView.swift
//  GradeTracker
//
//  Created by Katharine Kowalchuk on 2022-05-21.
//

import SwiftUI

struct EditCourseView: View {
    @Environment(\.managedObjectContext) private var viewContext //the view will update if the viewContext makes changes
    var course: Course
    @Binding var displayEditCourse: Bool
    //if user chooses to delete the course in the edit window, a confirmation popup appears
    @State var showDeleteCourseConfirmation = false
    
    //user input for editing the existing course information
    @State var courseTitle: String
    @State var goalGrade: String
    
    /* I am using a custom initializer here to assign the chosen colour set initially to the term's current chosen marker colour, and the term's title set to it's current title
     referenced this solution from: https://stackoverflow.com/questions/58783711/swiftui-use-relationship-predicate-with-struct-parameter-in-fetchrequest?noredirect=1&lq=1 */
    init(course: Course, displayEditCourse: Binding<Bool>) {
        self.course = course
        self._displayEditCourse = displayEditCourse
        self._courseTitle = State(initialValue: course.courseTitle ?? "New Course Title")
        self._goalGrade = State(initialValue: String(course.goalGrade))
    }
    var body: some View {
        VStack {
            List{
                HStack { //display current title for user to modify
                    Text("Course Title: ")
                    TextField(courseTitle, text: $courseTitle)
                }
                HStack{ //display current goal grade for user to modify
                    Text("Goal Grade (Percentage): ")
                    TextField(goalGrade, text: $goalGrade)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .textFieldStyle(RoundedBorderTextFieldStyle())
        
            //DELETE TERM
            Button(action: {
                //prompt warning + confirmation
                showDeleteCourseConfirmation = true
            }, label: {
                Text("Delete Course").foregroundColor(.red).bold()
            }).padding()
            .alert(isPresented: $showDeleteCourseConfirmation, content: { //this alert will pop up if the user selects "Delete Term" from the edit window
                Alert(title: Text("Delete Course"), message: Text("Are you sure you would like to delete course \(course.courseTitle!) and all it's data permanently?"), primaryButton: .cancel(Text("Cancel"), action: { showDeleteCourseConfirmation = false }),
                      secondaryButton: .destructive(Text("Delete Course"), action: {
                        displayEditCourse = false
                        viewContext.delete(course)
                        do { try viewContext.save() } catch { print("Couldn't save course deletion in persistent storage.") }
                }))
            })
        }
        .navigationTitle("Edit Course")
        .navigationBarItems(leading: Button("Cancel", action: {
            displayEditCourse = false
        }), trailing: Button("Save Changes", action: {
            do {
                try course.setTitle(courseTitle)
                try course.setGoalGrade(Double(goalGrade) ?? 0)
                try viewContext.save()
            } catch {
                print("Couldn't change the course's title or goal grade.")
            }
            displayEditCourse = false
        }))
    }
}
