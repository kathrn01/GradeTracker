//
//  TermView.swift
//  GradeTracker
//
//  Created by Katharine K
//
// This view is effectively the "home page" for a Term. It displays the courses in that term, allows the user to add a new course, or edit the term.

import SwiftUI

struct TermView: View {
    @Environment(\.managedObjectContext) private var viewContext //the view will update if the viewContext makes changes
    var term: Term //this variable is passed from the calling view
    @FetchRequest var courses: FetchedResults<Course> //this fetch request will allow to display all courses saved to persistent storage (created by the user)
    
    //when user selects the edit button in the top right corner, this is changed to true
    @State var showEditTermWindow = false
    
    //this state variable is changed to true if the user selects "add course"
    @State var displayAddCourse = false 
    
    /* I am using a custom initializer here to assign courses as the list of courses associated with this term 
     referenced this solution from: https://stackoverflow.com/questions/58783711/swiftui-use-relationship-predicate-with-struct-parameter-in-fetchrequest?noredirect=1&lq=1 */
    init(term: Term) {
        self.term = term
        self._courses = FetchRequest(entity: Course.entity(), sortDescriptors: [], predicate: NSPredicate(format: "term == %@", term))
    }
    
    var body: some View {
        //list of courses in this term
        VStack {
            List {
                //this list will display all courses that have been added to the term
                Section(header: Text("Courses in term \(term.termTitle ?? "Unnamed Term")")) {
                    ForEach(courses) { course in
                        //user can select the course to navigate to it's course page which will show syllabus items and target grades
                        NavigationLink(
                            destination: CourseView(course: course).environment(\.managedObjectContext, viewContext),
                            label: {
                                HStack {
                                    Text(course.courseTitle ?? "Unnamed Course")
                                    Spacer()
                                    Text("Goal Grade: %\(String(format: "%.01f", course.goalGrade))")
                                        .foregroundColor(.gray)
                                }
                        })
                    }
                } //section
            } //list
            .listStyle(InsetGroupedListStyle())
            //the button to add a new course to the term
            Button(action: {
                    displayAddCourse = true
            }) {
                    Label("Add Course", systemImage: "plus.circle")
                        .foregroundColor(.black)
                        .font(.headline)
            }
            .padding()
        } //vstack
        .navigationTitle(Text(term.termTitle ?? "Unnamed Term"))
        .navigationBarItems(trailing: Button(action: { showEditTermWindow = true }, label: { Text("Edit Term") }))
        .sheet(isPresented: $showEditTermWindow, content: { //the view that will pop up as a sheet if the user selects "Edit Term"
            NavigationView {
                EditTermView(term: term, showEditTermWindow: $showEditTermWindow)
                    .environment(\.managedObjectContext, viewContext)
            }
        })
        .sheet(isPresented: $displayAddCourse, content: { //this sheet will be presented if the user selects "Add Course"
            NavigationView {
                AddCourseView(displayAddCourse: $displayAddCourse, term: term)
                    .environment(\.managedObjectContext, viewContext)
            }
        })
    }
    
    //this will set the text colour based on if the marker colour chosen as the background is darker or lighter
    //CITATION: I got the formula for the background colour value here: https://stackoverflow.com/questions/5477702/how-to-see-if-a-rgb-color-is-too-light
    var textColour: Color {
        let backgroundColourValue = ((term.markerColor!.red * 255 * 299) + (term.markerColor!.green * 255 * 587) + (term.markerColor!.blue * 255 * 114))/1000
        if backgroundColourValue >= 128 { return .black } else { return .white }
    }
}
