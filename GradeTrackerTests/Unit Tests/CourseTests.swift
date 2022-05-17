//
//  CourseTests.swift
//  GradeTrackerTests
//
//  Created by Katharine K
//

import XCTest
@testable import GradeTracker

class CourseTests: XCTestCase {
    //this is the preview context that will be used to instantiate core data objects
    //all objects created in the tests will be destroyed at the end
    let testViewContext = PersistenceController.preview.container.viewContext
    var testCourse = Course()
    
    //SETUP
    override func setUpWithError() throws {
        //create a course object for test method to use
        testCourse = try Course(viewContext: testViewContext, title: "testCourse", creditHrs: nil, goalGrade: 85.0)
    }

    //TEARDOWN
    override func tearDownWithError() throws {
        //delete all objects created and saved before next test method
        testViewContext.registeredObjects.forEach({ testViewContext.delete($0) })
        try testViewContext.save()
    }

    /* -------------- TARGET GRADE TESTS  -------------- */
    //test how the target grade is computed when there are no syllabus items added to the course
    func testTargetGrade_NoSyllabusItems() throws {
        //when there are no syllabus items, the target grade should return nil (not enough data)
        XCTAssertTrue((testCourse.syllabusItems?.allObjects ?? []).isEmpty) //the course has no syllabus items
        XCTAssertEqual(testCourse.goalGrade, 85.0) //the goal grade is set
        XCTAssertNil(testCourse.targetGrade) //target grade returns nil
    }
    
    //test target grade when there are not enough syllabus items added (all items together do not make up 100% of final grade)
    func testTargetGrade_InsufficientItems() throws {
        //add a syllabus item worth 10% of the final course grade
        try testCourse.addSyllabusItem(viewContext: testViewContext, title: "test1", weight: 10.0, finalGrade: nil)
        XCTAssertEqual((testCourse.syllabusItems?.allObjects ?? []).count, 1) //there is one syllabus item in testCourse
        XCTAssertEqual(testCourse.totalCoursePoints, 10.0) //there are 10 points accounted for (10% of total grade)
        XCTAssertEqual(testCourse.goalGrade, 85.0) //goal grade has been set for the course
        XCTAssertNil(testCourse.targetGrade) //targetGrade returns nil
        
        //add a syllabus item worth 50% of the final course grade, with a final grade
        try testCourse.addSyllabusItem(viewContext: testViewContext, title: "test 2", weight: 50.0, finalGrade: nil)
        XCTAssertEqual((testCourse.syllabusItems?.allObjects ?? []).count, 2) //there are two syllabus items in testCourse
        XCTAssertEqual(testCourse.totalCoursePoints, 60.0) //there are 60 points accounted for (60% of total grade)
        XCTAssertEqual(testCourse.goalGrade, 85.0) //goal grade has been set for the course
        XCTAssertNil(testCourse.targetGrade) //targetGrade returns nil
    }
    
    //test that the target grade is correctly calculated when 100% of final grade is accounted for by syllabus item weights, when no final grades have yet been given to any item
    func testTargetGrade_SufficientItems_NoFinalGrades() throws {
        //these four syllabus items' weights total 100% of final grade
        try testCourse.addSyllabusItem(viewContext: testViewContext, title: "test 1", weight: 20.0, finalGrade: nil) //worth 20% of final grade
        XCTAssertNil(testCourse.targetGrade) //targetGrade returns nil
        
        try testCourse.addSyllabusItem(viewContext: testViewContext, title: "test 2", weight: 40.0, finalGrade: nil) //worth 40% of final grade
        XCTAssertNil(testCourse.targetGrade) //targetGrade returns nil
        
        try testCourse.addSyllabusItem(viewContext: testViewContext, title: "quiz 1", weight: 15.0, finalGrade: nil) //worth 15% of final grade
        XCTAssertNil(testCourse.targetGrade) //targetGrade returns nil
        
        try testCourse.addSyllabusItem(viewContext: testViewContext, title: "quiz 2", weight: 25.0, finalGrade: nil) //worth 25% of final grade
        XCTAssertNotNil(testCourse.targetGrade) //targetGrade is now not nil; sufficient items
        
        XCTAssertEqual((testCourse.syllabusItems?.allObjects ?? []).count, 4) //there are four syllabus items
        XCTAssertEqual(testCourse.totalCoursePoints, 100.0) //the syllabus items make up the full final grade
        XCTAssertEqual(testCourse.goalGrade, 85.0) //the goal grade is set
        XCTAssertEqual(testCourse.totalPointsAchieved, 0) //no final grades given, thus no points achieved
        XCTAssertEqual(testCourse.targetGrade, 85.0) //since no final grades given, the target grade is the same as the goal grade
    }
    
    
    //test that the target grade is correctly calculated when 100% of final grade is accounted for by syllabus item weights, when some, and all final grades have been assigned
    func testTargetGrade_SufficientItems_WithFinalGrades() throws {
        //these four syllabus items' weights total 100% of final grade
        //given 70% final grade
        try testCourse.addSyllabusItem(viewContext: testViewContext, title: "test 1", weight: 20.0, finalGrade: 70.0) //worth 20% of final grade
        XCTAssertNil(testCourse.targetGrade) //targetGrade returns nil
        
        try testCourse.addSyllabusItem(viewContext: testViewContext, title: "test 2", weight: 40.0, finalGrade: nil) //worth 40% of final grade
        XCTAssertNil(testCourse.targetGrade) //targetGrade returns nil
        
        //given 90% final grade
        try testCourse.addSyllabusItem(viewContext: testViewContext, title: "quiz 1", weight: 15.0, finalGrade: 90.0) //worth 15% of final grade
        XCTAssertNil(testCourse.targetGrade) //targetGrade returns nil
        
        try testCourse.addSyllabusItem(viewContext: testViewContext, title: "quiz 2", weight: 25.0, finalGrade: nil) //worth 25% of final grade
        XCTAssertNotNil(testCourse.targetGrade) //targetGrade is now not nil; sufficient items
        
        //preliminary
        XCTAssertEqual((testCourse.syllabusItems?.allObjects ?? []).count, 4) //there are four syllabus items
        XCTAssertEqual(testCourse.totalCoursePoints, 100.0) //the syllabus items make up the full final grade
        XCTAssertEqual(testCourse.goalGrade, 85.0) //the goal grade is set
        
        //the number of points achieved (percentage of final grade achieved) by the two syllabus items assigned a final grade
        let pointsFromTest1 = 20 * 0.7 //test 1 is worth 20% of final grade, multiplied by the final grade of 70% on the test
        let pointsFromQuiz1 = 15 * 0.9 //quiz 1 is worth 15% of final grade, multiplied by the final grade of 90% on the quiz
        
        XCTAssertEqual(testCourse.totalPointsAchieved, pointsFromTest1 + pointsFromQuiz1) //achieved percentage should reflect points from syllabus items given a final grade
        //the correct target grade should be calculated as the total percentage of final grade achieved divided by the sum of all syllabus item weights and then multiplied by 100 to get as a percentage
        let correctTargetGrade = (testCourse.totalPointsAchieved/testCourse.totalCoursePoints) * 100
        XCTAssertEqual(testCourse.targetGrade, correctTargetGrade)
    }
    //test target grade when bonus syllabus items are added to the course (all items together make up OVER 100% of final grade)
    func testTargetGrade_BonusItems() throws {
        
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
