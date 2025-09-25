//
//  FormatTests.swift
//  MovieQuiz
//
//  Created by Yury Semenyushkin on 20.09.25.
//

import XCTest
@testable import MovieQuiz

final class FormatTests: XCTestCase {
    func testAccuracyFormat() {
        let accuracy: Double = 0.7567
        let formatted = String(format: "%.2f%%", accuracy * 100)
        XCTAssertEqual(formatted, "75.67%")
    }
}
