//
//  Model.swift
//  Book4
//
//  Created by 김진규 on 6/25/24.
//

import Foundation

struct Book: Identifiable, Codable {
    let id = UUID()
    let title: String
    let subtitle: String?
    let isbn13: String
    let price: String
    let image: String
    let url: String
    
    var detail: BookDetail?
}

struct BookDetail: Codable {
    let authors: String?
    let publisher: String?
    let pages: String?
    let year: String?
    let rating: String?
    let desc: String?
    let pdf: [String: String]?
}
