//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Yury Semenyushkin on 03.09.25.
//

import Foundation

struct AlertModel {
    var title: String
    var message: String
    var buttonText: String
    var completion: () -> Void
}
