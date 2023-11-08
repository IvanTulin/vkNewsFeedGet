//
//  ViewController.swift
//  VKNewsFeedsGet
//
//  Created by Ivan Tulin on 02.10.2023.
//

import UIKit
import WebKit

class ViewController: UIViewController {
    
    var urlComponents = URLComponents()
    
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.navigationDelegate = self
        
        urlComponents.scheme = "https"
        urlComponents.host = "oauth.vk.com"
        urlComponents.path = "/authorize"
        urlComponents.queryItems = [
            ///в значение value  добавьте свой личный client_id из vk
            URLQueryItem(name: "client_id", value: "-"),
            URLQueryItem(name: "display", value: "mobile"),
            URLQueryItem(name: "redirect_uri", value: "https://oauth.vk.com/blank.html"),
            ///данное поле дает право доступа на получение новостей друзей и групп
            URLQueryItem(name: "scope", value: "wall,friends"),
            URLQueryItem(name: "response_type", value: "token"),
            URLQueryItem(name: "v", value: "5.131")
        ]
        
        let request = URLRequest(url: urlComponents.url!)
        webView.load(request)
        
    }
}


//MARK: - extension
extension ViewController: WKNavigationDelegate{
    
    /// обработчик завершения загрузки страницы
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let currentUrl = webView.url, let urlFragment = currentUrl.fragment{
            let token = extraTokenFromUrlFragment(urlFragment)

            if !token.isEmpty {
                /// получить токен
                print(token)
                SessionApp.shared.token = token
                
                /// получение новостей
                let storyvoard = UIStoryboard(name: "Main", bundle: nil)
                guard let newsVC = storyvoard.instantiateViewController(withIdentifier: "GetNewsViewController") as? GetNewsViewController else {return}

                self.navigationController?.pushViewController(newsVC, animated: true)
                
                
            }
            else {
                print("Ошибка - нет токена")
            }
        }
    }

    func extraTokenFromUrlFragment(_ fragment: String) -> String {
        let parametrPairs = fragment.components(separatedBy: "&")

        for pair in parametrPairs {
            let components = pair.components(separatedBy: "=")
            if components.count == 2 {
                let key = components[0]
                let value = components[1]
                if key == "access_token" {
                    return value
                }

            }
        }


        return ""
    }
    
}

