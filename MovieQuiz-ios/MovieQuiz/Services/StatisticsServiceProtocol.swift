//
//  StatisticsServiceProtocol.swift
//  MovieQuiz
//
//  Created by Yury Semenyushkin on 09.09.25.
//

import Foundation

protocol StatisticsServiceProtocol {
    var gamesCount: Int { get }
    var bestGame: GameResult { get }
    var totalAccuracy: Double { get }
    
    func store(correct count: Int, total amount: Int)
}

struct GameResult {
    let correct: Int
    let total: Int
    let date: Date

    func isBetterThan(_ another: GameResult) -> Bool {
        let selfAccuracy = total > 0 ? Double(correct) / Double(total) : -1
        let otherAccuracy = another.total > 0 ? Double(another.correct) / Double(another.total) : -1
        return selfAccuracy > otherAccuracy
    }
}
