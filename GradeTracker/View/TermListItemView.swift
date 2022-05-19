//
//  TermListItemView.swift
//  GradeTracker
//
//  Created by Katharine K
//
// This view displays each individual Term as a list item in HomePageView, and allows user to edit term information in edit mode

import SwiftUI

struct TermListItemView: View {
    @Environment(\.managedObjectContext) private var viewContext //the view will update if the viewContext makes changes
    var term: Term //Term being displayed
    var editMode: Bool //if the calling view is in edit mode, can delete or edit the term
    
    //when user selects the "info" button on the left side of the term display, this becomes true and allows the edit window to pop up
    @State var showEditTermWindow = false
    
    //user input for editing the existing term information
    @State var termTitle: String
    @State var chosenColour: Color
    
    //used an init here to initialize the term's current marker colour and title
    init(term: Term, editMode: Bool) {
        self.term = term
        self.editMode = editMode
        self.termTitle = term.termTitle ?? "New Term Title"
        self.chosenColour = Color(red: term.markerColor!.red, green: term.markerColor!.green, blue: term.markerColor!.blue)
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20.0, style: .circular)
                .foregroundColor(chosenColour)
            HStack {
                Text(term.termTitle!)
                    .foregroundColor(.white)
                Spacer()
                if editMode { Image(systemName: "info.circle")
                    .font(.title3)
                    .foregroundColor(.blue)
                    .onTapGesture { showEditTermWindow = true }}
            }.padding()
        }
        .sheet(isPresented: $showEditTermWindow, content: {
            NavigationView {
                List{
                    TextField("Term Title: ", text: $termTitle)
                    ColorPicker("Change Marker Colour", selection: $chosenColour)
                }
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
