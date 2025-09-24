//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Yury Semenyushkin on 03.09.25.
//

import UIKit

final class AlertPresenter {

    private weak var viewController: UIViewController?

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func present(model: AlertModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )
        alert.view.accessibilityIdentifier = "Game results"

        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion()
        }
        alert.addAction(action)

        viewController?.present(alert, animated: true)
    }
}

