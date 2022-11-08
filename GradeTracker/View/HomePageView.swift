//
//  HomePageView.swift
//  GradeTracker
//
//  Created by Katharine Kowalchuk on 2022-11-07.
//

import SwiftUI

struct HomePageView: View {
    @Environment(\.managedObjectContext) private var viewContext //the view will update if the viewContext makes changes
    var body: some View {
        NavigationView {
            VStack {
                Image("G")
                NavigationLink("My Terms", destination: AllTermsView().environment(\.managedObjectContext, viewContext))
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
