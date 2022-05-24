//
//  CourseDashboardView.swift
//  GradeTracker
//
//  Created by Katharine K
//
// This view is displayed on CourseView and shows the course's stats

import SwiftUI

struct CourseDashboardView: View {
    @Environment(\.managedObjectContext) private var viewContext //the view will update if the viewContext makes changes
    var course: Course //the course whos dashboard to display -- passed in from CourseView
    @State var displayEditWindow = false
    
    var body: some View {
        VStack(alignment: .leading) {
            let goalToDisplay = (course.goalGrade <= 0) ? 1 : course.goalGrade //incase there are no totalCourse points, make denominator 1
            let totalPointsDisplay = (course.totalPointsAchieved > goalToDisplay) ? goalToDisplay : course.totalPointsAchieved //if the points achieved > the goal

            //display course title and edit button
            HStack {
                Text(course.courseTitle ?? "Unnamed Course")
                    .font(.title)
                Spacer()
                Button(action: { displayEditWindow = true }, label: { Image(systemName: "info.circle").font(.title2) })
            }
            
            //display goal grade if not all syllabus items have been graded, or if they have, display the final grade achieved in the course
            if course.targetGrade != nil && (course.totalPointsCompleted == course.totalCoursePoints) {
                Text("Final Grade: \(String(format: "%.01f", (course.totalPointsAchieved)))%")
                    .font(.headline)
            } else {
                Text("Goal Grade: \(String(format: "%.01f", course.goalGrade))%")
                    .font(.headline)
            }

            //can only display progress view if all syllabus items (making up >= 100% of course) have been entered
            if course.targetGrade != nil {
                //message above progress display
                if course.totalPointsAchieved < course.goalGrade { //if user has not achieved goal grade
                    Text("You have achieved \(String(format: "%.01f", course.totalPointsAchieved))% towards your goal grade.")
                        .font(.callout)
                } else if course.totalPointsAchieved == course.goalGrade { //if user has achieved exact goal grade
                    Text("Congratulations, you've achieved your goal grade!")
                        .font(.callout)
                } else { //if user has surpassed goal grade
                    Text("Good work! You've surpassed your goal grade.")
                        .font(.callout)
                }
                
                //view progress bar in same colour as the term marker colour
                ProgressView(value: totalPointsDisplay, total:  goalToDisplay)
                    .accentColor(Color(red: course.term?.markerColor?.red ?? 0, green: course.term?.markerColor?.green ?? 0, blue: course.term?.markerColor?.blue ?? 0))
                    .scaleEffect(x: 1, y: 4, anchor: .center)
            }
        }
        .padding()
        .sheet(isPresented: $displayEditWindow, content: { //this sheet will be presented if the user selects "Edit Course" in the top right corner
            NavigationView {
                EditCourseView(course: course, displayEditCourse: $displayEditWindow)
                    .environment(\.managedObjectContext, viewContext)
            }
        })
    }
}
