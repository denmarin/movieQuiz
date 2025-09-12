//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Yury Semenyushkin on 09.09.25.
//

import Foundation

protocol StatisticServiceProtocol {
    var gamesCount: Int { get }
    var bestGame: GameResult { get }
    var totalAccuracy: Double { get }
    
    func store(correct count: Int, total amount: Int)
}

struct GameResult {
    let correct: Int
    let total: Int
    let date: Date
    
    private func isBetterThan(_ another: GameResult) -> Bool {
            correct > another.correct
        }
}
