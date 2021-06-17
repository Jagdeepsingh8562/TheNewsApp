//
//  NetworkManager.swift
//  NewsNest
//
//  Created by Jagdeep Singh on 12/06/21.
//

import UIKit

class NetworkManager {
    
    
    let cache = NSCache<NSString, UIImage>()
    static let shared = NetworkManager()
    
    struct Const {
        static let apiKey = "282ee3ff78a643ea85af8bf4a7a58600"
        static let baseUrl = "https://newsapi.org/v2/"
        static let nextapiKey = "54f67fff9b69491487e52907fe00ed49"
        static let otherApiKey = "e12557646ee74056b38a68c1d45a22d2"
    }
    
    enum Endpoints {
        
        case getTopHeadlines(Int)
        case getSearch(String)
        case getByCategory(String)
        
        var StringValue: String {
            switch self {
            case .getTopHeadlines(let page):
                return Const.baseUrl + "top-headlines?country=in&pageSize=50&apiKey=" + Const.nextapiKey + "&page=\(page)"
            case .getSearch(let query):
                return Const.baseUrl + "everything?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&apiKey=" + Const.nextapiKey
            case .getByCategory(let selectedCategory):
                return Const.baseUrl + "top-headlines?category=\(selectedCategory.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&apiKey=" + Const.otherApiKey
            }
        }
    }
    
    func getTopHeadline(page: Int,completion: @escaping (Result<[Article], CustomError>) -> Void) {
        taskForGETRequest(url: Endpoints.getTopHeadlines(page).StringValue, responseType: NewsResponse.self, completion: { result in
            switch result {
            case .success(let articles):
                completion(.success(articles))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    
    func getSearchResults(query: String,completion: @escaping (Result<[Article], CustomError>) -> Void) {
        taskForGETRequest(url: Endpoints.getSearch(query).StringValue, responseType: NewsResponse.self, completion: { result in
            switch result {
            case .success(let articles):
                completion(.success(articles))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    
    func getByCategory(selectedCategory: String,completion: @escaping (Result<[Article], CustomError>) -> Void) {
        taskForGETRequest(url: Endpoints.getByCategory(selectedCategory).StringValue, responseType: NewsResponse.self, completion: { result in
            switch result {
            case .success(let articles):
                completion(.success(articles))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    
    
    func taskForGETRequest(url: String, responseType: NewsResponse.Type, completion: @escaping (Result<[Article], CustomError>) -> Void) {
        guard let url = URL(string: url) else {
            DispatchQueue.main.async {
                completion(.failure(.invaildRequest))
            }
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let _ = error {
                DispatchQueue.main.async {
                completion(.failure(.noInternet))
                }
                return
            }
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                DispatchQueue.main.async {
                completion(.failure(.invaildResponse))
                }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(.noData))
                }
                return
            }
            do {
                let responseObject = try JSONDecoder().decode(NewsResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(responseObject.articles))
                }
            } catch {
                completion(.failure(.invaildResponse))
            }
        }
        task.resume()
        
    }
}
