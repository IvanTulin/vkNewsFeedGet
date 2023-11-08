//
//  SessionApp.swift
//  VKNewsFeedsGet
//
//  Created by Ivan Tulin on 02.10.2023.
//

import Foundation

class SessionApp {
    static let shared = SessionApp()
    
    var token: String?
    
    private init(){}
}
