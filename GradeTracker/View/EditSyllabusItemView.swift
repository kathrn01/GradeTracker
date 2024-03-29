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
    //passed in from SyllabusItemView: this is the syllabus item we're editing
    var syllabusItem: SyllabusItem
    
    //determines whether this view is shown -- passed in from calling view as true, when user is done editing, becomes false
    @Binding var displayEditSyllabusItem: Bool
    
    //if user chooses to delete the item in the edit window, a confirmation popup appears
    @State var showDeleteSIConfirmation = false
    
    //user input for editing the existing syllabus item information
    @State private var fields: SyllabusItem.SIData
    
    /* I am using a custom initializer here to assign the user inputs to the syllabus item's existing attributes */
    init(syllabusItem: SyllabusItem, displayEditSyllabusItem: Binding<Bool>) {
        self.syllabusItem = syllabusItem
        self._displayEditSyllabusItem = displayEditSyllabusItem
        self._fields = State(initialValue: syllabusItem.syllabusItemData)
    }
    var body: some View {
        VStack {
            List{
                Section(header: Text("Item Info:")) {
                    HStack { //display current title for user to modify
                        Text("Title: ")
                        TextField(fields.title, text: $fields.title)
                    }
                    HStack{ //display current goal grade for user to modify
                        Text("Weight: ")
                        TextField(fields.weight, text: $fields.weight)
                            .keyboardType(.decimalPad)
                    }
                    //allows user to modify the due date from the current one (if any assigned)
                    DatePicker("Due Date:", selection: $fields.dueDate, in: closedRangeDueDate)
                }
                
                Section(header: Text("Final Grade")) {
                    HStack{ //display current goal grade for user to modify
                        Text("Grade: ")
                        TextField(fields.grade, text: $fields.grade)
                            .keyboardType(.decimalPad)
                    }
                    if syllabusItem.finalGrade > 0 {
                        Button(action: { fields.grade = "None Assigned" }, label: {
                            Text("Remove Grade")
                                .foregroundColor(.red)
                        })
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .textFieldStyle(PlainTextFieldStyle())
        
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
        }), trailing: Button("Save", action: {
            do {
                try syllabusItem.update(from: fields)
            } catch {
                print("Couldn't change the syllabus item's attributes.")
            }
            do { try viewContext.save() } catch { print("Could not save changes.")}
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

