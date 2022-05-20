//
//  TermListItemView.swift
//  GradeTracker
//
//  Created by Katharine K
//
// This view displays each individual Term as a list item in HomePageView

import SwiftUI

struct TermListItemView: View {
    @Environment(\.managedObjectContext) private var viewContext //the view will update if the viewContext makes changes
    @ObservedObject var term: Term //Term being displayed
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20.0, style: .circular)
                .foregroundColor(Color(red: term.markerColor!.red, green: term.markerColor!.green, blue: term.markerColor!.blue))
            HStack {
                Text(term.termTitle!)
                    .font(.title)
                Spacer()
                // TEMPORARY -- this will eventually be how start and end dates are displayed when the functionality to add them is available. For now, this is placeholder text to help visualize what it will look like.
                VStack { //start + end date display
                    Text("Start Date")
                    Text("-")
                    Text("End Date")
                }
                .font(.callout)
            }.padding()
            .foregroundColor(textColour)
        }
    }
    
    //this will set the text colour based on if the marker colour chosen as the background is darker or lighter
    //CITATION: I got the formula for the background colour value here: https://stackoverflow.com/questions/5477702/how-to-see-if-a-rgb-color-is-too-light
    var textColour: Color {
        let backgroundColourValue = ((term.markerColor!.red * 255 * 299) + (term.markerColor!.green * 255 * 587) + (term.markerColor!.blue * 255 * 114))/1000
        if backgroundColourValue >= 128 { return .black } else { return .white }
    }
}
