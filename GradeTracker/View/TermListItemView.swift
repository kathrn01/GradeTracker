//
//  TermListItemView.swift
//  GradeTracker
//
//  Created by Katharine K
//
// This view displays each individual Term as a list item in HomePageView

import SwiftUI

struct TermListItemView: View {
    @ObservedObject var term: Term //Term being displayed
    
    var body: some View {
        ZStack {
            //background rectangle that the term name and start/end dates are displayed on
            RoundedRectangle(cornerRadius: 20.0, style: .circular)
                .foregroundColor(Color(red: term.markerColor?.red ?? 0, green: term.markerColor?.green ?? 0, blue: term.markerColor?.blue ?? 0))
            HStack { //term name and start + end dates
                Text(term.termTitle ?? "Unnamed Term")
                    .font(.title)
                Spacer()
                VStack { //start + end date display
                    Text(term.startDate ?? Date(), formatter: dateFormatStartEnd)
                    Text("-")
                    Text(term.endDate ?? Date(), formatter: dateFormatStartEnd)
                }
                .font(.footnote)
            }.padding()
            .foregroundColor(textColour)
        }
    }
    
    //this will set the text colour based on if the marker colour chosen as the background is darker or lighter
    //CITATION: I got the formula for the background colour value here: https://stackoverflow.com/questions/5477702/how-to-see-if-a-rgb-color-is-too-light
    var textColour: Color {
        let bgRed = (term.markerColor?.red ?? 0) * 255
        let bgGreen = (term.markerColor?.green ?? 0) * 255
        let bgBlue = (term.markerColor?.blue ?? 0) * 255
        let backgroundColourValue = ((bgRed * 299) + (bgGreen * 587) + (bgBlue * 114))/1000
        if backgroundColourValue >= 128 { return .black } else { return .white }
    }
    
    //referenced how to format the date from here: https://stackoverflow.com/questions/62814989/swiftui-date-formatting
    var dateFormatStartEnd: DateFormatter {
        let format = DateFormatter()
        format.dateFormat = "dd MMM yyyy"
        return format
    }
}
