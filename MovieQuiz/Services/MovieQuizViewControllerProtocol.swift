//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Алексей Витценко on 4.03.2025.
//

import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    func resetImageBorder()
    
    func enableButtons()
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func showNetworkError(message: String)
}
