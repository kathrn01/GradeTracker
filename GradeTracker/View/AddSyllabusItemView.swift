//
//  AddSyllabusItemView.swift
//  GradeTracker
//
//  Created by Katharine K
//

import SwiftUI

struct AddSyllabusItemView: View {
    @Environment(\.managedObjectContext) private var viewContext //the view will update if the viewContext makes changes
    @Binding var displayAddSyllabusItem: Bool //determines whether this view is displayed
    var course: Course //passed in from CourseView -- the course we're adding a SyllabusItem to 
    
    //these state varables record user input for properties when creating a new course
    @State var itemTitle = ""
    @State var itemWeight = ""
    @State var itemFinalGrade = ""
    @State var itemDueDate: Date
    
    init(displayAddSyllabusItem: Binding<Bool>, course: Course) {
        self.course = course
        self._displayAddSyllabusItem = displayAddSyllabusItem
        self._itemDueDate = State(initialValue: course.term!.startDate!)
    }
    
    var body: some View {
        List {
            Section(header: Text("Syllabus Item Info")) {
                //in this section the user can add properties to the new course
                TextField("Syllabus Item Title", text: $itemTitle)
                TextField("Syllabus Item Weight (Percentage)", text: $itemWeight)
                    .keyboardType(.decimalPad)
                //allows user to modify the due date from the current one (if any assigned)
                DatePicker("Item Due Date:", selection: $itemDueDate, in: closedRangeDueDate)
                TextField("Final Grade (Optional)", text: $itemFinalGrade)
                    .keyboardType(.decimalPad)
                Text("The final grade assigned to this syllabus item can be added later.")
                    .font(.footnote)
            }
            .textFieldStyle(RoundedBorderTextFieldStyle())
        }.padding()
        .listStyle(InsetGroupedListStyle())
        .navigationTitle(Text("Add Syllabus Item"))
        .navigationBarItems(leading: Button("Cancel", action: {
            resetUserInput()
        }), trailing: Button("Add Item", action: {
            //add the course to the list of courses for the term
            do {
                try course.addSyllabusItem(viewContext: viewContext, title: itemTitle, weight: Double(itemWeight) ?? 0.0, finalGrade: Double(itemFinalGrade), dueDate: itemDueDate)
                try viewContext.save()
            } catch {
                print("Could not add syllabus item to course.")
            }
            resetUserInput()
        })
        .disabled(itemTitle.isEmpty)) //cannot add a new course without a name
    }
    
    private func resetUserInput() {
        displayAddSyllabusItem = false
        itemTitle = ""
        itemWeight = ""
        itemFinalGrade = ""
    }
    
    //CITATION: got idea for this var here: https://stackoverflow.com/questions/63040285/two-closedranges-for-datepicker-in-swiftui
    private var closedRangeDueDate: ClosedRange<Date> {
        let startOfTerm = course.term?.startDate ?? Date()
        let endOfTerm = course.term?.endDate ?? Date()
        return startOfTerm...endOfTerm
    }
}
