//
//  QuestionFactoryTests.swift
//  MovieQuiz
//
//  Created by Yury Semenyushkin on 20.09.25.
//

import XCTest
@testable import MovieQuiz

final class QuestionFactoryTests: XCTestCase {
    func testRequestNextQuestionReturnsQuestion() {
        let factory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: nil)

        let question: () = factory.requestNextQuestion()
        XCTAssertNotNil(question)
    }
}
