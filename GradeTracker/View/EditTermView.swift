//
//  EditTermView.swift
//  GradeTracker
//
//  Created by Katharine K
//
// This view will appear if the user wishes to edit the term in TermView.

import SwiftUI

struct EditTermView: View {
    @Environment(\.managedObjectContext) private var viewContext //the view will update if the viewContext makes changes
    //passed in from TermView: this is the term we are editing
    @State var term: Term
    //data for fields that will update Term info
    @State private var fields: Term.TermData
    //passed as true from calling view: determines if this edit window is shown
    @Binding var showWindow: Bool
    //if user chooses to delete the term in the edit window, a confirmation popup appears
    @State var showDeleteTermConfirmation = false
    
    /* I am using a custom initializer here to assign user input initially to the term's existing attribute values  */
    init(term: Term, showEditTermWindow: Binding<Bool>) {
        self._term = State(initialValue: term)
        self._fields = State(initialValue: term.termData)
        self._showWindow = showEditTermWindow
    }
    
    var body: some View {
        VStack {
            List{ //display edit-able attributes
                HStack {
                    Text("Term Title: ")
                    TextField(fields.title, text: $fields.title)
                }
                DatePicker("Start Date", selection: $fields.startDate, displayedComponents: .date)
                //user can only pick an end date that begins on or after selected start date
                DatePicker("End Date", selection: $fields.endDate, in: PartialRangeFrom(fields.startDate), displayedComponents: .date)
                //ColorPicker("Change Marker Colour", selection: $chosenColour)
            }
            .listStyle(InsetGroupedListStyle())
            .textFieldStyle(PlainTextFieldStyle())
        
            //DELETE TERM
            Button(action: {
                //prompt warning + confirmation
                showDeleteTermConfirmation = true
            }, label: {
                Text("Delete Term").foregroundColor(.red).bold()
            }).padding()
            .alert(isPresented: $showDeleteTermConfirmation, content: { //this alert will pop up if the user selects "Delete Term" from the edit window
                Alert(title: Text("Delete Term"), message: Text("Are you sure you would like to delete term \(term.termTitle!) and all it's data permanently?"), primaryButton: .cancel(Text("Cancel"), action: { showDeleteTermConfirmation = false }),
                      secondaryButton: .destructive(Text("Delete Term"), action: {
                        showWindow = false
                        viewContext.delete(term)
                        do { try viewContext.save() } catch { print("Couldn't save term deletion in persistent storage.") }
                }))
            })
        }
        .navigationTitle("Edit Term")
        .navigationBarItems(leading: Button("Cancel", action: {
            //resetUserInput()
            showWindow = false
        }), trailing: Button("Save", action: { //set attributes to new user input
            do { try term.update(from: fields) } catch { print("Could not update term.")}
            do { try viewContext.save() } catch { print("Couldn't save term changes in persistent storage.") }
            showWindow = false
        }))
    }
}

