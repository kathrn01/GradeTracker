//
//  CourseTests.swift
//  GradeTrackerTests
//
//  Created by Katharine Kowalchuk on 2022-05-17.
//

import XCTest
@testable import GradeTracker

class CourseTests: XCTestCase {
    //this is the preview context that will be used to instantiate core data objects
    //all objects created in the tests will be destroyed at the end
    let testViewContext = PersistenceController.preview.container.viewContext
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        //delete all objects created and saved before next test method
        testViewContext.registeredObjects.forEach({ testViewContext.delete($0) })
        try testViewContext.save()
    }

    /* -------------- TARGET GRADE  -------------- */
    //test how the target grade is computed when there are no syllabus items added to the course
    func testTargetGrade_NoSyllabusItems() throws {
    }
    
    //test target grade when there are not enough syllabus items added (all items together do not make up 100% of final grade)
    func testTargetGrade_InsufficientItems() throws {
        
    }
    
    //test target grade when bonus syllabus items are added to the course (all items together make up OVER 100% of final grade)
    func testTargetGrade_BonusItems() throws {
        
    }
    
    //test how the target grade is computed when there are no final grades for syllabus items in the course
    func testTargetGrade_NoFinalGrades() throws {
        
    }
    
    //test target grade when goal grade is changed from original
    func testTargetGrade_NewGoal() throws {
        
    }
    
    //test the target grade when syllabus items are added to the course
    func testTargetGrade_AddItems() throws {
        
    }
    
    //test the target grade when syllabus items are removed from the course
    func testTargetGrade_RemoveItems() throws {
        
    }
    
    //test the target grade when syllabus items are added with a final grade that is below the goal
    func testTargetGrade_ItemGradeBelowGoal() throws {
        
    }
    
    //test the target grade when syllabus items are added with a final grade that is above the goal
    func testTargetGrade_ItemGradedAboveGoal() throws {
        
    }
    
    //test the target grade when all items (making up >= 100% of grade) have been assigned a final grade
    func testTargetGrade_AllItemsGraded() throws {
        
    }
    
    //test target grade when the weight of syllabus items are modified from original
    func testTargetGrade_ItemWeightChange() throws {
        
    }
    
    //test target grade when the final grade of syllabus items is changed from original
    func testTargetGrade_ItemFinalGradeChange() throws {
        
    }
}
