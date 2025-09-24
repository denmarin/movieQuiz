//
//  StatisticsService.swift
//  MovieQuiz
//
//  Created by Yury Semenyushkin on 09.09.25.
//

import Foundation

class StatisticsService: StatisticsServiceProtocol {

    private let ud = UserDefaults.standard
    
    private var totalCorrectAnswers: Int {
        get { ud.integer(forKey: Keys.totalCorrectAnswers.rawValue) }
        set { ud.set(newValue, forKey: Keys.totalCorrectAnswers.rawValue) }
    }

    private var totalQuestionsAsked: Int {
        get { ud.integer(forKey: Keys.totalQuestionsAsked.rawValue) }
        set { ud.set(newValue, forKey: Keys.totalQuestionsAsked.rawValue) }
    }
    
    var gamesCount: Int {
        get {
            ud.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            ud.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            let hasBest = ud.object(forKey: Keys.bestGameDate.rawValue) != nil
            if !hasBest {
                return GameResult(correct: 0, total: 0, date: Date.distantPast)
            }
            let correctAnswers = ud.integer(forKey: Keys.bestGameCorrect.rawValue)
            let questionsInQuiz = ud.integer(forKey: Keys.bestGameTotal.rawValue)
            let date = ud.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
            return GameResult(correct: correctAnswers, total: questionsInQuiz, date: date)
        }
        set {
            ud.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            ud.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            ud.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        let total = totalQuestionsAsked
        guard total > 0 else { return 0 }
        return (Double(totalCorrectAnswers) / Double(total)) * 100.0
    }
    
    func store(correct count: Int, total amount: Int) {
        
        totalCorrectAnswers += count
        totalQuestionsAsked += amount
        gamesCount += 1

        
        let newResult = GameResult(correct: count, total: amount, date: Date())
        let currentBest = bestGame

        
        let newAccuracy = amount > 0 ? Double(count) / Double(amount) : 0
        let bestAccuracy = currentBest.total > 0 ? Double(currentBest.correct) / Double(currentBest.total) : -1

        if newAccuracy > bestAccuracy {
            bestGame = newResult
        }
    }
    
    private enum Keys: String {
        case gamesCount
        case bestGameCorrect
        case bestGameTotal
        case bestGameDate
        case totalCorrectAnswers
        case totalQuestionsAsked
    }
    
}

