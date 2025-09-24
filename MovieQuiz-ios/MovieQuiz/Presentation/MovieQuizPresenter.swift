//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Yury Semenyushkin on 24.09.25.
//

import UIKit

final class MovieQuizPresenter {
    
    let questionsAmount: Int = 10
    var currentQuestionIndex: Int = 0
    var currentQuestion: QuizQuestion?
    weak var VC: MovieQuizViewController?
    
    
    func yesButtonClicked () {
        
        guard let VC = VC else { return }
        guard
            let yesButton = VC.yesButton,
            let noButton = VC.noButton,
            let currentQuestion = currentQuestion
        else { return }
        
        guard yesButton.isEnabled && noButton.isEnabled else { return }
        yesButton.isEnabled = false
        noButton.isEnabled = false
        let givenAnswer = true
        VC.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func noButtonClicked() {
        guard let VC = VC else { return }
        guard
            let yesButton = VC.yesButton,
            let noButton = VC.noButton,
            let currentQuestion = currentQuestion
        else { return }
        
        guard yesButton.isEnabled && noButton.isEnabled else { return }
        yesButton.isEnabled = false
        noButton.isEnabled = false
        let givenAnswer = false
        
        VC.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
        
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
        
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
}
