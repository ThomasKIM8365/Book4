//
//  Network.swift
//  Book4
//
//  Created by 김진규 on 6/25/24.
//

import Foundation

class APIService {
    func fetchBooks(query: String, page: Int, category: String = "mongodb") async throws -> ([Book], Int) {
        var urlString = "https://api.itbook.store/1.0/search/"
        if query.isEmpty {
            urlString += category
        } else {
            urlString += "\(query)"
        }
        
        if page > 1 {
            urlString += "/\(page)"
        }

        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }

        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(BookResult.self, from: data)
            return (result.books, Int(result.total) ?? 0)
        } catch {
            throw APIError.decodingError
        }
    }

    func fetchBookDetail(isbn13: String) async throws -> BookDetail {
        let urlString = "https://api.itbook.store/1.0/books/\(isbn13)"
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }

        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(BookDetail.self, from: data)
            return result
        } catch {
            throw APIError.decodingError
        }
    }
}

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case decodingError
}

struct BookResult: Decodable {
    let error: String
    let total: String
    let books: [Book]
}
