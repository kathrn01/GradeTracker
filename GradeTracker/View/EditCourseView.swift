//
//  EditCourseView.swift
//  GradeTracker
//
//  Created by Katharine K
//
// This view is shown if the user selects "Edit Course" in CourseView. Allows user to edit attributes for the course.

import SwiftUI

struct EditCourseView: View {
    @Environment(\.managedObjectContext) private var viewContext //the view will update if the viewContext makes changes
    var course: Course //passed from calling view
    
    //for user input to modify existing course info
    @State private var fields: Course.CourseData
    
    //determines whether this view is shown -- passed in from calling view as true, when user is done editing, becomes false
    @Binding var displayEditCourse: Bool
    
    //if user chooses to delete the course in the edit window, a confirmation popup appears
    @State var showDeleteCourseConfirmation = false
    
    /* I am using a custom initializer here to assign the user inputs to the course's existing attributes */
    init(course: Course, displayEditCourse: Binding<Bool>) {
        self.course = course
        self._displayEditCourse = displayEditCourse
        self._fields = State(initialValue: course.courseData)
    }
    var body: some View {
        VStack {
            List{ //display edit-able attributes
                HStack { //display current title for user to modify
                    Text("Course Title: ")
                    TextField(fields.title, text: $fields.title)
                }
                HStack{ //display current goal grade for user to modify
                    Text("Goal Grade: ")
                    TextField(fields.goalGrade, text: $fields.goalGrade)
                        .keyboardType(.decimalPad)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .textFieldStyle(PlainTextFieldStyle())
        
            //DELETE Course
            Button(action: {
                //prompt warning + confirmation
                showDeleteCourseConfirmation = true
            }, label: {
                Text("Delete Course").foregroundColor(.red).bold()
            }).padding()
            .alert(isPresented: $showDeleteCourseConfirmation, content: { //this alert will pop up if the user selects "Delete Course" from the edit window
                Alert(title: Text("Delete Course"), message: Text("Are you sure you would like to delete course \(course.courseTitle ?? "Unnamed Course") and all it's data permanently?"), primaryButton: .cancel(Text("Cancel"), action: { showDeleteCourseConfirmation = false }),
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
        }), trailing: Button("Save", action: { //save changes to persistence
            do { try course.update(from: fields) } catch {
                print("Couldn't change the course's title or goal grade.")
            }
            do { try viewContext.save() } catch { print("couldn't save changes.")} 
            displayEditCourse = false
        }))
    }
}
