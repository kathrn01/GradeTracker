//
//  CourseView.swift
//  GradeTracker
//
//  Created by Katharine K
//
// This view is a Course's "Home Page" -- shows all syllabus items, goal grade, allows user to edit course and add syllabus items.

import SwiftUI

struct CourseView: View {
    @Environment(\.managedObjectContext) private var viewContext //the view will update if the viewContext makes changes
    var course: Course //this variable is passed from the calling view
    @FetchRequest var syllabusItems: FetchedResults<SyllabusItem> //this fetch request will allow to display all syllabus items saved to persistent storage (created by the user)
    
    //this state variable will become true user selects "Add Syllabus Item"
    @State var displayAddSyllabusItem = false
    
    /* I am using a custom initializer here to have the fetched results 'syllabusItems' reflect only the syllabus items with the associated course provided (instead of all SyllabusItem objects in persistent storage)
     referenced this solution from: https://stackoverflow.com/questions/58783711/swiftui-use-relationship-predicate-with-struct-parameter-in-fetchrequest?noredirect=1&lq=1 */
    init(course: Course) {
        self.course = course
        self._syllabusItems = FetchRequest(entity: SyllabusItem.entity(), sortDescriptors: [NSSortDescriptor(key: "dueDate", ascending: true)], predicate: NSPredicate(format: "course == %@", course) ,animation: .default)
    }
    
    var body: some View {
        VStack{
            //display the course "dashboard" at the top: has stats, progress bar, edit button
            CourseDashboardView(course: course)
                .aspectRatio(5/1, contentMode: .fit)
            
            //cannot calculate target grade for syllabus items if the weights of existing syllabus items do not add up to 100 or more
            if !(course.syllabusItems?.allObjects.isEmpty ?? true) {
                if course.targetGrade == nil {
                    Text("Not enough data to calculate target grades. The weight of all syllabus items must total 100% or more.")
                        .font(.footnote)
                        .padding(.horizontal)
                }
            } else {
                Text("No syllabus items added yet.")
            }
            
            //display syllabus items for this course
            ScrollView {
                ForEach(syllabusItems) { syllItem in
                    SyllabusItemView(syllItem: syllItem)
                }
                .aspectRatio(4/1, contentMode: .fit)
            }
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
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(course.courseTitle ?? "Unnamed Course")
        .sheet(isPresented: $displayAddSyllabusItem, content: { //this sheet will be presented if the user selects "Add Course"
            NavigationView {
                AddSyllabusItemView(displayAddSyllabusItem: $displayAddSyllabusItem, course: course)
                    .environment(\.managedObjectContext, viewContext)
            }
        })
    }
}

