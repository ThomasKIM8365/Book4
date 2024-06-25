//
//  ViewModel.swift
//  Book4
//
//  Created by 김진규 on 6/25/24.
//

import Foundation

class BookListViewModel: ObservableObject {
    @Published var books: [Book] = []
    @Published var searchText = ""
    @Published var selectedCategory = "mongodb"
    @Published var currentPage = 1
    @Published var totalPages = 1
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiService = APIService()
    var cache = ImageCache()

    func fetchBooks() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let (books, totalPages) = try await apiService.fetchBooks(query: searchText, page: currentPage, category: selectedCategory)
                DispatchQueue.main.async {
                    self.books = books
                    self.totalPages = totalPages
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            }
            isLoading = false
        }
    }

    func searchBooks() {
        currentPage = 1
        fetchBooks()
    }

    func loadNextPage() {
        if currentPage < totalPages {
            currentPage += 1
            fetchBooks()
        }
    }

    func loadPreviousPage() {
        if currentPage > 1 {
            currentPage -= 1
            fetchBooks()
        }
    }

    func fetchBookDetail(for book: Book) {
        guard let index = books.firstIndex(where: { $0.id == book.id }) else { return }

        Task {
            do {
                let bookDetail = try await apiService.fetchBookDetail(isbn13: book.isbn13)
                DispatchQueue.main.async {
                    self.books[index].detail = bookDetail
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
