//
//  CoursePageView.swift
//  GradeTracker
//
//  Created by Katharine K
//

import SwiftUI

struct CoursePageView: View {
    @Environment(\.managedObjectContext) private var viewContext //the view will update if the viewContext makes changes
    @ObservedObject var course: Course //this variable is passed from the calling view, and allows this view to display any courses associated with this term
    @FetchRequest var syllabusItems: FetchedResults<SyllabusItem> //this fetch request will allow to display all syllabus items saved to persistent storage (created by the user)

    /* I am using a custom initializer here to have the fetched results 'syllabusItems' reflect only the syllabus items with the associated course provided (instead of all SyllabusItem objects in persistent storage)
     referenced this solution from: https://stackoverflow.com/questions/58783711/swiftui-use-relationship-predicate-with-struct-parameter-in-fetchrequest?noredirect=1&lq=1 */
    init(course: Course) {
        self.course = course
        self._syllabusItems = FetchRequest(entity: SyllabusItem.entity(), sortDescriptors: [], predicate: NSPredicate(format: "course == %@", course) ,animation: .default)
    }
    
    //this state variable will become true when the edit screen shows
    @State var editSyllabusItem = false
    @State var addSyllabusItem = false
    
    @State var itemTitle = ""
    @State var itemWeight = ""
    @State var itemFinalGrade = ""
    
    var body: some View {
        VStack {
            Text("Goal grade: \(String(format: "%.02f", course.goalGrade))")
            List {
                ForEach(syllabusItems) { syllItem in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(syllItem.itemTitle ?? "Unnamed Syllabus Item")
                                .font(.title3)
                            Spacer()
                            Text("Worth: %\(String(format: "%.01f", syllItem.worthWeight)) of final grade.")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        }
                        if syllItem.finalGrade == nil {
                            if course.targetGrade != nil {
                                Text("Target: %\(String(format: "%.01f", course.targetGrade!))")
                                    .font(.callout)
                            } else {
                                Text("Target: Not enough data.")
                                    .font(.callout)
                            }
                        } else {
                            Text("Final grade achieved: %\(String(format: "%.01f", syllItem.finalGrade))")
                                .font(.callout)
                        }
                    }
                }
                .onDelete { indexSet in //delete an item by swiping left on it
                    indexSet.forEach({ course.removeSyllabusItem(syllabusItems[$0]) })
                    //error without .perform, found error fix on this thread: https://developer.apple.com/forums/thread/668299
                    viewContext.perform {
                        do { try viewContext.save() } catch { print("Could not delete syllabus item.") }
                    }
                }
            
                //cannot calculate target grade for syllabus items if the weights of existing syllabus items do not add up to 100 or more
                if !(course.syllabusItems?.allObjects.isEmpty ?? true) {
                    if course.targetGrade == nil {
                        Text("Not enough data to calculate target grades. The weight of all syllabus items must total %100 or more.")
                            .font(.footnote)
                    }
                }
            }
            //add a new syllabus item to the course
            Button("+Add Syllabus Item", action: { addSyllabusItem = true })
        }
        .navigationBarTitle(Text(course.courseTitle ?? "Unnamed Course"))
        .sheet(isPresented: $addSyllabusItem, content: { //this sheet will be presented if the user selects "Add Course"
            NavigationView {
                List {
                    Section(header: Text("Syllabus Item Info")) {
                        //in this section the user can add properties to the new course
                        TextField("Syllabus Item Title", text: $itemTitle)
                        TextField("Syllabus Item Weight", text: $itemWeight)
                            .keyboardType(.decimalPad)
                        TextField("Final Grade (Optional)", text: $itemFinalGrade)
                            .keyboardType(.decimalPad)
                    }
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                }.padding()
                .navigationBarItems(leading: Button("Cancel", action: {
                    addSyllabusItem = false
                    itemTitle = ""
                    itemWeight = ""
                    itemFinalGrade = ""
                }), trailing: Button("Add Course", action: {
                    //add the course to the list of courses for the term
                    do {
                        try course.addSyllabusItem(viewContext: viewContext, title: itemTitle, weight: Double(itemWeight) ?? 0.0, finalGrade: Double(itemFinalGrade))
                        try viewContext.save()
                    } catch {
                        print("Could not add course to term.")
                    }
                    addSyllabusItem = false
                    itemTitle = ""
                    itemWeight = ""
                    itemFinalGrade = ""
                })
                .disabled(itemTitle.isEmpty)) //cannot add a new course without a name
            }
        })
    }
}

