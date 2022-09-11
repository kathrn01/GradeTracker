//
//  CourseTests.swift
//  GradeTrackerTests
//
//  Created by Katharine K
//
// This test class will test the Course class -- mostly it's targetGrade computed variable

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
        
        testTerm = try Term(viewContext: testViewContext, title: "testTerm", start: Date(), end: Calendar.current.date(byAdding: dateComponent, to: Date()), currGPA: nil, goalGPA: nil, markerColour: [0,0,0])
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

    /* -------------- TARGET GRADE TESTS  --------------
     Mostly testing how attributes totalCoursePoints, totalPointsAchieved, and totalPointsCompleted, and computed variable targetGrade respond to changes in syllabus items
     totalCoursePoints is the weights of all syllabus items added up (must be >= 100 to calculate target grades)
     totalPointsAchieved is the points from all final grades given to syllabus items in the course
     totalPointsCompleted is all the weights from completed (given final grade) syllabus items in the course
     
     these attributes are used to calculate the target grade.
     */
    
    
    
    //test how the target grade is computed when there are no syllabus items added to the course
    func testTargetGrade_NoSyllabusItems() throws {
        //when there are no syllabus items, the target grade should return nil (not enough data)
        XCTAssertTrue((testCourse.syllabusItems?.allObjects ?? []).isEmpty) //the course has no syllabus items
        XCTAssertEqual(testCourse.goalGrade, 85.0) //the goal grade is set
        XCTAssertNil(testCourse.targetGrade) //target grade returns nil
        XCTAssertEqual(testCourse.totalCoursePoints, 0) //no course points
        XCTAssertEqual(testCourse.totalPointsCompleted, 0) //no points completed
        XCTAssertEqual(testCourse.totalPointsAchieved, 0) //no points achieved
    }
    
    //test target grade when there are not enough syllabus items added (all items together do not make up 100% of final grade)
    func testTargetGrade_InsufficientItems() throws {
        //add a syllabus item worth 10% of the final course grade
        try testCourse.addSyllabusItem(viewContext: testViewContext, title: "test1", weight: 10.0, finalGrade: nil, dueDate: Date())
        XCTAssertEqual((testCourse.syllabusItems?.allObjects ?? []).count, 1) //there is one syllabus item in testCourse
        XCTAssertEqual(testCourse.totalCoursePoints, 10.0) //there are 10 points accounted for (10% of total grade)
        XCTAssertNil(testCourse.targetGrade) //targetGrade returns nil
        
        //add a syllabus item worth 50% of the final course grade, with a final grade
        try testCourse.addSyllabusItem(viewContext: testViewContext, title: "test 2", weight: 50.0, finalGrade: nil, dueDate: Date())
        XCTAssertEqual((testCourse.syllabusItems?.allObjects ?? []).count, 2) //there are two syllabus items in testCourse
        
        
        XCTAssertEqual(testCourse.goalGrade, 85.0) //goal grade has been set for the course
        XCTAssertEqual(testCourse.totalCoursePoints, 60.0) //there are 60 points accounted for (60% of total grade)
        XCTAssertEqual(testCourse.totalPointsCompleted, 0) //no items, so can't have any completed
        XCTAssertEqual(testCourse.totalPointsAchieved, 0) //no points achieved as no final grades were given to items
        XCTAssertNil(testCourse.targetGrade) //targetGrade returns nil, weights of syllabus items < 100
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
        XCTAssertEqual(testCourse.goalGrade, 85.0) //the goal grade is set
        XCTAssertEqual(testCourse.totalCoursePoints, 100.0) //the syllabus items make up the full final grade
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
        let totalLeftToAchieve =  testCourse.goalGrade - testCourse.totalPointsAchieved //goal grade - points achieved
        let totalLeftToComplete = testCourse.totalCoursePoints - testCourse.totalPointsCompleted //total possible points in course - points completed (sum of weights of items given final grade)
        let correctTargetGrade = (totalLeftToAchieve/totalLeftToComplete) * 100
        XCTAssertEqual(testCourse.targetGrade, correctTargetGrade) //computes the correct target grade for remaining syllabus items
    }
    
    //test the course when all items (making up >= 100% of grade) have been assigned a final grade
    //ie. the final grade for the course has been achieved
    func testAllItemsGraded() throws {
        //assign all syllabus items a grade, where the weights of all syllabus items >= 100%
        try testCourse.addSyllabusItem(viewContext: testViewContext, title: "s1", weight: 25.0, finalGrade: 85, dueDate: Date())
        try testCourse.addSyllabusItem(viewContext: testViewContext, title: "s2", weight: 25.0, finalGrade: 75, dueDate: Date())
        try testCourse.addSyllabusItem(viewContext: testViewContext, title: "s3", weight: 15.0, finalGrade: 65, dueDate: Date())
        try testCourse.addSyllabusItem(viewContext: testViewContext, title: "s4", weight: 15.0, finalGrade: 95, dueDate: Date())
        try testCourse.addSyllabusItem(viewContext: testViewContext, title: "s5", weight: 20.0, finalGrade: 70, dueDate: Date())
        XCTAssertEqual(testCourse.totalCoursePoints, 100)
        XCTAssertEqual(testCourse.totalPointsCompleted, 100)
        let finalGrade = (0.85 * 25) + (0.75 * 25) + (0.65 * 15) + (0.95 * 15) + (0.7 * 20) //add up all item grades multiplied by their weight in the course to obtain the points achieved towards the final grade
        XCTAssertEqual(testCourse.totalPointsAchieved, finalGrade)
    }
    
    //test target grade when bonus syllabus items are added to the course (all items together make up OVER 100% of final grade), and NONE of the items have been assigned grades
    func testTargetGrade_BonusItems_NoneGraded() throws {
        //these five syllabus items' weights total 110% of final grade -- one of the items is a "bonus" marks syllabus item
        try testCourse.addSyllabusItem(viewContext: testViewContext, title: "test 1", weight: 20.0, finalGrade: nil, dueDate: Date())
        XCTAssertNil(testCourse.targetGrade) //targetGrade returns nil
        
        try testCourse.addSyllabusItem(viewContext: testViewContext, title: "test 2", weight: 40.0, finalGrade: nil, dueDate: Date())
        XCTAssertNil(testCourse.targetGrade) //targetGrade returns nil
        
        try testCourse.addSyllabusItem(viewContext: testViewContext, title: "quiz 1", weight: 15.0, finalGrade: nil, dueDate: Date())
        XCTAssertNil(testCourse.targetGrade) //targetGrade returns nil

        try testCourse.addSyllabusItem(viewContext: testViewContext, title: "quiz 2", weight: 25.0, finalGrade: nil, dueDate: Date())
        XCTAssertNotNil(testCourse.targetGrade) //targetGrade is now not nil; sufficient items
        
        //the bonus 10%
        try testCourse.addSyllabusItem(viewContext: testViewContext, title: "bonus item", weight: 10.0, finalGrade: nil, dueDate: Date())
        XCTAssertNotNil(testCourse.targetGrade) //targetGrade is not nil; sufficient items
        
        //preliminary
        XCTAssertEqual((testCourse.syllabusItems?.allObjects ?? []).count, 5) //there are five syllabus items
        XCTAssertEqual(testCourse.totalCoursePoints, 110.0) //the syllabus items make up the full final grade PLUS 10 bonus percent
        XCTAssertEqual(testCourse.totalPointsCompleted, 0) //since none are graded, there have been no points completed
        XCTAssertEqual(testCourse.totalPointsAchieved, 0)
        XCTAssertEqual(testCourse.goalGrade, 85.0) //the goal grade is set
        
        //the correct target grade should be calculated as the goal grade minus points achieved,  divided by the remaining points in the course to be accounted for (the total percent of syllabus items not yet graded/completed)
        let pointsToAchieveForGoal =  testCourse.goalGrade - testCourse.totalPointsAchieved //85 - 0 = 85
        let pointsLeftToComplete = testCourse.totalCoursePoints - testCourse.totalPointsCompleted //110 - 0 = 110
        let correctTargetGrade = (pointsToAchieveForGoal/pointsLeftToComplete) * 100 //85/110 = 0.773 * 100 = 77.3 %
        
        /* notice that the correct target grade here is lower than the goal grade, even though no items have yet been graded ...
         this is because of the bonus item. With the bonus item, the number of points that need to be achieved to meet the goal grade are spread accross more syllabus items (110% rather than 100%) and so lowers the target grade for each item.
         This is with the assumption that the student will complete the bonus item. */
        XCTAssertEqual(testCourse.targetGrade, correctTargetGrade) //computes the correct target grade for remaining syllabus items
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
        let pointsFromTest1 = 20 * 0.6
        let pointsFromQuiz1 = 25 * 0.9
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
        XCTAssertEqual(testCourse.targetGrade, 75) //target grade is adjusted to 75% for all syllabus items
    }
    
    //test target grade when goal grade is changed from original, with some of the syllabus items having been graded
    func testTargetGrade_NewGoal_SomeGraded() throws {
        //preliminary
        XCTAssertTrue((testCourse.syllabusItems?.allObjects ?? []).isEmpty) // no syllabus items
        XCTAssertEqual(testCourse.totalCoursePoints, 0) // no points (b/c no syllabus items)
        XCTAssertEqual(testCourse.totalPointsCompleted, 0) //no items to give grades
        XCTAssertNil(testCourse.targetGrade) //target grade nil
        XCTAssertEqual(testCourse.totalPointsAchieved, 0)
        
        XCTAssertEqual(testCourse.goalGrade, 85.0) //the goal grade is set at 85%
        
        //now add syllabus items that worth totals >= 100% so that the target grade returns a non-nil value
        
        //graded 90%
        try testCourse.addSyllabusItem(viewContext: testViewContext, title: "test 1", weight: 20.0, finalGrade: 90.0, dueDate: Date())
        XCTAssertNil(testCourse.targetGrade) //targetGrade returns nil
        
        try testCourse.addSyllabusItem(viewContext: testViewContext, title: "test 2", weight: 40.0, finalGrade: nil, dueDate: Date())
        XCTAssertNil(testCourse.targetGrade) //targetGrade returns nil
        
        //graded 70%
        try testCourse.addSyllabusItem(viewContext: testViewContext, title: "quiz 1", weight: 15.0, finalGrade: 70.0, dueDate: Date())
        XCTAssertNil(testCourse.targetGrade) //targetGrade returns nil

        try testCourse.addSyllabusItem(viewContext: testViewContext, title: "quiz 2", weight: 25.0, finalGrade: nil, dueDate: Date())
        XCTAssertNotNil(testCourse.targetGrade) //targetGrade is now not nil; sufficient items
        
        //since the weights of above syllabus items total 100%, the target grade should now return 85% (since none of the items are graded)
        XCTAssertEqual((testCourse.syllabusItems?.allObjects ?? []).count, 4) // four syllabus items
        XCTAssertEqual(testCourse.totalCoursePoints, 100) // the four syllabus items' worth total 100%
        XCTAssertEqual(testCourse.totalPointsCompleted, 35) //two items have been graded, one worth 20% and the other worth 15%
        
        //the number of points achieved (percentage of final grade achieved) by the two syllabus items assigned a final grade
        let pointsFromTest1 = 20 * 0.9
        let pointsFromQuiz1 = 15 * 0.7
        XCTAssertEqual(testCourse.totalPointsAchieved, pointsFromTest1 + pointsFromQuiz1) //achieved percentage should reflect points from syllabus items given a final grade
        
        //the target grade with current goal grade (85%)
        //the correct target grade should be calculated as the goal grade minus points achieved,  divided by the remaining points in the course to be accounted for (the total percent of syllabus items not yet graded/completed)
        let pointsToAchieveForGoal =  testCourse.goalGrade - testCourse.totalPointsAchieved //85 - 28.5 = 56.5
        let pointsLeftToComplete = testCourse.totalCoursePoints - testCourse.totalPointsCompleted // 100 - 35 = 65
        let correctTargetGrade = (pointsToAchieveForGoal/pointsLeftToComplete) * 100 // 56.5/65 * 100 = 86.9%
        XCTAssertEqual(testCourse.targetGrade, correctTargetGrade) //the correct target grade for goal of 85% should be 86.9% as calculated above
        
        //now if the goal is changed, the target grade should reflect that
        try testCourse.setGoalGrade(75)
        XCTAssertEqual(testCourse.goalGrade, 75) //goal grade is now 75%
        
        //target grade with new goal of 75%
        let pointsToAchieveForNewGoal =  testCourse.goalGrade - testCourse.totalPointsAchieved //75 - 28.5 = 46.5
        let pointsLeftToCompleteNew = testCourse.totalCoursePoints - testCourse.totalPointsCompleted // 100 - 35 = 65 (unchanged)
        let correctTargetGradeNew = (pointsToAchieveForNewGoal/pointsLeftToCompleteNew) * 100 // 46.5/65 * 100 = 71.5%
        XCTAssertEqual(testCourse.targetGrade, correctTargetGradeNew) //the correct target grade for goal of 75% should be 71.5% as calculated above
    }
    
    //test the target grade when syllabus items are removed from the course
    func testTargetGrade_RemoveItems_AddRedoItem() throws {
        /* ------------- from 110% to 100% -- target grade will adjust ------------- */
        //given 60% final grade
        let test1 = try SyllabusItem(viewContext: testViewContext, course: testCourse, title: "test 1", weight: 20.0, grade: 60.0, dueDate: Date())
        testCourse.addToSyllabusItems(test1)
        XCTAssertNil(testCourse.targetGrade) //targetGrade returns nil
        
        try testCourse.addSyllabusItem(viewContext: testViewContext, title: "test 2", weight: 40.0, finalGrade: nil, dueDate: Date())
        XCTAssertNil(testCourse.targetGrade) //targetGrade returns nil
        
        try testCourse.addSyllabusItem(viewContext: testViewContext, title: "quiz 1", weight: 15.0, finalGrade: nil, dueDate: Date())
        XCTAssertNil(testCourse.targetGrade) //targetGrade returns nil
        //given 90% final grade
        try testCourse.addSyllabusItem(viewContext: testViewContext, title: "quiz 2", weight: 25.0, finalGrade: 90.0, dueDate: Date())
        XCTAssertNotNil(testCourse.targetGrade) //targetGrade is now not nil; sufficient items
        
        //the bonus 10%
        let bonusItem = try SyllabusItem(viewContext: testViewContext, course: testCourse, title: "bonus item", weight: 10.0, grade: nil, dueDate: Date())
        testCourse.addToSyllabusItems(bonusItem)
        XCTAssertNotNil(testCourse.targetGrade) //targetGrade is not nil; sufficient items
        
        //preliminary
        XCTAssertEqual((testCourse.syllabusItems?.allObjects ?? []).count, 5) //there are five syllabus items
        XCTAssertEqual(testCourse.totalCoursePoints, 110.0) //the syllabus items make up the full final grade PLUS 10 bonus percent
        XCTAssertEqual(testCourse.totalPointsCompleted, 45.0) //a syllabus item worth 20%, and one worth 45%, were given final grades, 45% of the course has been "completed"
        XCTAssertEqual(testCourse.goalGrade, 85.0) //the goal grade is set
        
        //the number of points achieved (percentage of final grade achieved) by the two syllabus items assigned a final grade
        let pointsFromTest1 = 20 * 0.6 //12
        let pointsFromQuiz2 = 25 * 0.9 //22.5
        XCTAssertEqual(testCourse.totalPointsAchieved, pointsFromTest1 + pointsFromQuiz2) //achieved percentage should reflect points from syllabus items given a final grade
        
        //the correct target grade should be calculated as the goal grade minus points achieved,  divided by the remaining points in the course to be accounted for (the total percent of syllabus items not yet graded/completed)
        var pointsToAchieveForGoal =  testCourse.goalGrade - testCourse.totalPointsAchieved //85 - 34.5 = 50.5
        var pointsLeftToComplete = testCourse.totalCoursePoints - testCourse.totalPointsCompleted //110 - 45 = 65
        let correctTargetGrade = (pointsToAchieveForGoal/pointsLeftToComplete) * 100
        XCTAssertEqual(correctTargetGrade, (50.5/65) * 100)
        XCTAssertEqual(testCourse.targetGrade, correctTargetGrade) //computes the correct target grade for remaining syllabus items
        
        /* Now remove the bonus item -- making the totalCoursePoints 100 instead of 110 */
        testCourse.removeSyllabusItem(bonusItem) //bonus item removed
        XCTAssertEqual((testCourse.syllabusItems?.allObjects ?? []).count, 4) //there are now four syllabus items
        XCTAssertEqual(testCourse.totalCoursePoints, 100.0) //the syllabus items make up the full final grade, no more
        XCTAssertEqual(testCourse.totalPointsCompleted, 45.0) //a syllabus item worth 20%, and one worth 45%, were given final grades, 45% of the course has been "completed"
        XCTAssertEqual(testCourse.totalPointsAchieved, pointsFromTest1 + pointsFromQuiz2) //remains same, as the bonus item removed wasn't given a final grade/no points achieved
        
        //the new target grade is not equal to the old target grade, since the extra 10% achievable has been removed
        pointsToAchieveForGoal =  testCourse.goalGrade - testCourse.totalPointsAchieved //unchanged
        pointsLeftToComplete = testCourse.totalCoursePoints - testCourse.totalPointsCompleted // 100 - 45 = 55
        let correctTargetGradeNew = (pointsToAchieveForGoal/pointsLeftToComplete) * 100
        XCTAssertEqual(correctTargetGradeNew, (50.5/55) * 100)
        XCTAssertEqual(testCourse.targetGrade, correctTargetGradeNew) //computes the correct new target grade for remaining syllabus items
        XCTAssertNotEqual(correctTargetGrade, correctTargetGradeNew) //not equal to the old one
        
        /* ------------- from 100% to insufficient items -- target grade will return nil ------------- */
        XCTAssertEqual(testCourse.totalCoursePoints, 100)
        testCourse.removeSyllabusItem(test1) //remove test 1 from the course
        //this removes 20 points from totalCoursePoints, which will make it a total of 80 -- targetGrade should now return nil
        XCTAssertNil(testCourse.targetGrade)
        XCTAssertEqual(testCourse.totalCoursePoints, 80)
        XCTAssertEqual(testCourse.totalPointsCompleted, 25.0) //only quiz 2 is completed now
        XCTAssertEqual(testCourse.totalPointsAchieved, pointsFromQuiz2)
        
        //Now if item added to bring total course points back to 100
        let redoTest1 = try SyllabusItem(viewContext: testViewContext, course: testCourse, title: "redoTest1", weight: 20.0, grade: 80.0, dueDate: Date())
        testCourse.addToSyllabusItems(redoTest1)
        
        XCTAssertEqual(testCourse.totalCoursePoints, 100) //back at 100
        XCTAssertEqual(testCourse.totalPointsCompleted, 45)
        let pointsAchievedRedo = 0.8 * 20 // 16
        XCTAssertEqual(testCourse.totalPointsAchieved, pointsFromQuiz2 + pointsAchievedRedo) // 22.5 + 16 = 38.5
        
        //new target grade
        let totalLeftToComplete = testCourse.totalCoursePoints - testCourse.totalPointsCompleted // 100 - 45 = 55
        let totalLeftToAchieve = testCourse.goalGrade - testCourse.totalPointsAchieved //85 - 38.5 = 46.5
        let newTarg = (totalLeftToAchieve/totalLeftToComplete) * 100 //84.5
        XCTAssertEqual(testCourse.targetGrade, newTarg)
        
    }
    
    //test target grade when the weight of syllabus items are modified from original
    func testTargetGrade_ItemWeightChange() throws {
        let syllItem1 = try SyllabusItem(viewContext: testViewContext, course: testCourse, title: "s1", weight: 50.0, grade: 75.0, dueDate: Date())
        testCourse.addToSyllabusItems(syllItem1)
        try testCourse.addSyllabusItem(viewContext: testViewContext, title: "s2", weight: 20, finalGrade: 90, dueDate: Date())
        try testCourse.addSyllabusItem(viewContext: testViewContext, title: "s3", weight: 30, finalGrade: 78, dueDate: Date())
        try testCourse.addSyllabusItem(viewContext: testViewContext, title: "bonus", weight: 10, finalGrade: nil, dueDate: Date())
        
        //preliminary
        XCTAssertEqual((testCourse.syllabusItems?.allObjects ?? []).count, 4) //there are four syllabus items
        XCTAssertEqual(testCourse.totalCoursePoints, 110.0) //the syllabus items make up the full final grade PLUS 10 bonus percent
        XCTAssertEqual(testCourse.totalPointsCompleted, 100.0) //the course has been completed except for the bonus grade
        XCTAssertEqual(testCourse.goalGrade, 85.0) //the goal grade is set at 85%
        
        //the current target grade for the bonus item is:
        let totalPointsAchieved = (0.75 * 50) + (0.90 * 20) + (0.78 * 30) // = 78.9 %
        XCTAssertEqual(testCourse.totalPointsAchieved, 78.9)
        XCTAssertEqual(testCourse.totalPointsAchieved, totalPointsAchieved)
        let pointsToAchieveForGoal =  testCourse.goalGrade - testCourse.totalPointsAchieved //85 - 78.9 = 6.1% -- how much must be achieved to reach goal
        let pointsLeftToComplete = testCourse.totalCoursePoints - testCourse.totalPointsCompleted // 110 - 100 = 10% possible points left
        let correctTargetGrade = round((pointsToAchieveForGoal/pointsLeftToComplete) * 100) //this will give 61% as the correct target grade for the remaining bonus item
        XCTAssertEqual(correctTargetGrade, 61)
        XCTAssertEqual(round(testCourse.targetGrade!), correctTargetGrade) //computes the correct target grade for remaining syllabus items
        
        //NOW if the weight of syllItem1, for example, is changed from 50% to 40% of the final grade, then the totalCoursePoints will change from 110 to 100, making the "bonus" syllabus item not really a bonus anymore.
        // the target grade will be adjusted accordingly
        try syllItem1.setWeight(40.0)
        XCTAssertEqual(syllItem1.weight, 40.0) //syllItem1's new weight is 40
        XCTAssertEqual(testCourse.totalCoursePoints, 100) //testCourse now has 100 possible points/percent
        XCTAssertEqual(testCourse.totalPointsCompleted, 90) //now only 90% of the course has been achieved
        
        //check that the target grade has been adjusted accordingly
        let totalPointsAchievedNew = (0.75 * 40) + (0.90 * 20) + (0.78 * 30) // adjusted for syllItem1's new weight -- 71.4%
        XCTAssertEqual(testCourse.totalPointsAchieved, 71.4)
        XCTAssertEqual(testCourse.totalPointsAchieved, totalPointsAchievedNew)
        let pointsToAchieveForGoalNew =  testCourse.goalGrade - testCourse.totalPointsAchieved //85 - 71.4 = 13.6%  -- how much must now be achieved to reach goal
        let pointsLeftToCompleteNew = testCourse.totalCoursePoints - testCourse.totalPointsCompleted // 100 - 90 = 10% possible points left
        let correctTargetGradeNew = round((pointsToAchieveForGoalNew/pointsLeftToCompleteNew) * 100) //this will give 136% as the correct target grade for the remaining bonus item
        XCTAssertEqual(correctTargetGradeNew, 136)
        XCTAssertEqual(round(testCourse.targetGrade!), correctTargetGradeNew) //computes the correct target grade for remaining syllabus items
    }
    
    //test target grade when the final grade of syllabus items is changed from original
    //found formula for rounding to correct decimal place here : https://stackoverflow.com/questions/25513357/rounding-in-swift-with-round
    func testTargetGrade_ItemFinalGradeChange() throws {
        let syllItem1 = try SyllabusItem(viewContext: testViewContext, course: testCourse, title: "s1", weight: 50.0, grade: 75.0, dueDate: Date())
        testCourse.addToSyllabusItems(syllItem1)
        try testCourse.addSyllabusItem(viewContext: testViewContext, title: "s2", weight: 20, finalGrade: 90, dueDate: Date())
        try testCourse.addSyllabusItem(viewContext: testViewContext, title: "s3", weight: 30, finalGrade: nil, dueDate: Date())
        
        //preliminary
        XCTAssertEqual((testCourse.syllabusItems?.allObjects ?? []).count, 3) //there are 3 syllabus items
        XCTAssertEqual(testCourse.totalCoursePoints, 100.0) //the syllabus items make up the full final grade
        XCTAssertEqual(testCourse.totalPointsCompleted, 70.0) // 70% of the course has been completed
        XCTAssertEqual(testCourse.goalGrade, 85.0) //the goal grade is set at 85%
        
        //the total percentage achieved towards the final grade, so far
        let totalPointsAchieved = (0.75 * 50) + (0.90 * 20) // = 55.5%
        XCTAssertEqual(totalPointsAchieved, 55.5)
        XCTAssertEqual(testCourse.totalPointsAchieved, totalPointsAchieved)
        
        //the target grade for the incomplete syllabus item is:
        let pointsToAchieveForGoal = testCourse.goalGrade - testCourse.totalPointsAchieved // 85 - 55.5 = 29.5% must be achieved on final syllabus item
        let pointsLeftToComplete = testCourse.totalCoursePoints - testCourse.totalPointsCompleted // 100 - 70 = 30
        let correctTargetGrade = round(10 * ((pointsToAchieveForGoal/pointsLeftToComplete) * 100))/10 // 29.5/30 * 100 = 98.3%
        XCTAssertEqual(correctTargetGrade, 98.3)
        XCTAssertEqual(round( 10 * testCourse.targetGrade!)/10, correctTargetGrade) //correct
        
        
        //NOW if the final grade is changed for syllItem1 -- from 75% to 87%, the target grade should adjust accordingly
        try syllItem1.setFinalGrade(87)
        XCTAssertEqual(syllItem1.finalGrade, 87)
        
        //recalculate total points achieved
        XCTAssertEqual(testCourse.totalPointsCompleted, 70) //the percentage of the course completed doesn't change as a result of a final grade change
        let totalPointsAchievedNew = (0.87 * 50) + (0.9 * 20) //61.5%
        XCTAssertEqual(totalPointsAchievedNew, 61.5)
        XCTAssertEqual(testCourse.totalPointsAchieved, totalPointsAchievedNew)
        
        //target grade is now:
        let pointsToAchieveForGoalNew = testCourse.goalGrade - testCourse.totalPointsAchieved // 85 - 61.5 = 23.5 % must be achieved on final syllabus item
        let pointsLeftToCompleteNew = testCourse.totalCoursePoints - testCourse.totalPointsCompleted // 100 - 70 = 30 (this shouldnt change)
        let correctTargetGradeNew = round(10 * ((pointsToAchieveForGoalNew/pointsLeftToCompleteNew) * 100))/10 //new target grade: 78.3%
        XCTAssertEqual(correctTargetGradeNew, 78.3)
        XCTAssertEqual(round(10 * testCourse.targetGrade!)/10, correctTargetGradeNew)
    }
}
