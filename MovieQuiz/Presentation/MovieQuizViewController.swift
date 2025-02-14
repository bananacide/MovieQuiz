import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    private var statisticService: StatisticServiceProtocol?
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenter?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        statisticService = StatisticService()
        alertPresenter = AlertPresenter(viewController: self)
        
        let questionFactory = QuestionFactory()
        questionFactory.setup(delegate: self)
        self.questionFactory = questionFactory
        
        questionFactory.requestNextQuestion()
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
    
    // MARK: - Private functions
    
    private func show(quiz step: QuizStepViewModel) {
        counterLabel.text = step.questionNumber
        imageView.image = step.image
        questionLabel.text = step.question
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    private func showAnswerResult(isCorrect: Bool) {
            correctAnswers = isCorrect ? correctAnswers + 1 : correctAnswers
        
            imageView.layer.masksToBounds = true
            imageView.layer.borderWidth = 8
            imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                guard let self = self else { return }
                self.showNextQuestionOrResults()
        }
    }
    
    private func disableButtons() {
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }

    private func enableButtons() {
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    
    private func showNextQuestionOrResults() {
        imageView.layer.borderWidth = 0
        
        if currentQuestionIndex == questionsAmount - 1 {
            let text = correctAnswers == questionsAmount ?
                    "Поздравляем, вы ответили на 10 из 10!" :
                    "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            show(quiz: viewModel)
            enableButtons()
        } else {
            currentQuestionIndex += 1
            
            self.questionFactory?.requestNextQuestion()
            
            enableButtons()
        }
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        statisticService?.store(correct: correctAnswers, total: questionsAmount)
        
        let totalAccuracy = statisticService?.totalAccuracy ?? 0
        let bestGame = statisticService?.bestGame
        
        let message = """
            Ваш результат: \(correctAnswers)/\(questionsAmount)
            Количество сыгранных квизов: \(statisticService?.gamesCount ?? 0)
            Рекорд: \(bestGame?.correct ?? 0)/\(bestGame?.total ?? 0) (\(bestGame?.date.dateTimeString ?? ""))
            Средняя точность: \(String(format: "%.2f", totalAccuracy))%
        """
        
        let alertModel = AlertModel(
            title: result.title,
            message: message,
            buttonText: result.buttonText
        ) { [weak self] in
            guard let self = self else { return }
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
        }
        
        alertPresenter?.showAlert(model: alertModel)
    }
    
    // MARK: - Actions
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        disableButtons()
        
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        let isCorrect = givenAnswer == currentQuestion.correctAnswer
        
        showAnswerResult(isCorrect: isCorrect)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        disableButtons()
        
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        let isCorrect = givenAnswer == currentQuestion.correctAnswer
        
        showAnswerResult(isCorrect: isCorrect)
    }
}
