//
//  SyllabusItem+CoreDataClass.swift
//  GradeTracker
//
//  Created by Katharine K
//
//

import Foundation
import CoreData

@objc(SyllabusItem)
public class SyllabusItem: NSManagedObject {
    //initialize with data -- propagate error to the calling code to handle
    convenience init(viewContext: NSManagedObjectContext, course: Course, title: String, weight: Double, grade: Double?, dueDate: Date) throws {
        self.init(context: viewContext)
        self.id = UUID()
        self.course = course
        try self.setTitle(title)
        try self.setWeight(weight)
        self.dueDate = dueDate 
        if grade != nil { try setFinalGrade(grade!) }
        try viewContext.save()
    }
    
    
    struct SIData {
        var title: String = ""
        var weight: String = "0.0"
        var grade: String = "None"
        var dueDate: Date = Date()
    }
    
    var syllabusItemData: SIData {
        SIData(title: itemTitle ?? "Untitled", weight: String(weight), grade:  self.finalGrade > -1 ? String(self.finalGrade) : "None Assigned", dueDate: dueDate ?? Date())
    }
    
    func update(from: SIData) throws {
        try setTitle(from.title)
        try setWeight(Double(from.weight) ?? self.weight)
        try setFinalGrade(Double(from.grade) ?? self.finalGrade) 
        self.dueDate = from.dueDate
    }
    
    /* -------------- FETCH  -------------- */
    //use to access stored syllabus items
    //got idea to keep fetch request in Model to minimize use in View from this repository:
    //https://github.com/gahntpo/Slipbox/blob/main/Shared/model/Folder%2Bhelper.swift
    static func fetchSyllItems(forCourse: Course) -> NSFetchRequest<SyllabusItem> {
        let request = NSFetchRequest<SyllabusItem>(entityName: "SyllabusItem") //all terms that exist
        request.sortDescriptors = [NSSortDescriptor(key: "dueDate", ascending: true)] //displayed by earliest due date
        request.predicate = NSPredicate(format: "course == %@", forCourse)
        return request
    }
    
    /* -------------- COMPUTED VARIABLE(S)  -------------- */
    //if item is graded, how many points towards final grade are achieved
    var percentageOfCourseGradeAchieved: Double {
        if finalGrade > -1 { return weight * (finalGrade/100) }
        return 0
    }
    
    /* -------------- SETTERS  -------------- */
    //propagates an error to the calling function if the title is empty or contains only whitespace characters
    private func setTitle(_ newTitle: String) throws {
        if !newTitle.isEmpty && !newTitle.trimmingCharacters(in: .whitespaces).isEmpty { self.itemTitle = newTitle}
        else if newTitle.isEmpty { throw InvalidPropertySetter.titleEmpty }
        else if newTitle.trimmingCharacters(in: .whitespaces).isEmpty { throw InvalidPropertySetter.titleWhitespaces }
    }

    //propagates an error to the calling function if the syllabus item's weight is attempted to be set as negative
    func setWeight(_ newWeight: Double) throws {
        if newWeight != self.weight { //weight was updated
            if newWeight >= 0 { //valid
                let currAchieved = percentageOfCourseGradeAchieved //percentage of course grade achieved with current item weight
                let weightDiff = newWeight - self.weight //difference between new item weight and current item weight
                
                self.weight = newWeight //set weight to new weight
                
                course?.addTotalPoints(weightDiff) //add difference to the course's total points
                
                //if there is a grade assigned, update the percentage of the course completed and percentage achieved
                if finalGrade > -1 {
                    let gradeDiff = percentageOfCourseGradeAchieved - currAchieved //% of course achieved w/ NEW weight minus % achieved w/ PREV weight
                    course?.addAchievedPoints(gradeDiff) //add grade percentage difference to course's achieved points
                    course?.addCompletedPoints(weightDiff) //add weight difference to course's completed points
                }
            }
            else { throw InvalidPropertySetter.negativeValue }
        }
    }
    
    //propagates an error to the calling function if the syllabus item's final grade is attempted to be set as negative
    func setFinalGrade(_ grade: Double) throws {
        if grade != self.finalGrade { //the grade was updated
            if grade >= 0 { //valid
                let currAchieved = percentageOfCourseGradeAchieved //percentage achieved in course with CURRENT grade
                
                if self.finalGrade < 0 { //if the final grade is being added for the first time, update course's completed points with item weight
                    course?.addCompletedPoints(self.weight)
                }
                
                self.finalGrade = grade //set the new final grade
                let gradeDiff = percentageOfCourseGradeAchieved - currAchieved //difference between points achieved w/ NEW grade and points achieved w/ PREV grade
                course?.addAchievedPoints(gradeDiff) //add the difference to the course's achieved points
            
                
            } else { throw InvalidPropertySetter.negativeValue } //throw exception if user tries to set negative grade value
        }
    }
    
    //removes the final grade if one was previously added
    func removeFinalGrade() {
        course?.removeCompletedPoints(self.weight)
        course?.removeAchievedPoints(percentageOfCourseGradeAchieved)
        self.finalGrade = -1
    }
}
