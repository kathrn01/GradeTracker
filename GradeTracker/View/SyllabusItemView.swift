//
//  SyllabusItemView.swift
//  GradeTracker
//
//  Created by Katharine K
//
// This view displays an indivual syllabus item on CourseView. Tapping on this view allows the user to edit the syllabus item. 

import SwiftUI

struct SyllabusItemView: View {
    @Environment(\.managedObjectContext) private var viewContext //the view will update if the viewContext makes changes
    @ObservedObject var course: Course //this item is initialized in init() instead of being passed in -- the course this syllabus item belongs to
    @ObservedObject var syllItem: SyllabusItem //this is passed in from the calling view: the syllabus item we're displaying
    
    //determines whether this view is shown -- passed in from calling view as true, when user is done editing, becomes false
    @State var displayEditSyllabusItem = false
    
    /* I am using a custom initializer here to assign the course as the syllabus item's course */
    init(syllItem: SyllabusItem) {
        self.syllItem = syllItem
        self.course = syllItem.course ?? Course()
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20.0)
                .foregroundColor(Color(red: 0.9, green: 0.9, blue: 0.9))
            VStack(alignment: .leading) {
                HStack { //display syllabus item's title and percentage of final grade it's worth
                    Text(syllItem.itemTitle ?? "Unnamed Syllabus Item")
                        .font(.title3)
                    Spacer()
                    Text("Weight: \(String(format: "%.01f", syllItem.weight))%")
                        .font(.footnote)
                        .foregroundColor(.blue)
                }
                
                if syllItem.finalGrade == -1 { //if no final grade has yet been added for this item, display a target grade OR display not enough data message
                    if syllItem.course?.targetGrade != nil { //if the target grade is not nil, the user has entered at least 100% worth of the final grade in syllabus items
                        //display the target grade
                        Text("Target Grade: \(String(format: "%.01f", syllItem.course?.targetGrade ?? 0.0))%")
                            .font(.callout)
                    } else { //the sum of weights of the syllabus items added do not make up 100% of the grade. So the target cannot be calculated.
                        Text("Target Grade: Not enough data.")
                            .font(.callout)
                    }
                } else { //if a final grade HAS been added for this item, display it, as well as the amount towards the final grade in the course that the user has achieved from this item
                    Text("Grade achieved: \(String(format: "%.01f", syllItem.finalGrade))%")
                        .font(.callout)
                    Text("Achieved \(String(format: "%.01f", syllItem.percentageOfCourseGradeAchieved))% out of possible \(String(format: "%.01f", syllItem.weight))% for this item.")
                        .font(.footnote)
                    ProgressView(value: syllItem.percentageOfCourseGradeAchieved, total: syllItem.weight)
                        .accentColor(.blue)
                }
            }.padding()
        }.padding(.horizontal)
        .lineLimit(3)
        .onTapGesture { //the user only has to tap the syllabus item to edit it
            displayEditSyllabusItem = true
        }
        .sheet(isPresented: $displayEditSyllabusItem) { //a sheet will pop up when the user taps the syllabus item
            NavigationView {
                EditSyllabusItemView(syllabusItem: syllItem, displayEditSyllabusItem: $displayEditSyllabusItem)
                    .environment(\.managedObjectContext, viewContext)
            }
        }
    }
}
