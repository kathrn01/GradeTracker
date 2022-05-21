//
//  EditSyllabusItemView.swift
//  GradeTracker
//
//  Created by Katharine Kowalchuk on 2022-05-21.
//

import SwiftUI

struct EditSyllabusItemView: View {
    @Environment(\.managedObjectContext) private var viewContext //the view will update if the viewContext makes changes
    var syllabusItem: SyllabusItem
    @Binding var displayEditSyllabusItem: Bool
    //if user chooses to delete the item in the edit window, a confirmation popup appears
    @State var showDeleteSIConfirmation = false
    
    //user input for editing the existing course information
    @State var itemTitle: String
    @State var itemWeight: String
    @State var itemFinalGrade: String
    @State var itemDueDate: Date
    
    /* I am using a custom initializer here to assign the chosen colour set initially to the term's current chosen marker colour, and the term's title set to it's current title
     referenced this solution from: https://stackoverflow.com/questions/58783711/swiftui-use-relationship-predicate-with-struct-parameter-in-fetchrequest?noredirect=1&lq=1 */
    init(syllabusItem: SyllabusItem, displayEditSyllabusItem: Binding<Bool>) {
        self.syllabusItem = syllabusItem
        self._displayEditSyllabusItem = displayEditSyllabusItem
        self._itemTitle = State(initialValue: syllabusItem.itemTitle ?? "New Item Title")
        self._itemWeight = State(initialValue: String(syllabusItem.weight))
        self._itemFinalGrade = State(initialValue: String(syllabusItem.finalGrade))
        self._itemDueDate = State(initialValue: syllabusItem.dueDate!)
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
                HStack{ //display current goal grade for user to modify
                    Text("Item Grade (Percentage): ")
                    TextField(itemFinalGrade, text: $itemFinalGrade)
                }
                //allows user to modify the due date from the current one (if any assigned)
                DatePicker("Item Due Date:", selection: $itemDueDate, in: closedRangeDueDate)
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
            .alert(isPresented: $showDeleteSIConfirmation, content: { //this alert will pop up if the user selects "Delete Term" from the edit window
                Alert(title: Text("Delete Syllabus Item"), message: Text("Are you sure you would like to delete course \(syllabusItem.itemTitle!) and all it's data permanently?"), primaryButton: .cancel(Text("Cancel"), action: { showDeleteSIConfirmation = false }),
                      secondaryButton: .destructive(Text("Delete Item"), action: {
                        displayEditSyllabusItem = false
                        syllabusItem.course?.removeSyllabusItem(syllabusItem)
                        viewContext.delete(syllabusItem)
                        do { try viewContext.save() } catch { print("Couldn't save item deletion in persistent storage.") }
                }))
            })
        }
        .navigationTitle("Edit Syllabus Item")
        .navigationBarItems(leading: Button("Cancel", action: {
            displayEditSyllabusItem = false
        }), trailing: Button("Save Changes", action: {
            do {
                try syllabusItem.setTitle(itemTitle)
                try syllabusItem.setWeight(Double(itemWeight) ?? 0)
                try syllabusItem.setFinalGrade(Double(itemFinalGrade) ?? 0)
                try viewContext.save()
            } catch {
                print("Couldn't change the course's title or goal grade.")
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

