import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    private let moviesLoader: MoviesLoading
    private var delegate: QuestionFactoryDelegate?
    private var movies: [MostPopularMovie] = []

    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
            self.moviesLoader = moviesLoader
            self.delegate = delegate
        }
        
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
    
    func setup(delegate: QuestionFactoryDelegate) {
        self.delegate = delegate
    }
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
           
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.delegate?.didFailToLoadData(with: error)
                }
                return
            }
            
            let rating = Float(movie.rating) ?? 0
            let randomRating = Int([5, 6, 7, 8].randomElement() ?? 7)
            let isGreaterThan = Bool.random()
            let comparisonText = isGreaterThan ? "больше" : "меньше"
            let correctAnswer = isGreaterThan ? (Int(rating) > randomRating) : (Int(rating) < randomRating)

            let text = "Рейтинг этого фильма\n\(comparisonText) чем \(randomRating)?"
            
            let question = QuizQuestion(image: imageData,
                                         text: text,
                                         correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                self?.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
}
