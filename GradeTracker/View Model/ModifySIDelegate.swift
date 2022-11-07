//
//  ModifySIDelegate.swift
//  GradeTracker
//
//  Created by Katharine on 2022-11-06.
//

import Foundation

protocol ModifySIDelegate {
    func adjustWeight(weight: Double)
    func adjustFinalGrade(finalGrade: Double)
}
