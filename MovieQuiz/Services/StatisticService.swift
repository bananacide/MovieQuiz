import Foundation

final class StatisticService {
    private let storage: UserDefaults = .standard

    private enum Keys: String {
        case correct
        case bestGame
        case gamesCount
        case totalQuestions
        case bestGameCorrect
        case bestGameTotal
        case bestGameDate
    }
}

extension StatisticService: StatisticServiceProtocol {
    private var correctAnswers: Int {
        get { storage.integer(forKey: Keys.correct.rawValue) }
        set { storage.set(newValue, forKey: Keys.correct.rawValue) }
    }
    
    private var totalQuestions: Int {
        get { storage.integer(forKey: Keys.totalQuestions.rawValue) }
        set { storage.set(newValue, forKey: Keys.totalQuestions.rawValue) }
    }
    
    var gamesCount: Int {
        get { storage.integer(forKey: Keys.gamesCount.rawValue) }
        set { storage.set(newValue, forKey: Keys.gamesCount.rawValue) }
    }
    
    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.bestGameCorrect.rawValue)
            let total = storage.integer(forKey: Keys.bestGameTotal.rawValue)
            let date = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        guard totalQuestions > 0 else { return 0.0 }
        return Double(correctAnswers) / Double(totalQuestions) * 100
    }
    
    func store(correct count: Int, total amount: Int) {
        gamesCount += 1
        correctAnswers += count
        totalQuestions += amount

        let newGameResult = GameResult(correct: count, total: amount, date: Date())
        if newGameResult.isBetterThan(bestGame) {
            bestGame = newGameResult
        }
    }
}
