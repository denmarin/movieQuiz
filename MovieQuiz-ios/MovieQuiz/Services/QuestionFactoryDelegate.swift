//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Yury Semenyushkin on 02.09.25.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}
