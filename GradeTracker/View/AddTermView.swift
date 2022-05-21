//
//  AddTermView.swift
//  GradeTracker
//
//  Created by Katharine Kowalchuk on 2022-05-21.
//

import SwiftUI

struct AddTermView: View {
    @Environment(\.managedObjectContext) private var viewContext //the view will update if the viewContext makes changes
    @Binding var displayAddTerm: Bool //determines whether this view is displayed
    
    //these state varables record user input for properties when creating a new term
    @State var termName = ""
    @State var startDate = Date()
    @State var endDate = Date()
    @State var chosenColour = Color(red: 50, green: 50, blue: 50) //default grey
    
    var body: some View {
        List {
            Section(header: Text("Term Info")) {
                //in this section the user can add properties to the new course
                TextField("Term Title", text: $termName)
                DatePicker("Start Date", selection: $startDate)
                DatePicker("End Date", selection: $endDate, in: PartialRangeFrom(startDate))
                ColorPicker("Choose A Colour", selection: $chosenColour)
            }
            .textFieldStyle(RoundedBorderTextFieldStyle())
        }.padding()
        .listStyle(InsetGroupedListStyle())
        .navigationTitle(Text("Add A Term"))
        .navigationBarItems(leading: Button("Cancel", action: {
            resetUserInput()
        }), trailing: Button("Add Term", action: {
            //add the new term with the data given by the user
            do {
                let newTerm = try Term(viewContext: viewContext, title: termName, start: startDate, end: endDate, currGPA: nil, goalGPA: nil)
                newTerm.setMarkerColour(viewContext: viewContext, red: Double((chosenColour.cgColor?.components![0])!), green: Double((chosenColour.cgColor?.components![1])!), blue: Double((chosenColour.cgColor?.components![2])!))
                try viewContext.save()
            } catch {
                print("could not add term")
            }
            resetUserInput()
        })
        .disabled(termName.isEmpty)) //cannot add a new course without a name
    }
    
    func resetUserInput() {
        displayAddTerm = false
        termName = ""
        chosenColour = Color(red: 50, green: 50, blue: 50) //default grey
    }

}
