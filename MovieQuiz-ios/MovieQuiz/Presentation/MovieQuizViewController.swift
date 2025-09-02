import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // MARK: - Lifecycle
    
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        questionFactory = QuestionFactory(delegate: self)
        
        questionFactory?.requestNextQuestion()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }

        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }

// MARK: - Actions

@IBAction private func YesButtonClicked(_ sender: UIButton) {
    guard let currentQuestion = currentQuestion else {
        return
    }
    let givenAnswer = true
    
    showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
}

@IBAction private func NoButtonClicked(_ sender: UIButton) {
    guard let currentQuestion = currentQuestion else {
        return
    }
    let givenAnswer = false
    
    showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
}

// MARK: - Private functions

private func convert(model: QuizQuestion) -> QuizStepViewModel {
    let questionStep = QuizStepViewModel(
        image: UIImage(named: model.image) ?? UIImage(),
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
        let text = correctAnswers == questionsAmount ?
        "Поздравляем, вы ответили на 10 из 10!" :
        "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"
        let viewModel = QuizResultsViewModel(
            title: "Этот раунд окончен!",
            text: text,
            buttonText: "Сыграть ещё раз")
        show(result: viewModel)
    } else {
        currentQuestionIndex += 1
        self.questionFactory?.requestNextQuestion()
    }
}

private func show(result: QuizResultsViewModel) {
    let alert = UIAlertController(
        title: result.title,
        message: result.text,
        preferredStyle: .alert)
    
    let action = UIAlertAction(title: result.buttonText, style: .default) {[weak self] _ in
        guard let self = self else { return }
        self.currentQuestionIndex = 0
        self.correctAnswers = 0
        
        self.questionFactory = QuestionFactory(delegate: self)
        
        questionFactory?.requestNextQuestion()
    }
    
    alert.addAction(action)
    
    self.present(alert, animated: true, completion: nil)
}
}
