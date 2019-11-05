//
//  ContentView.swift
//  LibreriaFlux
//
//  Created by Juan Ignacio Tarallo on 05/11/2019.
//  Copyright © 2019 Juan Ignacio Tarallo. All rights reserved.
//

import SwiftUI

let apiUrl = "https://qodyhvpf8b.execute-api.us-east-1.amazonaws.com/test/books"

struct Book: Identifiable, Decodable {
    let id: Int
    let nombre: String
    let autor: String
    let disponibilidad: Bool
    let popularidad: Int
    let imagen: String
}

class BooksViewModel: ObservableObject {
    @Published var books: [Book] = [
        .init(id: 1, nombre: "Libro 1", autor: "Autor 1", disponibilidad: true, popularidad: 100, imagen: "https://www.google.com.ar"),
        .init(id: 2, nombre: "Libro 2", autor: "Autor 2", disponibilidad: false, popularidad: 80, imagen: "https://www.google.com.ar"),
        .init(id: 3, nombre: "Libro 3", autor: "Autor 3", disponibilidad: true, popularidad: 60, imagen: "https://www.google.com.ar")
    ]
    
    func fetchBooks() {
        guard let url = URL(string: apiUrl) else { return }
        URLSession.shared.dataTask(with: url) { (data, resp, err) in
            DispatchQueue.main.async {
                do {
                    self.books = try JSONDecoder().decode([Book].self, from: data!)
                } catch {
                    print("Failed to decode JSON: ", error)
                }
            }
        }.resume()
    }
}

struct ContentView: View {
    
    @ObservedObject var booksVM = BooksViewModel()
    var body: some View {
        Text("Hello, World!")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
