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
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "startDate", ascending: false)], animation: .default) //this fetch request will allow to display all terms saved to persistent storage (created by the user)
    private var terms: FetchedResults<Term> //use the 'terms' variable to display and modify the terms
    // ------ end of provided code
    
    //this state variable is changed to true if the user selects "add term"
    @State var displayAddTerm = false

    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    //all terms added by the user will appear as a list under the title
                    ForEach(terms) { term in
                        //click on a term to go to the view for that term and view/add/delete it's courses
                        NavigationLink(destination: TermView(term: term)) {
                            TermListItemView(term: term)
                                .environment(\.managedObjectContext, viewContext)
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
            .navigationBarItems(leading: Image(systemName: "info.circle").foregroundColor(.blue))
        }//NavigationView
        //this sheet will present when the user selects "add term"
        .sheet(isPresented: $displayAddTerm, content: {
            NavigationView {
                AddTermView(displayAddTerm: $displayAddTerm)
                    .environment(\.managedObjectContext, viewContext)
            }
        })
    }
}
