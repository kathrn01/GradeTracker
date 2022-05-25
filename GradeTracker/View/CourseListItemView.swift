//
//  CourseListItemView.swift
//  GradeTracker
//
//  Created by Katharine K
//
// This view displays a course in a term as a list item in TermView 

import SwiftUI

struct CourseListItemView: View {
    var course: Course //passed in from TermView -- the course to be displayed
    var textColour: Color //passed in from TermView -- based on the term's marker colour, which colour the text should be for visibility
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(Color(red: course.term?.markerColor?.red ?? 0, green: course.term?.markerColor?.green ?? 0, blue: course.term?.markerColor?.blue ?? 0))
            HStack {
                Text(course.courseTitle ?? "Unnamed Course")
                    .font(.title)
                Spacer()
                VStack {
                    Text("Goal Grade: ")
                    Text("\(String(format: "%.01f", course.goalGrade))%")
                        .font(.callout)
                }
            }
            .foregroundColor(textColour)
            .padding(.horizontal)
        }
    }
}
