import Foundation

protocol MoviesLoading {
    func loadMovies() async throws -> MostPopularMovies
}

struct MoviesLoader: MoviesLoading {
    // MARK: - Dependencies
    private let networkClient: NetworkRouting

    // MARK: - Init
    init(networkClient: NetworkRouting = NetworkClient()) {
        self.networkClient = networkClient
    }

    // MARK: - URL
    private var mostPopularMoviesUrl: URL {
        guard let url = URL(string: "https://tv-api.com/en/API/Top250Movies/k_zcuw1ytf") else {
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        return url
    }

    // MARK: - API
    func loadMovies() async throws -> MostPopularMovies {
        let data = try await networkClient.fetch(url: mostPopularMoviesUrl)
        return try JSONDecoder().decode(MostPopularMovies.self, from: data)
    }
}
    /*
    // версия от практикума
     
     struct MoviesLoader: MoviesLoading {
       
       private let networkClient: NetworkRouting
       
       init(networkClient: NetworkRouting = NetworkClient()) {
           self.networkClient = networkClient
       }
         
         private var mostPopularMoviesUrl: URL {
             guard let url = URL(string: "https://tv-api.com/en/API/Top250Movies/k_zcuw1ytf") else {
                 preconditionFailure("Unable to construct mostPopularMoviesUrl")
             }
             return url
         }
         
         func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
             networkClient.fetch(url: mostPopularMoviesUrl) { result in
                 switch result {
                 case .success(let data):
                     do {
                         let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                         handler(.success(mostPopularMovies))
                     } catch {
                         handler(.failure(error))
                     }
                 case .failure(let error):
                     handler(.failure(error))
                 }
             }
         }
     }
    */


