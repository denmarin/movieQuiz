import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    
    
    // MARK: - Lifecycle
    
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var questionSign: UILabel!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var noButton: UIButton!
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenter?
    private var statistics: StatisticsServiceProtocol = StatisticsService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = 20
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        alertPresenter = AlertPresenter(viewController: self)
        
        showLoadingState()
        Task { [weak self] in
            guard let self = self else { return }
            await self.questionFactory?.loadData()
            
        }
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    func didLoadDataFromServer() {
        // Data is ready, request the first question; UI will be shown when the question arrives
        questionFactory?.requestNextQuestion()
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.showContentState()
            self?.show(quiz: viewModel)
        }
    }
    
    // MARK: - Actions
    
    @IBAction private func YesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        guard yesButton.isEnabled && noButton.isEnabled else { return }
        yesButton.isEnabled = false
        noButton.isEnabled = false
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func NoButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        guard yesButton.isEnabled && noButton.isEnabled else { return }
        yesButton.isEnabled = false
        noButton.isEnabled = false
        let givenAnswer = false
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    // MARK: - Private functions

    private func showLoadingState() {
        // Show only activity indicator and block interactions
        activityIndicator.startAnimating()
        imageView.isHidden = true
        textLabel.isHidden = true
        counterLabel.isHidden = true
        questionSign.isHidden = true
        yesButton.isHidden = true
        noButton.isHidden = true
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }

    private func showContentState() {
        // Hide activity indicator and reveal content
        activityIndicator.stopAnimating()
        imageView.isHidden = false
        textLabel.isHidden = false
        counterLabel.isHidden = false
        questionSign.isHidden = false
        yesButton.isHidden = false
        noButton.isHidden = false
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    
    private func showNetworkError(message: String) {
        activityIndicator.stopAnimating()
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let model = AlertModel(
                title: "Ошибка",
                message: message,
                buttonText: "Попробовать ещё раз"
            ) { [weak self] in
                guard let self = self else { return }
                self.showLoadingState()
                Task { [weak self] in
                    guard let self = self else { return }
                    await self.questionFactory?.loadData()
                }
            }
            self.alertPresenter?.present(model: model)
        }
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        if isCorrect {
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
            self.correctAnswers += 1
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            
            statistics.store(correct: correctAnswers, total: questionsAmount)
            
            let best = statistics.bestGame
            
            let df = DateFormatter()
            df.dateFormat = "dd.MM.yy HH:mm"
            
            let accuracy = String(format: "%.2f%%", statistics.totalAccuracy)
            
            let text = """
            Ваш результат: \(correctAnswers)/\(questionsAmount)
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
                    self.currentQuestionIndex = 0
                    self.correctAnswers = 0
                    self.currentQuestion = nil
                    
                    self.showLoadingState()
                    Task { [weak self] in
                        guard let self = self else { return }
                        await self.questionFactory?.loadData()
                    }
                }
            )
            DispatchQueue.main.async { [weak self] in
                self?.alertPresenter?.present(model: model)
            }
            
            
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
    
}
