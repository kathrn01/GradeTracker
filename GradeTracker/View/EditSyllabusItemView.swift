//
//  EditSyllabusItemView.swift
//  GradeTracker
//
//  Created by Katharine K
//
// This view is displayed when the user taps on SyllabusItemView, which is the display for syllabus items in CourseView.
// The user can edit attributes for the syllabus item within this view.

import SwiftUI

struct EditSyllabusItemView: View {
    @Environment(\.managedObjectContext) private var viewContext //the view will update if the viewContext makes changes
    var syllabusItem: SyllabusItem
    
    //determines whether this view is shown -- passed in from calling view as true, when user is done editing, becomes false
    @Binding var displayEditSyllabusItem: Bool
    
    //if user chooses to delete the item in the edit window, a confirmation popup appears
    @State var showDeleteSIConfirmation = false
    
    //user input for editing the existing course information
    @State var itemTitle: String
    @State var itemWeight: String
    @State var itemFinalGrade: String
    @State var itemDueDate: Date
    
    /* I am using a custom initializer here to assign the user inputs to the syllabus item's existing attributes */
    init(syllabusItem: SyllabusItem, displayEditSyllabusItem: Binding<Bool>) {
        self.syllabusItem = syllabusItem
        self._displayEditSyllabusItem = displayEditSyllabusItem
        self._itemTitle = State(initialValue: syllabusItem.itemTitle ?? "New Item Title") //existing title
        self._itemWeight = State(initialValue: String(syllabusItem.weight)) //existing weight
        if syllabusItem.finalGrade >= 0 { //if the item already has been assigned a final grade
            self._itemFinalGrade = State(initialValue: String(syllabusItem.finalGrade)) //existing grade
        } else { self._itemFinalGrade = State(initialValue: "")} //blank if no existing grade
        self._itemDueDate = State(initialValue: syllabusItem.dueDate ?? syllabusItem.course!.term!.startDate!) //existing due date or start date of the term
    }
    var body: some View {
        VStack {
            List{
                HStack { //display current title for user to modify
                    Text("Item Title: ")
                    TextField(itemTitle, text: $itemTitle)
                }
                HStack{ //display current goal grade for user to modify
                    Text("Item Weight (Percentage): ")
                    TextField(itemWeight, text: $itemWeight)
                }
                //allows user to modify the due date from the current one (if any assigned)
                DatePicker("Due Date:", selection: $itemDueDate, in: closedRangeDueDate)
                HStack{ //display current goal grade for user to modify
                    Text("Item Grade (Percentage): ")
                    HStack {
                        TextField(itemFinalGrade, text: $itemFinalGrade)
                        Spacer()
                        Button(action: { itemFinalGrade = "" }, label: {
                            Text("Remove Grade")
                                .font(.footnote)
                                .foregroundColor(.red)
                        })
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .textFieldStyle(RoundedBorderTextFieldStyle())
        
            //DELETE TERM
            Button(action: {
                //prompt warning + confirmation
                showDeleteSIConfirmation = true
            }, label: {
                Text("Delete Item").foregroundColor(.red).bold()
            }).padding()
            .alert(isPresented: $showDeleteSIConfirmation, content: { //this alert will pop up if the user selects "Delete Syllabus Item" from the edit window
                Alert(title: Text("Delete Syllabus Item"), message: Text("Are you sure you would like to delete \(syllabusItem.itemTitle!) and all it's data permanently?"), primaryButton: .cancel(Text("Cancel"), action: { showDeleteSIConfirmation = false }),
                      secondaryButton: .destructive(Text("Delete Item"), action: {
                        displayEditSyllabusItem = false
                        syllabusItem.course?.removeSyllabusItem(syllabusItem)
                        do { try viewContext.save() } catch { print("Couldn't save item deletion in persistent storage.") }
                }))
            })
        }
        .navigationTitle("Edit \(syllabusItem.itemTitle ?? "Syllabus Item")")
        .navigationBarItems(leading: Button("Cancel", action: {
            displayEditSyllabusItem = false
        }), trailing: Button("Save Changes", action: {
            do {
                try syllabusItem.setTitle(itemTitle)
                try syllabusItem.setWeight(Double(itemWeight) ?? 0)
                if Double(itemFinalGrade) != nil { try syllabusItem.setFinalGrade(Double(itemFinalGrade)!)} else { syllabusItem.removeFinalGrade() }
                try syllabusItem.setDueDate(itemDueDate)
                try viewContext.save()
            } catch {
                print("Couldn't change the syllabus item's attributes.")
            }
            displayEditSyllabusItem = false
        }))
    }
    
    
    //CITATION: got idea for this var here: https://stackoverflow.com/questions/63040285/two-closedranges-for-datepicker-in-swiftui
    private var closedRangeDueDate: ClosedRange<Date> {
        let startOfTerm = syllabusItem.course?.term?.startDate ?? Date()
        let endOfTerm = syllabusItem.course?.term?.endDate ?? Date()
        return startOfTerm...endOfTerm
    }
}

