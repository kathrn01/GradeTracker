//
//  TermListView.swift
//  GradeTracker
//
//  Created by Katharine K
//

import SwiftUI
import CoreData

struct TermListView: View {
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

    var body: some View {
        NavigationView {
            VStack {
                Text("Grade Tracker")
                    .font(.title)
                
                //all terms added by the user will appear as a list under the title
                List {
                    ForEach(terms) { term in
                        //click on a term to go to the view for that term and view/add/delete it's courses
                        NavigationLink(destination: CourseListView(term: term)) {
                            Text(term.termTitle ?? "Unnamed")
                        }
                    }
                    //delete a term from the list by swiping left
                    .onDelete(perform: { indexSet in
                        indexSet.forEach({ viewContext.delete(terms[$0])})
                        do { try viewContext.save() } catch { print("Could not delete term.") }
                    })
                }

                //add a term
                Button(action: {
                        displayAddTerm = true
                }) {
                        Label("Add Term", systemImage: "plus")
                }
            
            }
        }
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
                    }
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                }.padding()
                .navigationBarItems(leading: Button("Cancel", action: {
                    displayAddTerm = false
                    termName = ""
                    goalGPA = ""
                    currGPA = ""
                    
                }), trailing: Button("Add Term", action: {
                    //add the new term with the data given by the user
                    do {
                        let _ = try Term(viewContext: viewContext, title: termName, start: nil, end: nil, currGPA: Double(currGPA), goalGPA: Double(goalGPA))
                        try viewContext.save()
                    } catch {
                        print("could not add term")
                    }
                    displayAddTerm = false
                    termName = ""
                    goalGPA = ""
                    currGPA = ""
                })
                .disabled(termName.isEmpty)) //cannot add a term with no name provided
            }
        })
    }
}
