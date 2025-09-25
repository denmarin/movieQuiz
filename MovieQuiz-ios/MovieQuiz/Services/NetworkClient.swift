import Foundation

protocol NetworkRouting {
    func fetch(url: URL) async throws -> (Data)
}

struct NetworkClient: NetworkRouting {
    
    private enum NetworkError: Error {
        case codeError
    }
    
    func fetch(url: URL) async throws -> Data {
        let request = URLRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            throw NetworkError.codeError
        }
        return data
    }
}


/*
 // версия от практикума
 
 protocol NetworkRouting {
     func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void)
 }
 
 func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
 let request = URLRequest(url: url)
 
 let task = URLSession.shared.dataTask(with: request) { data, response, error in
 
 if let error = error {
 handler(.failure(error))
 return
 }
 
 if let response = response as? HTTPURLResponse,
 response.statusCode < 200 || response.statusCode >= 300 {
 handler(.failure(NetworkError.codeError))
 return
 }
 
 guard let data = data else { return }
 handler(.success(data))
 }
 
 task.resume()
 }
 */

