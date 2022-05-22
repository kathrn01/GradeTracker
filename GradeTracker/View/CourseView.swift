//
//  CourseView.swift
//  GradeTracker
//
//  Created by Katharine K
//
// This view displays all syllabus items associated with a Course

import SwiftUI

struct CourseView: View {
    @Environment(\.managedObjectContext) private var viewContext //the view will update if the viewContext makes changes
    @ObservedObject var course: Course //this variable is passed from the calling view
    @FetchRequest var syllabusItems: FetchedResults<SyllabusItem> //this fetch request will allow to display all syllabus items saved to persistent storage (created by the user)
    
    /* I am using a custom initializer here to have the fetched results 'syllabusItems' reflect only the syllabus items with the associated course provided (instead of all SyllabusItem objects in persistent storage)
     referenced this solution from: https://stackoverflow.com/questions/58783711/swiftui-use-relationship-predicate-with-struct-parameter-in-fetchrequest?noredirect=1&lq=1 */
    init(course: Course) {
        self.course = course
        self._syllabusItems = FetchRequest(entity: SyllabusItem.entity(), sortDescriptors: [NSSortDescriptor(key: "dueDate", ascending: true)], predicate: NSPredicate(format: "course == %@", course) ,animation: .default)
    }
    
    //this state variable will become true user selects "Add Syllabus Item"
    @State var displayAddSyllabusItem = false
    
    //when user selects the edit button in the top right corner, this is changed to true
    @State var displayEditCourse = false
    
    var body: some View {
        VStack{
            Text("Goal grade: \(String(format: "%.01f", course.goalGrade))")
            List {
                Section(header: Text("Syllabus items in \(course.courseTitle ?? "Unnamed Course")")) {
                    ForEach(syllabusItems) { syllItem in
                        SyllabusItemView(syllItem: syllItem)
                    }
    
                    //cannot calculate target grade for syllabus items if the weights of existing syllabus items do not add up to 100 or more
                    if !(course.syllabusItems?.allObjects.isEmpty ?? true) {
                        if course.targetGrade == nil {
                            Text("Not enough data to calculate target grades. The weight of all syllabus items must total 100% or more.")
                                .font(.footnote)
                        }
                    }
                } //section
            } //list
            .listStyle(InsetGroupedListStyle())
            //add a new syllabus item to the course
            Button(action: {
                    displayAddSyllabusItem = true
            }) {
                    Label("Add Syllabus Item", systemImage: "plus.circle")
                        .foregroundColor(.black)
                        .font(.headline)
            }
            .padding()
        }
        .navigationBarTitle(Text(course.courseTitle ?? "Unnamed Course"))
        .navigationBarItems(trailing: Button("Edit Course", action: { displayEditCourse = true }))
        .sheet(isPresented: $displayAddSyllabusItem, content: { //this sheet will be presented if the user selects "Add Course"
            NavigationView {
                AddSyllabusItemView(displayAddSyllabusItem: $displayAddSyllabusItem, course: course)
                    .environment(\.managedObjectContext, viewContext)
            }
        })
        .sheet(isPresented: $displayEditCourse, content: { //this sheet will be presented if the user selects "Edit Course" in the top right corner
            NavigationView {
                EditCourseView(course: course, displayEditCourse: $displayEditCourse)
                    .environment(\.managedObjectContext, viewContext)
            }
        })
    }
}

