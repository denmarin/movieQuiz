//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Yury Semenyushkin on 24.09.25.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    private let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    private var currentQuestion: QuizQuestion?
    private var correctAnswers: Int = 0
    var questionFactory: QuestionFactoryProtocol?
    private var statistics: StatisticsServiceProtocol!
    private weak var VC: MovieQuizViewController?
    
    init(viewController: MovieQuizViewController) {
        self.VC = viewController
        statistics = StatisticsService()
            
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
            
        Task {
            await questionFactory?.loadData()
        }
        VC?.showLoadingState()
    }
    
    // MARK - QuestionFactoryDelegate
    
    func didLoadDataFromServer() {
        questionFactory?.requestNextQuestion()
    }
        
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        VC?.showNetworkError(message: message)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [self] in
            VC!.showContentState()
            VC!.show(quiz: viewModel)
        }
    }
    
    func yesButtonClicked () {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    private func didAnswer(isYes: Bool) {
        guard let VC = VC else { return }
        guard
            let yesButton = VC.yesButton,
            let noButton = VC.noButton,
            let currentQuestion = currentQuestion
        else { return }
        
        guard yesButton.isEnabled && noButton.isEnabled else { return }
        yesButton.isEnabled = false
        noButton.isEnabled = false
        
        let givenAnswer = isYes
        
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func updateCorrectAnswersIf(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
        
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        Task { [weak self] in
            guard let self = self else { return }
            await questionFactory?.loadData()
        }
    }
        
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    private func proceedWithAnswer(isCorrect: Bool) {
        updateCorrectAnswersIf(isCorrect: isCorrect)
        
        VC!.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            proceedToNextQuestionOrResults()
        }
    }
    
    private func proceedToNextQuestionOrResults() {
        guard let VC = VC else { return }
        
        if self.isLastQuestion() {
            
            statistics.store(correct: self.correctAnswers, total: self.questionsAmount)
            
            let best = statistics.bestGame
            
            let df = DateFormatter()
            df.dateFormat = "dd.MM.yy HH:mm"
            
            let accuracy = String(format: "%.2f%%", statistics.totalAccuracy)
            
            let text = """
            Ваш результат: \(self.correctAnswers)/\(self.questionsAmount)
            Количество сыгранных квизов: \(statistics.gamesCount)
            Рекорд: \(best.correct)/\(best.total) (\(df.string(from: best.date)))
            Средняя точность: \(accuracy)
            """
            
            let model = AlertModel(
                title: "Этот раунд окончен!",
                message: text,
                buttonText: "Сыграть ещё раз",
                completion: { [weak self] in
                    guard let self = self else { return }
                    self.restartGame()
                    VC.showLoadingState()
                }
            )
            DispatchQueue.main.async {
                VC.alertPresenter?.present(model: model)
            }
            
            
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
}

