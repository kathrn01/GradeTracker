//
//  TermListItemView.swift
//  GradeTracker
//
//  Created by Katharine K
//
// This view displays each individual Term as a list item in HomePageView

import SwiftUI

struct TermListItemView: View {
    var term: Term
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10.0, style: .circular)
                .foregroundColor(Color(red: term.markerColor?.red ?? 0, green: term.markerColor?.green ?? 0, blue: term.markerColor?.blue ?? 0))
            Text(term.termTitle!)
                .foregroundColor(.white)
        }
    }
}
