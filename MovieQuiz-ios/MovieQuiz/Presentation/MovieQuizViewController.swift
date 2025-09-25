import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    
    func showLoadingState()
    func showContentState()
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    
    func showNetworkError(message: String)
}

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {

    // MARK: - Lifecycle
    
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var questionSign: UILabel!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    
    var alertPresenter: AlertPresenter?
    
    private lazy var presenter = MovieQuizPresenter(viewController: self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertPresenter = AlertPresenter(viewController: self)
        
        Task {
            await presenter.questionFactory?.loadData()
        }
        
        showLoadingState()
        _ = presenter
        
    }
    
    // MARK: - Actions
    
    @IBAction private func YesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    @IBAction private func NoButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    // MARK: - Private functions

    func showLoadingState() {
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

    func showContentState() {
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
    
    func showNetworkError(message: String) {
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
                    await self.presenter.questionFactory?.loadData()
                }
            }
            self.alertPresenter?.present(model: model)
        }
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }

    
    
    
}
