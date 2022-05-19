//
//  TermListItemView.swift
//  GradeTracker
//
//  Created by Katharine K
//
// This view displays each individual Term as a list item in HomePageView, and allows user to edit term information in edit mode

import SwiftUI

struct TermListItemView: View {
    @Environment(\.editMode) private var editMode //whether user selected 'edit' in HomePageView
    @Environment(\.managedObjectContext) private var viewContext //the view will update if the viewContext makes changes
    var term: Term //Term being displayed
    
    //when user selects the "info" button on the left side of the term display, this becomes true and allows the edit window to pop up
    @State var showEditTermWindow = false
    //if user chooses to delete the term in the edit window, a confirmation popup appears
    @State var showDeleteTermConfirmation = false
    
    //user input for editing the existing term information
    @State var termTitle: String 
    @State var chosenColour: Color
    
    //used an init here to initialize the term's current marker colour and title
    init(term: Term, editMode: Bool) {
        self.term = term
        self._termTitle = State(initialValue: term.termTitle ?? "New Term Title")
        self._chosenColour = State(initialValue: Color(red: term.markerColor!.red, green: term.markerColor!.green, blue: term.markerColor!.blue))
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20.0, style: .circular)
                .foregroundColor(chosenColour)
            HStack {
                Text(term.termTitle!)
                    .foregroundColor(.white)
                Spacer()
                if editMode?.wrappedValue.isEditing == true { Image(systemName: "info.circle")
                    .font(.title3)
                    .foregroundColor(.blue)
                    .onTapGesture { showEditTermWindow = true }}
            }.padding()
        }
        .sheet(isPresented: $showEditTermWindow, content: {
            NavigationView {
                List{
                    HStack {
                        Text("Term Title: ")
                        TextField(termTitle, text: $termTitle)
                    }
                    ColorPicker("Change Marker Colour", selection: $chosenColour)
                    Spacer()
                    
                    //DELETE TERM
                    Button(action: {
                        //prompt warning + confirmation
                        showDeleteTermConfirmation = true
                    }, label: {
                        Text("Delete Term").foregroundColor(.red)
                    })
                    .alert(isPresented: $showDeleteTermConfirmation, content: { //this alert will pop up if the user selects "Delete Term" from the edit window
                        Alert(title: Text("Delete Term"), message: Text("Are you sure you would like to delete term \(String(describing: term.termTitle)) and all it's data permanently?"), primaryButton: .cancel(Text("Cancel"), action: { resetUserInput() }),
                              secondaryButton: .destructive(Text("Delete Term"), action: {
                            resetUserInput()
                            viewContext.delete(term)
                            do { try viewContext.save() } catch { print("Couldn't save term deletion in persistent storage.") }
                        }))
                    })
                }
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .navigationTitle("Edit Term")
                .navigationBarItems(leading: Button("Cancel", action: {
                    resetUserInput()
                }), trailing: Button("Save Changes", action: {
                    do {
                        try term.setTitle(termTitle)
                        term.setMarkerColour(viewContext: viewContext, red: Double((chosenColour.cgColor?.components![0])!), green: Double((chosenColour.cgColor?.components![1])!), blue: Double((chosenColour.cgColor?.components![2])!))
                        try viewContext.save()
                    } catch {
                        print("Couldn't change the term's title or colour.")
                    }
                    resetUserInput()
                }))
            }
        })
    }
    
    func resetUserInput() {
        showEditTermWindow = false
    }
}
