//
//  CourseListView.swift
//  GradeTracker
//
//  Created by Katharine K
//
// This view shows a list of all courses in a given term, along with their goal grade target

import SwiftUI

struct CourseListView: View {
    @Environment(\.managedObjectContext) private var viewContext //the view will update if the viewContext makes changes
    var term: Term //this variable is passed from the calling view, and allows this view to display any courses associated with this term
    @FetchRequest var courses: FetchedResults<Course> //this fetch request will allow to display all courses saved to persistent storage (created by the user)

    /* I am using a custom initializer here to have the fetched results 'courses' reflect only the courses with the associated term provided (instead of all Course objects in persistent storage)
     referenced this solution from: https://stackoverflow.com/questions/58783711/swiftui-use-relationship-predicate-with-struct-parameter-in-fetchrequest?noredirect=1&lq=1 */
    init(term: Term) {
        self.term = term
        self._courses = FetchRequest(entity: Course.entity(), sortDescriptors: [], predicate: NSPredicate(format: "term == %@", term) ,animation: .default)
    }
    
    //this state variable is changed to true if the user selects "add course"
    @State var displayAddCourse = false 

    //these state varables record user input for properties when creating a new course
    @State var newCourseName = ""
    @State var newCourseCredHrs = ""
    @State var newCourseGoalGrade = ""
    
    var body: some View {
        VStack {
            Text("List of courses for \(term.termTitle ?? "Unnamed Term")")
            List {
                //this list will display all courses that have been added to the term
                ForEach(courses) { course in
                    //user can select the course to navigate to it's course page which will show syllabus items and target grades
                    NavigationLink(
                        destination: CoursePageView(course: course),
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
