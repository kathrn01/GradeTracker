//
//  HomePageView.swift
//  GradeTracker
//
//  Created by Katharine K
//

import SwiftUI
import CoreData

struct HomePageView: View {
    // ----- this code provided automatically by xcode (modified for purposes of this app)
    @Environment(\.managedObjectContext) private var viewContext //the view will update if the viewContext makes changes
    @FetchRequest(sortDescriptors: [], animation: .default) //this fetch request will allow to display all terms saved to persistent storage (created by the user)
    private var terms: FetchedResults<Term> //use the 'terms' variable to display and modify the terms
    // ------ end of provided code
    
    //this state variable is changed to true if the user selects "add term"
    @State var displayAddTerm = false
    
    //these state varables record user input for properties when creating a new term
    @State var termName = ""
    @State var currGPA = ""
    @State var goalGPA = ""
    @State var chosenColour = Color(red: 50, green: 50, blue: 50) //default grey

    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    //all terms added by the user will appear as a list under the title
                    ForEach(terms) { term in
                        //click on a term to go to the view for that term and view/add/delete it's courses
                        NavigationLink(destination: TermView(term: term)) {
                            TermListItemView(term: term)
                        }
                        .aspectRatio(4/1, contentMode: .fit)
                    }
                } //ScrollView
                
                //add a term
                Button(action: {
                        displayAddTerm = true
                }) {
                        Label("Add Term", systemImage: "plus.circle")
                            .foregroundColor(.black)
                            .font(.headline)
                }
            }//VStack 
            .padding()
            .navigationTitle(Text("Terms"))
            .navigationBarItems(leading: Image(systemName: "settings").foregroundColor(.blue))
        }//NavigationView
        //this sheet will present when the user selects "add term"
        .sheet(isPresented: $displayAddTerm, content: {
            NavigationView {
                List {
                    Section(header: Text("Term Info")) {
                        //in this section the user can add a term name and optionally a goal GPA
                        //if a goal GPA is provided, the goal grades for the courses in that term will be set automatically to meet the GPA goal for the term
                        //if no goal GPA is provided for the term, the user can manually set goal grades for individual courses
                        TextField("Term Title", text: $termName)
                        TextField("Current GPA", text: $currGPA)
                            .keyboardType(.decimalPad)
                        TextField("Goal GPA (Optional)", text: $goalGPA)
                            .keyboardType(.decimalPad)
                        ColorPicker("Choose A Colour", selection: $chosenColour)
                    }
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                }.padding()
                .navigationBarItems(leading: Button("Cancel", action: {
                    resetUserInput()
                }), trailing: Button("Add Term", action: {
                    //add the new term with the data given by the user
                    do {
                        let newTerm = try Term(viewContext: viewContext, title: termName, start: nil, end: nil, currGPA: Double(currGPA), goalGPA: Double(goalGPA))
                        newTerm.setMarkerColour(viewContext: viewContext, red: Double((chosenColour.cgColor?.components![0])!), green: Double((chosenColour.cgColor?.components![0])!), blue: Double((chosenColour.cgColor?.components![0])!))
                        try viewContext.save()
                    } catch {
                        print("could not add term")
                    }
                    resetUserInput()
                })
                .disabled(termName.isEmpty)) //cannot add a term with no name provided
            }
        })
    }
    
    func resetUserInput() {
        displayAddTerm = false
        termName = ""
        goalGPA = ""
        currGPA = ""
        chosenColour = Color(red: 50, green: 50, blue: 50) //default grey
    }
}
