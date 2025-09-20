//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Yury Semenyushkin on 02.09.25.
//

import Foundation
@MainActor
protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer() 
    func didFailToLoadData(with error: Error)
}
