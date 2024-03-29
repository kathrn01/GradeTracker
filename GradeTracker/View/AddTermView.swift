//
//  AddTermView.swift
//  GradeTracker
//
//  Created by Katharine K
//
// This view is shown when the user selects "Add Term" on HomePageView

import SwiftUI

struct AddTermView: View {
    @Environment(\.managedObjectContext) private var viewContext //the view will update if the viewContext makes changes
    @Binding var displayAddTerm: Bool //determines whether this view is displayed
    
    //these state varables record user input for properties when creating a new term
    @State var termName = ""
    @State var startDate = Date()
    @State var endDate = Date()
    @State var chosenColour = Color(red: 0.7, green: 0.7, blue: 0.7) //default grey
    
    var body: some View {
        List {
            Section(header: Text("Term Info")) {
                //in this section the user can add properties to the new term
                TextField("Term Title", text: $termName)
                DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                DatePicker("End Date", selection: $endDate, in: PartialRangeFrom(startDate), displayedComponents: .date)
                ColorPicker("Choose A Colour", selection: $chosenColour)
            }
            .textFieldStyle(PlainTextFieldStyle())
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle(Text("New Term"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(leading: Button("Cancel", action: { resetUserInput() }), trailing: Button("Add", action: {
            //add the new term with the data given by the user
            let chosenColourComponents = chosenColour.cgColor!.components  //gives rbg of default grey if components nil
            do {
                _ = try Term(viewContext: viewContext, title: termName, start: startDate, end: endDate, currGPA: nil, goalGPA: nil, markerColour: [Double(chosenColourComponents![0]), Double(chosenColourComponents![1]), Double(chosenColourComponents![2])])
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
        chosenColour = Color(red: 0.7, green: 0.7, blue: 0.7) //default grey
    }

}
