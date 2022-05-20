//
//  TermView.swift
//  GradeTracker
//
//  Created by Katharine K
//
// This view shows a list of all courses in a given term, along with their goal grade target

import SwiftUI

struct TermView: View {
    @Environment(\.managedObjectContext) private var viewContext //the view will update if the viewContext makes changes
    var term: Term //this variable is passed from the calling view, and allows this view to display any courses associated with this term
    @FetchRequest var courses: FetchedResults<Course> //this fetch request will allow to display all courses saved to persistent storage (created by the user)
    
    //when user selects the "info" button on the left side of the term display, this becomes true and allows the edit window to pop up
    @State var showEditTermWindow = false
    //if user chooses to delete the term in the edit window, a confirmation popup appears
    @State var showDeleteTermConfirmation = false
    
    //user input for editing the existing term information
    @State var termTitle: String
    @State var chosenColour: Color
    
    //this state variable is changed to true if the user selects "add course"
    @State var displayAddCourse = false 

    //these state varables record user input for properties when creating a new course
    @State var newCourseName = ""
    @State var newCourseCredHrs = ""
    @State var newCourseGoalGrade = ""
    
    /* I am using a custom initializer here to have the fetched results 'courses' reflect only the courses with the associated term provided (instead of all Course objects in persistent storage)
     referenced this solution from: https://stackoverflow.com/questions/58783711/swiftui-use-relationship-predicate-with-struct-parameter-in-fetchrequest?noredirect=1&lq=1 */
    init(term: Term) {
        self.term = term
        self._courses = FetchRequest(entity: Course.entity(), sortDescriptors: [], predicate: NSPredicate(format: "term == %@", term) ,animation: .default)
        self._termTitle = State(initialValue: term.termTitle ?? "New Term Title")
        self._chosenColour = State(initialValue: Color(red: term.markerColor!.red, green: term.markerColor!.green, blue: term.markerColor!.blue))
    }
    
    var body: some View {
        VStack {
            Text("List of courses for \(term.termTitle ?? "Unnamed Term")")
            List {
                //this list will display all courses that have been added to the term
                ForEach(courses) { course in
                    //user can select the course to navigate to it's course page which will show syllabus items and target grades
                    NavigationLink(
                        destination: CourseView(course: course),
                        label: {
                            HStack {
                                Text(course.courseTitle ?? "Unnamed Course")
                                Spacer()
                                Text("goal: %\(String(format: "%.01f", course.goalGrade))")
                                    .foregroundColor(.gray)
                            }
                    })
                }
                .onDelete { indexSet in //delete a course by swiping left on it
                    indexSet.forEach({ term.removeCourse(courses[$0]) })
                    do { try viewContext.save() } catch { print("Could not delete course.") }
                }
            }
            //the button to add a new course to the term
            Button(action: { displayAddCourse = true
            }) { Label("Add Course", systemImage: "plus") }
        }
        .navigationBarItems(trailing: Button(action: { showEditTermWindow = true }, label: { Text("Edit Term") }))
        .sheet(isPresented: $showEditTermWindow, content: {
            NavigationView {
                List{
                    HStack {
                        Text("Term Title: ")
                        TextField(termTitle, text: $termTitle)
                    }
                    ColorPicker("Change Marker Colour", selection: $chosenColour)
                    Spacer()
                    
                    //DELETE TERM
                    Button(action: {
                        //prompt warning + confirmation
                        showDeleteTermConfirmation = true
                    }, label: {
                        Text("Delete Term").foregroundColor(.red)
                    })
                    .alert(isPresented: $showDeleteTermConfirmation, content: { //this alert will pop up if the user selects "Delete Term" from the edit window
                        Alert(title: Text("Delete Term"), message: Text("Are you sure you would like to delete term \(String(describing: term.termTitle)) and all it's data permanently?"), primaryButton: .cancel(Text("Cancel"), action: { showEditTermWindow = false }),
                              secondaryButton: .destructive(Text("Delete Term"), action: {
                                showEditTermWindow = false
                            viewContext.delete(term)
                            do { try viewContext.save() } catch { print("Couldn't save term deletion in persistent storage.") }
                        }))
                    })
                }
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .navigationTitle("Edit Term")
                .navigationBarItems(leading: Button("Cancel", action: {
                    showEditTermWindow = false
                }), trailing: Button("Save Changes", action: {
                    do {
                        try term.setTitle(termTitle)
                        term.setMarkerColour(viewContext: viewContext, red: Double((chosenColour.cgColor?.components![0])!), green: Double((chosenColour.cgColor?.components![1])!), blue: Double((chosenColour.cgColor?.components![2])!))
                        try viewContext.save()
                    } catch {
                        print("Couldn't change the term's title or colour.")
                    }
                    showEditTermWindow = false
                }))
            }
        })
        .sheet(isPresented: $displayAddCourse, content: { //this sheet will be presented if the user selects "Add Course"
            NavigationView {
                List {
                    Section(header: Text("Course Info")) {
                        //in this section the user can add properties to the new course
                        TextField("Course Title", text: $newCourseName)
                        TextField("Credit Hours", text: $newCourseCredHrs)
                            .keyboardType(.decimalPad)
                        TextField("Goal Grade", text: $newCourseGoalGrade)
                            .keyboardType(.decimalPad)
                    }
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                }.padding()
                .navigationBarItems(leading: Button("Cancel", action: {
                    displayAddCourse = false
                    newCourseName = ""
                    newCourseCredHrs = ""
                    newCourseGoalGrade = ""
                }), trailing: Button("Add Course", action: {
                    //add the course to the list of courses for the term
                    do {
                        try term.addCourse(viewContext: viewContext, title: newCourseName, creditHrs: Double(newCourseCredHrs), goalGrade: Double(newCourseGoalGrade))
                        try viewContext.save()
                    } catch {
                        print("Could not add course to term.")
                    }
                    displayAddCourse = false
                    newCourseName = ""
                    newCourseCredHrs = ""
                    newCourseGoalGrade = ""
                })
                .disabled(newCourseName.isEmpty)) //cannot add a new course without a name
            }
        })
    }
}
