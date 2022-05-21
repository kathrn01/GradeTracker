//
//  SyllabusItemView.swift
//  GradeTracker
//
//  Created by Katharine Kowalchuk on 2022-05-21.
//

import SwiftUI

struct SyllabusItemView: View {
    var syllItem: SyllabusItem
    @State var displayEditSyllabusItem = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(syllItem.itemTitle ?? "Unnamed Syllabus Item")
                    .font(.title3)
                Spacer()
                Text("Worth: \(String(format: "%.01f", syllItem.weight))% of final grade.")
                    .font(.footnote)
                    .foregroundColor(.blue)
            }
            .padding(.bottom)
            if syllItem.finalGrade == -1 {
                if syllItem.course?.targetGrade != nil {
                    Text("Target: \(String(format: "%.01f", syllItem.course?.targetGrade ?? 0.0))%")
                        .font(.callout)
                } else {
                    Text("Target: Not enough data.")
                        .font(.callout)
                }
            } else {
                Text("Grade achieved: \(String(format: "%.01f", syllItem.finalGrade))%")
                    .font(.callout)
                Text("With the mark for this item, you have added \(String(format: "%.01f", syllItem.percentageOfCourseGradeAchieved))% towards your final grade in the course.")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
        .onTapGesture {
            displayEditSyllabusItem = true
        }
        .sheet(isPresented: $displayEditSyllabusItem) {
            NavigationView {
                EditSyllabusItemView(syllabusItem: syllItem, displayEditSyllabusItem: $displayEditSyllabusItem)
            }
        }
    }
}
