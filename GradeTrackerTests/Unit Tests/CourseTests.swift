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
    var testTerm = Term()
    
    //SETUP
    override func setUpWithError() throws {
        //test term for test course to be added to
        var dateComponent = DateComponents()
        dateComponent.day = 1
        
        testTerm = try Term(viewContext: testViewContext, title: "testTerm", start: Date(), end: Calendar.current.date(byAdding: dateComponent, to: Date()), currGPA: nil, goalGPA: nil)
        //create a course object for test method to use
        testCourse = try Course(viewContext: testViewContext, title: "testCourse", creditHrs: nil, goalGrade: 85.0)
        
        //add testCourse to testTerm
        testTerm.addToCourseList(testCourse)
    }

    //TEARDOWN
    override func tearDownWithError() throws {
        //delete all objects created and saved before next test method
        testViewContext.registeredObjects.forEach({ testViewContext.delete($0) })
        try testViewContext.save()
    }
    
    /* -------------- TEST ADD SYLLABUS ITEM  -------------- */
    

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
        try testCourse.addSyllabusItem(viewContext: testViewContext, title: "test1", weight: 10.0, finalGrade: nil, dueDate: Date())
        XCTAssertEqual((testCourse.syllabusItems?.allObjects ?? []).count, 1) //there is one syllabus item in testCourse
        XCTAssertEqual(testCourse.totalCoursePoints, 10.0) //there are 10 points accounted for (10% of total grade)
        XCTAssertEqual(testCourse.goalGrade, 85.0) //goal grade has been set for the course
        XCTAssertNil(testCourse.targetGrade) //targetGrade returns nil
        
        //add a syllabus item worth 50% of the final course grade, with a final grade
        try testCourse.addSyllabusItem(viewContext: testViewContext, title: "test 2", weight: 50.0, finalGrade: nil, dueDate: Date())
        XCTAssertEqual((testCourse.syllabusItems?.allObjects ?? []).count, 2) //there are two syllabus items in testCourse
        XCTAssertEqual(testCourse.totalCoursePoints, 60.0) //there are 60 points accounted for (60% of total grade)
        XCTAssertEqual(testCourse.goalGrade, 85.0) //goal grade has been set for the course
        XCTAssertEqual(testCourse.totalPointsCompleted, 0) //no items, so can't have any completed
        XCTAssertNil(testCourse.targetGrade) //targetGrade returns nil
    }
    
    //test that the target grade is correctly calculated when 100% of final grade is accounted for by syllabus item weights, when no final grades have yet been given to any item
    func testTargetGrade_SufficientItems_NoFinalGrades() throws {
        //these four syllabus items' weights total 100% of final grade
        try testCourse.addSyllabusItem(viewContext: testViewContext, title: "test 1", weight: 20.0, finalGrade: nil, dueDate: Date()) //worth 20% of final grade
        XCTAssertNil(testCourse.targetGrade) //targetGrade returns nil
        
        try testCourse.addSyllabusItem(viewContext: testViewContext, title: "test 2", weight: 40.0, finalGrade: nil, dueDate: Date()) //worth 40% of final grade
        XCTAssertNil(testCourse.targetGrade) //targetGrade returns nil
        
        try testCourse.addSyllabusItem(viewContext: testViewContext, title: "quiz 1", weight: 15.0, finalGrade: nil, dueDate: Date()) //worth 15% of final grade
        XCTAssertNil(testCourse.targetGrade) //targetGrade returns nil
        
        try testCourse.addSyllabusItem(viewContext: testViewContext, title: "quiz 2", weight: 25.0, finalGrade: nil, dueDate: Date()) //worth 25% of final grade
        XCTAssertNotNil(testCourse.targetGrade) //targetGrade is now not nil; sufficient items
        
        XCTAssertEqual((testCourse.syllabusItems?.allObjects ?? []).count, 4) //there are four syllabus items
        XCTAssertEqual(testCourse.totalCoursePoints, 100.0) //the syllabus items make up the full final grade
        XCTAssertEqual(testCourse.goalGrade, 85.0) //the goal grade is set
        XCTAssertEqual(testCourse.totalPointsAchieved, 0) //no final grades given, thus no points achieved
        XCTAssertEqual(testCourse.totalPointsCompleted, 0) //no final grades given, thus no items completed
        XCTAssertEqual(testCourse.targetGrade, 85.0) //since no final grades given, the target grade is the same as the goal grade
    }
    
    
    //test that the target grade is correctly calculated when 100% of final grade is accounted for by syllabus item weights, when some, and all final grades have been assigned
    func testTargetGrade_SufficientItems_WithFinalGrades() throws {
        //these four syllabus items' weights total 100% of final grade
        //given 70% final grade
        try testCourse.addSyllabusItem(viewContext: testViewContext, title: "test 1", weight: 20.0, finalGrade: 70.0, dueDate: Date()) //worth 20% of final grade
        XCTAssertNil(testCourse.targetGrade) //targetGrade returns nil
        
        try testCourse.addSyllabusItem(viewContext: testViewContext, title: "test 2", weight: 40.0, finalGrade: nil, dueDate: Date()) //worth 40% of final grade
        XCTAssertNil(testCourse.targetGrade) //targetGrade returns nil
        
        //given 90% final grade
        try testCourse.addSyllabusItem(viewContext: testViewContext, title: "quiz 1", weight: 15.0, finalGrade: 90.0, dueDate: Date()) //worth 15% of final grade
        XCTAssertNil(testCourse.targetGrade) //targetGrade returns nil
        
        try testCourse.addSyllabusItem(viewContext: testViewContext, title: "quiz 2", weight: 25.0, finalGrade: nil, dueDate: Date()) //worth 25% of final grade
        XCTAssertNotNil(testCourse.targetGrade) //targetGrade is now not nil; sufficient items
        
        //preliminary
        XCTAssertEqual((testCourse.syllabusItems?.allObjects ?? []).count, 4) //there are four syllabus items
        XCTAssertEqual(testCourse.totalCoursePoints, 100.0) //the syllabus items make up the full final grade
        XCTAssertEqual(testCourse.totalPointsCompleted, 35.0) //a syllabus item worth 20%, and one worth 15%, were given final grades, 35% of the course has been "completed"
        XCTAssertEqual(testCourse.goalGrade, 85.0) //the goal grade is set
        
        //the number of points achieved (percentage of final grade achieved) by the two syllabus items assigned a final grade
        let pointsFromTest1 = 20 * 0.7 //test 1 is worth 20% of final grade, multiplied by the final grade of 70% on the test
        let pointsFromQuiz1 = 15 * 0.9 //quiz 1 is worth 15% of final grade, multiplied by the final grade of 90% on the quiz
        
        XCTAssertEqual(testCourse.totalPointsAchieved, pointsFromTest1 + pointsFromQuiz1) //achieved percentage should reflect points from syllabus items given a final grade
        //the correct target grade should be calculated as the goal grade minus points achieved,  divided by the remaining points in the course to be accounted for (the total percent of syllabus items not yet graded/completed)
        let pointsToAchieveForGoal =  testCourse.goalGrade - testCourse.totalPointsAchieved
        let pointsLeftToComplete = testCourse.totalCoursePoints - testCourse.totalPointsCompleted
        let correctTargetGrade = (pointsToAchieveForGoal/pointsLeftToComplete) * 100
        XCTAssertEqual(testCourse.targetGrade, correctTargetGrade) //computes the correct target grade for remaining syllabus items
    }
    
    //test target grade when bonus syllabus items are added to the course (all items together make up OVER 100% of final grade), and NONE of the items have been assigned grades
    func testTargetGrade_BonusItems_NoneGraded() throws {
        
    }
    
    //test target grade when bonus syllabus items are added to the course (all items together make up OVER 100% of final grade), and some of the items have been assigned grades
    func testTargetGrade_BonusItems_SomeGraded() throws {
        //these five syllabus items' weights total 110% of final grade -- one of the items is a "bonus" marks syllabus item

        //given 60% final grade
        try testCourse.addSyllabusItem(viewContext: testViewContext, title: "test 1", weight: 20.0, finalGrade: 60.0, dueDate: Date())
        XCTAssertNil(testCourse.targetGrade) //targetGrade returns nil
        
        try testCourse.addSyllabusItem(viewContext: testViewContext, title: "test 2", weight: 40.0, finalGrade: nil, dueDate: Date())
        XCTAssertNil(testCourse.targetGrade) //targetGrade returns nil
        
        try testCourse.addSyllabusItem(viewContext: testViewContext, title: "quiz 1", weight: 15.0, finalGrade: nil, dueDate: Date())
        XCTAssertNil(testCourse.targetGrade) //targetGrade returns nil
        //given 90% final grade
        try testCourse.addSyllabusItem(viewContext: testViewContext, title: "quiz 2", weight: 25.0, finalGrade: 90.0, dueDate: Date())
        XCTAssertNotNil(testCourse.targetGrade) //targetGrade is now not nil; sufficient items
        
        //the bonus 10%
        try testCourse.addSyllabusItem(viewContext: testViewContext, title: "bonus item", weight: 10.0, finalGrade: nil, dueDate: Date())
        XCTAssertNotNil(testCourse.targetGrade) //targetGrade is not nil; sufficient items
        
        //preliminary
        XCTAssertEqual((testCourse.syllabusItems?.allObjects ?? []).count, 5) //there are five syllabus items
        XCTAssertEqual(testCourse.totalCoursePoints, 110.0) //the syllabus items make up the full final grade PLUS 10 bonus percent
        XCTAssertEqual(testCourse.totalPointsCompleted, 45.0) //a syllabus item worth 20%, and one worth 45%, were given final grades, 45% of the course has been "completed"
        XCTAssertEqual(testCourse.goalGrade, 85.0) //the goal grade is set
        
        //the number of points achieved (percentage of final grade achieved) by the two syllabus items assigned a final grade
        let pointsFromTest1 = ((20/testCourse.totalCoursePoints) * 100) * 0.6 //test 1 is worth 18.18% of final grade, multiplied by the final grade of 60% on the test
        let pointsFromQuiz1 = ((25/testCourse.totalCoursePoints) * 100) * 0.9 //quiz 1 is worth 22.73% of final grade, multiplied by the final grade of 90% on the quiz
        XCTAssertEqual(testCourse.totalPointsAchieved, pointsFromTest1 + pointsFromQuiz1) //achieved percentage should reflect points from syllabus items given a final grade
        
        //the correct target grade should be calculated as the goal grade minus points achieved,  divided by the remaining points in the course to be accounted for (the total percent of syllabus items not yet graded/completed)
        let pointsToAchieveForGoal =  testCourse.goalGrade - testCourse.totalPointsAchieved
        let pointsLeftToComplete = testCourse.totalCoursePoints - testCourse.totalPointsCompleted
        let correctTargetGrade = (pointsToAchieveForGoal/pointsLeftToComplete) * 100
        XCTAssertEqual(testCourse.targetGrade, correctTargetGrade) //computes the correct target grade for remaining syllabus items
    }
    
    //test target grade when goal grade is changed from original, with none of the syllabus items graded
    func testTargetGrade_NewGoal_NoneGraded() throws {
        //preliminary
        XCTAssertTrue((testCourse.syllabusItems?.allObjects ?? []).isEmpty) // no syllabus items
        XCTAssertEqual(testCourse.totalCoursePoints, 0) // no points (b/c no syllabus items)
        XCTAssertEqual(testCourse.totalPointsCompleted, 0) //no items to give grades
        XCTAssertNil(testCourse.targetGrade) //target grade nil
        XCTAssertEqual(testCourse.totalPointsAchieved, 0)
        
        XCTAssertEqual(testCourse.goalGrade, 85.0) //the goal grade is set at 85%
        
        //now add syllabus items that worth totals >= 100% so that the target grade returns a non-nil value
        //all initially ungraded
        try testCourse.addSyllabusItem(viewContext: testViewContext, title: "test 1", weight: 20.0, finalGrade: nil, dueDate: Date())
        XCTAssertNil(testCourse.targetGrade) //targetGrade returns nil
        
        try testCourse.addSyllabusItem(viewContext: testViewContext, title: "test 2", weight: 40.0, finalGrade: nil, dueDate: Date())
        XCTAssertNil(testCourse.targetGrade) //targetGrade returns nil
        
        try testCourse.addSyllabusItem(viewContext: testViewContext, title: "quiz 1", weight: 15.0, finalGrade: nil, dueDate: Date())
        XCTAssertNil(testCourse.targetGrade) //targetGrade returns nil

        try testCourse.addSyllabusItem(viewContext: testViewContext, title: "quiz 2", weight: 25.0, finalGrade: nil, dueDate: Date())
        XCTAssertNotNil(testCourse.targetGrade) //targetGrade is now not nil; sufficient items
        
        //since the weights of above syllabus items total 100%, the target grade should now return 85% (since none of the items are graded)
        XCTAssertEqual((testCourse.syllabusItems?.allObjects ?? []).count, 4) // four syllabus items
        XCTAssertEqual(testCourse.totalCoursePoints, 100) // the four syllabus items' worth total 100%
        XCTAssertEqual(testCourse.totalPointsCompleted, 0) //no items have been graded
        XCTAssertEqual(testCourse.totalPointsAchieved, 0) //no items have been graded
        XCTAssertEqual(testCourse.targetGrade, 85) //target grade now equal to goal grade
        
        //now if the goal is changed, the target grade should reflect that
        try testCourse.setGoalGrade(75)
        XCTAssertEqual(testCourse.goalGrade, 75) //goal grade is now 75%
        XCTAssertEqual(testCourse.targetGrade, 75) //target grade is adjusted to 75%
    }
    
    //test target grade when goal grade is changed from original, with some of the syllabus items having been graded
    func testTargetGrade_NewGoal_SomeGraded() throws {
        
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
    
    //test target grade when a final grade previously added to a syllabus item is removed
    func testTargetGrade_ItemFinalGradeRemoved() throws {
        
    }
}
