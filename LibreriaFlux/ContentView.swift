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
    let imagen: String = ""
}

struct ImageView: View {
    @ObservedObject var imageLoader:ImageLoader
    @State var image:UIImage = UIImage()

    func imageFromData(_ data:Data) -> UIImage {
        UIImage(data: data) ?? UIImage()
    }

    init(withURL url:String) {
        imageLoader = ImageLoader(urlString:url)
    }

    var body: some View {
        VStack {

            Image(uiImage: imageLoader.data != nil ? UIImage(data:imageLoader.data!)! : UIImage())
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width:100, height:100)
        }
    }

}

class ImageLoader: ObservableObject {
    @Published var dataIsValid = false
    var data:Data?

    init(urlString:String) {
        guard let url = URL(string: urlString) else { return }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            DispatchQueue.main.async {
                self.dataIsValid = true
                self.data = data
            }
        }
        task.resume()
    }
}

class BooksViewModel: ObservableObject {
    @Published var books: [Book] = []
    
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
        NavigationView {
            List {
                VStack(alignment: .leading) {
                    ForEach(booksVM.books.sorted { $0.popularidad > $1.popularidad}) { book in
                        HStack {
                            ImageView(withURL: book.imagen)
                            Text(book.nombre)
                            Spacer()
                            Text(String(book.popularidad))
                        }
                        HStack {
                            Text(book.autor)
                            Spacer()
                            if book.disponibilidad {
                                Text("Disponible")
                            } else {
                                Text("No disponible")
                            }
                        }
                        Spacer()
                    }
                }.padding([.leading, .trailing], 5)
            }
            .navigationBarTitle("Bienvenido a la librería flux")
            .onAppear(perform: self.booksVM.fetchBooks)
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
