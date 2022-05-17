//
//  ErrorDefinitions.swift
//  GradeTracker
//
//  Created by Katharine K
//

import Foundation

//defining errors for error handling for our main classes (Term, Course, SyllabusItem)
enum InvalidPropertySetter: Error {
    case titleEmpty
    case titleWhitespaces
    case negativeValue
}

//if a date range is given for a term, the start and end dates must be chronologically correct
enum InvalidDateRange: Error {
    case startAfterEnd
    case endBeforeStart
}
