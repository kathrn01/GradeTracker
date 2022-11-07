//
//  HomePageView.swift
//  GradeTracker
//
//  Created by Katharine K
//
// This is the view the user sees when opening the app

import SwiftUI
import CoreData

struct AllTermsView: View {
    // ----- this code provided automatically by xcode (modified for purposes of this app)
    @Environment(\.managedObjectContext) private var viewContext //the view will update if the viewContext makes changes
//    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "startDate", ascending: true)], animation: .default) //this fetch request will allow to display all terms saved to persistent storage (created by the user)
//    private var terms: FetchedResults<Term> //use the 'terms' variable to display and modify the terms
    // ------ end of provided code
    @FetchRequest(fetchRequest: Term.fetchTerms()) var terms: FetchedResults<Term>
    
    //this state variable is changed to true if the user selects "add term"
    @State var displayAddTerm = false

    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    //all terms added by the user will appear as a list under the title
                    if terms.isEmpty {
                        Text("No terms added yet.")
                    }

                    ForEach(terms) { term in
                        //click on a term to go to the view for that term and view/add/delete it's courses
                        NavigationLink(destination: TermView(term: term).environment(\.managedObjectContext, viewContext)){
                            TermListItemView(term: term)
                        }
                        .frame(width: nil, height: nil)
                    }
                } //ScrollView
                
                //add a term
                Button(action: { displayAddTerm = true }) {
                        Label("New Term", systemImage: "plus.circle")
                            .foregroundColor(.blue)
                            .font(.title2)
                }
            }//VStack
            .padding()
            .navigationTitle(Text("Terms"))
            .navigationBarTitleDisplayMode(.automatic)
        }//NavigationView
        .navigationViewStyle(StackNavigationViewStyle())
        //this sheet will present when the user selects "add term"
        .sheet(isPresented: $displayAddTerm, content: {
            NavigationView {
                AddTermView(displayAddTerm: $displayAddTerm)
                    .environment(\.managedObjectContext, viewContext)
            }
        })
    }
}
