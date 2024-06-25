//
//  ContentView.swift
//  Book4
//
//  Created by 김진규 on 6/25/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = BookListViewModel()

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Button("New") {
                        viewModel.selectedCategory = "new"
                        viewModel.searchBooks()
                    }
                    Picker("Category", selection: $viewModel.selectedCategory) {
                        Text("Title").tag("title")
                    }
                    .pickerStyle(MenuPickerStyle())
                    TextField("Search", text: $viewModel.searchText)
                        .onSubmit { viewModel.searchBooks() }
                }
                .padding()

                List(viewModel.books) { book in
                    NavigationLink(destination: BookDetailView(book: book, viewModel: viewModel)) {
                        BookRowView(book: book, imageCache: viewModel.cache)
                    }
                }
                .listStyle(PlainListStyle())

                PaginationView(currentPage: $viewModel.currentPage, totalPages: viewModel.totalPages) { newPage in
                    viewModel.currentPage = newPage
                    viewModel.fetchBooks()
                }
            }
            .navigationTitle("IT Books")
            .alert(isPresented: .constant(viewModel.errorMessage != nil)) {
                Alert(title: Text("Error"), message: Text(viewModel.errorMessage ?? "Unknown error"), dismissButton: .default(Text("OK")))
            }
            .onAppear {
                viewModel.fetchBooks()
            }
        }
    }
}

struct BookDetailView: View {
    @State var book: Book
    @ObservedObject var viewModel: BookListViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                if let imageURL = URL(string: book.image), let imageData = try? Data(contentsOf: imageURL), let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                }
                Text(book.title)
                    .font(.title)
                if let subtitle = book.subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                }
                Text("ISBN: \(book.isbn13)")
                Text("Price: \(book.price)")

                if let detail = book.detail {
                    Divider()
                    Text("Details:")
                    if let authors = detail.authors {
                        Text("Authors: \(authors)")
                    }
                    if let publisher = detail.publisher {
                        Text("Publisher: \(publisher)")
                    }
                    // 나머지 상세 정보 표시
                    if let pdf = detail.pdf {
                        ForEach(pdf.keys.sorted(), id: \.self) { key in
                            Link(key, destination: URL(string: pdf[key]!)!)
                        }
                    }
                }
            }
            .padding()
        }
        .onAppear {
            if book.detail == nil {
                viewModel.fetchBookDetail(for: book)
            }
        }
    }
}

struct BookRowView: View {
    let book: Book
    let imageCache: ImageCache

    var body: some View {
        HStack {
            AsyncImage(url: URL(string: book.image)) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 80, height: 80)
            .cornerRadius(10)

            VStack(alignment: .leading) {
                Text(book.title)
                    .font(.headline)
                if let subtitle = book.subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

struct PaginationView: View {
    @Binding var currentPage: Int
    let totalPages: Int
    let onPageChange: (Int) -> Void

    var body: some View {
        HStack {
            Button(action: {
                onPageChange(currentPage - 1)
            }) {
                Image(systemName: "chevron.left")
            }
            .disabled(currentPage == 1)

            ForEach((currentPage - 2)..<(currentPage + 3), id: \.self) { page in
                if page >= 1 && page <= totalPages {
                    Button(action: {
                        onPageChange(page)
                    }) {
                        Text("\(page)")
                            .padding(5)
                            .background(currentPage == page ? Color.blue : Color.clear)
                            .foregroundColor(currentPage == page ? Color.white : Color.black)
                            .cornerRadius(5)
                    }
                }
            }

            Button(action: {
                onPageChange(currentPage + 1)
            }) {
                Image(systemName: "chevron.right")
            }
            .disabled(currentPage == totalPages)
        }
        .padding(.bottom)
    }
}
