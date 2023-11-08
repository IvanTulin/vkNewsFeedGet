//
//  ModelNews.swift
//  VKNewsFeedsGet
//
//  Created by Ivan Tulin on 02.10.2023.
//

import Foundation
import RealmSwift

struct ResponseNews:  Codable {
    let response: NewsItems
}

struct NewsItems: Codable {
    let items: [News]

    ///next_from — содержит start_from, который необходимо передать, для того, чтобы получить следующую часть новостей. Позволяет избавиться от дубликатов, которые могут возникнуть при появлении новых новостей между вызовами этого метода.
    let nextFrom: String?
    
    enum CodeingKeys: String, CodingKey{
        case items
        case nextFrom = "next_from"
        
    }
}

struct ProfileNews: Codable{
    let id: Int
    let firstName: String
    let lastName: String
    let avatarURL: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case avatarURL = "photo_100"
    }
}

struct GroupNews: Codable {
    let id: Int
    let name: String
    let avatarURL: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case avatarURL = "photo_100"
    }
}

struct News: Codable {
    let posId: Int
    let text: String
    let date: Double
    let attachments: [Attachments]?
    var photosURL: [String]? {
        get {
            let photoURL = attachments?.compactMap{ $0.photo?.sizes?.last?.url}
            return photoURL
        }
    }
    
    var aspectRatio: CGFloat {
        get {
            let aspectRatio = attachments?.compactMap{ $0.photo?.sizes?.last?.aspectRatio}.last
            return aspectRatio ?? 1
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case posId = "post_id"
        case text
        case date
        case attachments
    }
    
    func getStringDate() -> String {
        let dateFormatter = DateFormatterVK()
        return dateFormatter.convertDate(timeIntervalSince1970: date)
    }
}

struct Attachments: Codable{
    let type: String?
    let photo: PhotoNews?
}

struct PhotoNews: Codable {
    let sizes: [Size]?
}

struct Size: Codable {
    var height: Int?
    let url: String?
    let type: String?
    var width: Int?
    
    var aspectRatio: CGFloat{ return CGFloat(height ?? 1) / CGFloat(width ?? 1)}
}

class DateFormatterVK {
    let dateFormatter = DateFormatter()
    
    func convertDate(timeIntervalSince1970: Double) -> String {
        dateFormatter.dateFormat = "MM-dd-yyyy HH.mm"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let date = Date(timeIntervalSince1970: timeIntervalSince1970)
        return dateFormatter.string(from: date)
    }
}
