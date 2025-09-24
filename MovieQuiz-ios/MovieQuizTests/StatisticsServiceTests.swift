//
//  StatisticsServiceTests.swift
//  MovieQuiz
//
//  Created by Yury Semenyushkin on 20.09.25.
//


import XCTest
@testable import MovieQuiz

final class StatisticsServiceTests: XCTestCase {
    override func setUp() {
        super.setUp()
        let ud = UserDefaults.standard
        ud.removeObject(forKey: "gamesCount")
        ud.removeObject(forKey: "bestGameCorrect")
        ud.removeObject(forKey: "bestGameTotal")
        ud.removeObject(forKey: "bestGameDate")
        ud.removeObject(forKey: "totalCorrectAnswers")
        ud.removeObject(forKey: "totalQuestionsAsked")
    }

    func testTotalAccuracyAfterOneGame() {
        // Arrange
        let stats = StatisticsService()

        // Act
        stats.store(correct: 7, total: 10)

        // Assert
        XCTAssertEqual(stats.totalAccuracy, 70.0)
    }
    
    func testTotalAccuracyAfterTwoGames() {
        // Arrange
        let stats = StatisticsService()

        // Act
        stats.store(correct: 6, total: 10) // 60%
        stats.store(correct: 8, total: 10) // 80%

        // Assert
        // Всего правильных = 14, всего вопросов = 20 → 70%
        XCTAssertEqual(stats.totalAccuracy, 70.0)
    }
    
    func testBestGameUpdatesWhenAccuracyIsHigher() {
        let stats = StatisticsService()

        // Первая игра: 5/10 (50%)
        stats.store(correct: 5, total: 10)
        XCTAssertEqual(stats.bestGame.correct, 5)

        // Вторая игра: 9/10 (90%) → должна стать новой лучшей
        stats.store(correct: 9, total: 10)
        XCTAssertEqual(stats.bestGame.correct, 9)
    }
    
    func testBestGameDoesNotUpdateWhenAccuracyIsLower() {
        let stats = StatisticsService()

        stats.store(correct: 8, total: 10) // 80%

        stats.store(correct: 6, total: 10) // 60% → хуже
        XCTAssertEqual(stats.bestGame.correct, 8) // остаётся 8/10
    }
    
}
