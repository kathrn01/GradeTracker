//
//  GradeTrackerTests.swift
//  GradeTrackerTests
//
//  Created by Katharine K
//

import XCTest
@testable import GradeTracker

class TermTests: XCTestCase {
    //this is the preview context that will be used to instantiate core data objects
    //all objects created in the tests will be destroyed at the end
    let testViewContext = PersistenceController.preview.container.viewContext

//    override func setUpWithError() throws {
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//    }

    override func tearDownWithError() throws {
        //delete all objects created and saved before next test method
        testViewContext.registeredObjects.forEach({ testViewContext.delete($0) })
        try testViewContext.save()
    }

    func testTerm() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

}
