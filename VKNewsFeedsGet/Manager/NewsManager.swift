//
//  NewsManager.swift
//  VKNewsFeedsGet
//
//  Created by Ivan Tulin on 02.10.2023.
//

import Foundation
import UIKit
import PromiseKit

final class NewsManager {
    //MARK: -private properties
    private var urlComponent = URLComponents()
    
    //MARK: -private constants
    private let config: URLSessionConfiguration
    private let session: URLSession
    private let json = JSONDecoder()
    private let version = "5.131"
    
    //MARK: -Init
    init() {
        urlComponent.scheme = "https"
        urlComponent.host = "api.vk.com"
        config = URLSessionConfiguration.default
        session = URLSession(configuration: config)
    }
    
    //MARK: -public methods
    func getNews(completion: @escaping([News]) -> ()) {
        urlComponent.path = "/method/newsfeed.get"
        
        urlComponent.queryItems = [
            URLQueryItem(name: "filters", value: "post"),
            URLQueryItem(name: "count", value: "15"),
            URLQueryItem(name: "access_token", value: SessionApp.shared.token!),
            URLQueryItem(name: "v", value: version),
        ]
        
        let task = session.dataTask(with: urlComponent.url!) { data, response, error in
            DispatchQueue.global(qos: .userInteractive).async {
                if let data = data {
                    do{
                         let group = try JSONDecoder().decode(ResponseNews.self, from: data).response.items
                        DispatchQueue.main.async {
                            completion(group)
                        }
                    } catch {
                        print("error: \(error)")
                    }
                }
            }
        }
        task.resume()
    }
    
    
    /// PROMISE PARSEDATE
    /// 1. Создаем URL для запроса
    func getUrl() -> Promise<URL> {
        
        urlComponent.path = "/method/newsfeed.get"
        
        urlComponent.queryItems = [
            URLQueryItem(name: "filters", value: "post"),
            URLQueryItem(name: "count", value: "6"),
            URLQueryItem(name: "access_token", value: SessionApp.shared.token!),
            URLQueryItem(name: "v", value: version),
        ]
        return Promise { resolver in
            guard let url = urlComponent.url else {return}
            resolver.fulfill(url)
        }
    }
    
    /// для Pull-to-refresh
    func getUrlWithTime(_ timeInterval1970: String) -> Promise<URL> {
        
        urlComponent.path = "/method/newsfeed.get"
        
        urlComponent.queryItems = [
            URLQueryItem(name: "filters", value: "post"),
            URLQueryItem(name: "start_time", value: timeInterval1970),
            URLQueryItem(name: "count", value: "2"),
            URLQueryItem(name: "access_token", value: SessionApp.shared.token!),
            URLQueryItem(name: "v", value: version),
        ]
        return Promise { resolver in
            guard let url = urlComponent.url else {return}
            resolver.fulfill(url)
        }
    }
    
    /// для Паттерна Infinite Scrolling
    func getUrlNextFrom(_ nextFrom: String) -> Promise<URL> {
        
        urlComponent.path = "/method/newsfeed.get"
        
        urlComponent.queryItems = [
            URLQueryItem(name: "filters", value: "post"),
            URLQueryItem(name: "start_from", value: nextFrom),
            URLQueryItem(name: "count", value: "3"),
            URLQueryItem(name: "access_token", value: SessionApp.shared.token!),
            URLQueryItem(name: "v", value: version),
        ]
        return Promise { resolver in
            guard let url = urlComponent.url else {return}
            resolver.fulfill(url)
        }
    }
    
    /// 2. Создаем запрос
    func getData(_ url: URL) -> Promise<Data> {
        
        
        return Promise { resolver in
            let task = session.dataTask(with: url) { data, _, error in
                guard let data = data else {
                    resolver.reject(error!)
                    return
                }
                resolver.fulfill(data)
            }
            task.resume()
        }
    }
    
    ///3. Парсим data
    func getParseData(_ data: Data) -> Promise<ResponseNews> {
        return Promise { resolver in
            do{
                let news = try json.decode(ResponseNews.self, from: data)
                resolver.fulfill(news)
            } catch let error {
                resolver.reject(error)
            }
        }
    }
    
    ///4. Получение новостей погоды
    func getNews(_ news: ResponseNews) -> Promise<[News]> {
        return Promise { resolver in
            let news = news.response.items
            
            resolver.fulfill(news)
        }
    }
}
