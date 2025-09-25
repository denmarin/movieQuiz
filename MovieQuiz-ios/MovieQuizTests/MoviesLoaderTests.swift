//
//  MoviesLoaderTests.swift
//  MovieQuiz
//
//  Created by Yury Semenyushkin on 21.09.25.
//


import XCTest
@testable import MovieQuiz

class MoviesLoaderTests: XCTestCase {
    func testSuccessLoading() async throws {
        // Given
        let stubNetworkClient = StubNetworkClient(emulateError: false)
        let loader = MoviesLoader(networkClient: stubNetworkClient)

        // When
        let movies = try await loader.loadMovies()

        // Then
        XCTAssertEqual(movies.items.count, 2)
    }
    
    func testFailureLoading() async throws {
        // Given
        let stubNetworkClient = StubNetworkClient(emulateError: true)
        let loader = MoviesLoader(networkClient: stubNetworkClient)

        do {
            _ = try await loader.loadMovies()
            XCTFail("Ожидали ошибку, но метод завершился успехом")
        } catch let error as StubNetworkClient.TestError {
                // Конкретно та ошибка, которую мы ожидали от стаба
                XCTAssertEqual(error, .test)
        } catch {
            XCTFail("Неожиданный тип ошибки: \(error)")
        }
    }
}

struct StubNetworkClient: NetworkRouting {

    enum TestError: Error {
        case test
    }

    /// true — эмулируем ошибку; false — успех с prepared JSON
    let emulateError: Bool

    /// Можно эмулировать сетевую задержку (по желанию)
    let artificialDelayNanos: UInt64 = 0 // например, 300_000_000 для 0.3 c

    func fetch(url: URL) async throws -> Data {
        // эмуляция задержки (опционально)
        if artificialDelayNanos > 0 {
            try? await Task.sleep(nanoseconds: artificialDelayNanos)
        }

        if emulateError {
            throw TestError.test
        } else {
            return expectedResponse
        }
    }

    private var expectedResponse: Data {
        """
        {
           "errorMessage" : "",
           "items" : [
              {
                 "crew" : "Dan Trachtenberg (dir.), Amber Midthunder, Dakota Beavers",
                 "fullTitle" : "Prey (2022)",
                 "id" : "tt11866324",
                 "imDbRating" : "7.2",
                 "imDbRatingCount" : "93332",
                 "image" : "https://m.media-amazon.com/images/M/MV5BMDBlMDYxMDktOTUxMS00MjcxLWE2YjQtNjNhMjNmN2Y3ZDA1XkEyXkFqcGdeQXVyMTM1MTE1NDMx._V1_Ratio0.6716_AL_.jpg",
                 "rank" : "1",
                 "rankUpDown" : "+23",
                 "title" : "Prey",
                 "year" : "2022"
              },
              {
                 "crew" : "Anthony Russo (dir.), Ryan Gosling, Chris Evans",
                 "fullTitle" : "The Gray Man (2022)",
                 "id" : "tt1649418",
                 "imDbRating" : "6.5",
                 "imDbRatingCount" : "132890",
                 "image" : "https://m.media-amazon.com/images/M/MV5BOWY4MmFiY2QtMzE1YS00NTg1LWIwOTQtYTI4ZGUzNWIxNTVmXkEyXkFqcGdeQXVyODk4OTc3MTY@._V1_Ratio0.6716_AL_.jpg",
                 "rank" : "2",
                 "rankUpDown" : "-1",
                 "title" : "The Gray Man",
                 "year" : "2022"
              }
            ]
          }
        """.data(using: .utf8) ?? Data()
    }
}
