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
    var term: Term //this variable is passed from the calling view
    
    //determines whether this view is shown -- passed in from calling view as true, when user is done editing, becomes false
    @Binding var showEditTermWindow: Bool
    
    //if user chooses to delete the term in the edit window, a confirmation popup appears
    @State var showDeleteTermConfirmation = false
    
    //user input for editing the existing term information
    @State var termTitle: String
    @State var startDate: Date
    @State var endDate: Date
    @State var chosenColour: Color
    
    /* I am using a custom initializer here to assign user input initially to the term's existing attribute values  */
    init(term: Term, showEditTermWindow: Binding<Bool>) {
        self.term = term
        self._showEditTermWindow = showEditTermWindow
        self._termTitle = State(initialValue: term.termTitle ?? "New Term Title")
        self._startDate = State(initialValue: term.startDate ?? Date()) 
        self._endDate = State(initialValue: term.endDate ?? Date())
        self._chosenColour = State(initialValue: Color(red: term.markerColor?.red ?? 0, green: term.markerColor?.green ?? 0, blue: term.markerColor?.blue ?? 0))
    }
    var body: some View {
        VStack {
            List{ //display edit-able attributes
                HStack {
                    Text("Term Title: ")
                    TextField(termTitle, text: $termTitle)
                }
                DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                //user can only pick an end date that begins on or after selected start date
                DatePicker("End Date", selection: $endDate, in: PartialRangeFrom(startDate), displayedComponents: .date)
                ColorPicker("Change Marker Colour", selection: $chosenColour)
            }
            .listStyle(InsetGroupedListStyle())
            .textFieldStyle(RoundedBorderTextFieldStyle())
        
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
                        showEditTermWindow = false
                    viewContext.delete(term)
                    do { try viewContext.save() } catch { print("Couldn't save term deletion in persistent storage.") }
                }))
            })
        }
        .navigationTitle("Edit Term")
        .navigationBarItems(leading: Button("Cancel", action: {
            resetUserInput()
        }), trailing: Button("Save Changes", action: { //save changes to persistence
            do {
                try term.setTitle(termTitle)
                term.startDate = startDate
                term.endDate = endDate
                //set the marker colour based on the new RGB components of the new chosen colour
                term.setMarkerColour(red: Double((chosenColour.cgColor?.components![0])!), green: Double((chosenColour.cgColor?.components![1])!), blue: Double((chosenColour.cgColor?.components![2])!))
                try viewContext.save()
            } catch {
                print("Couldn't change the term's attributes.")
            }
            resetUserInput()
        }))
    }
    
    func resetUserInput() {
        showEditTermWindow = false
        termTitle = term.termTitle ?? "Term Name"
        startDate = term.startDate ?? Date()
        endDate = term.endDate ?? Date()
        chosenColour = Color(red: term.markerColor!.red, green: term.markerColor!.green, blue: term.markerColor!.blue)
    }
}

