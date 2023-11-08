//
//  PhotoService.swift
//  VKNewsFeedsGet
//
//  Created by Ivan Tulin on 21.10.2023.
//

import Foundation
import UIKit
import Alamofire

//MARK: -protocol
/// Для унифицирования обновления  создаю протокол и два объекта, в которые обернём коллекцию и таблицу.
fileprivate protocol DataReloadable {
    func reloadRow(atIndexpath indexPath: IndexPath)
}

final class PhotoService {
    //MARK: -private properties
    private var images = [String: UIImage]()
    
    private static let pathName: String = {
        let pathName = "images"
        guard let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else { return pathName }
        let url = cachesDirectory.appendingPathComponent(pathName, isDirectory: true)
        
        if !FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.createDirectory(at: url,withIntermediateDirectories: true, attributes: nil)
        }
        return pathName
    }()
    
    //MARK: - private constants
    /// свойство container для хранения обертки и два конструктора для установки таблицы или коллекции, в зависимости от того, что сейчас используется.
    private let container: DataReloadable
    private let cacheLifeTime: TimeInterval = 30 * 24 * 60 * 60
    
    //MARK: - Init
    init(container: UITableView) {
        self.container = Table(table: container)
    }
    
    init(container: UICollectionView) {
        self.container = Collection(collection: container)
    }
    
    //MARK: -private methods
    private func getFilePath(url: String) -> String? {
        guard let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else { return nil }
        let hashName = url.split(separator: "/").last ?? "default"
        return cachesDirectory.appendingPathComponent(PhotoService.pathName + "/" + hashName).path
    }
    
    
    private func saveImageToCache(url: String, image: UIImage) {
        guard let fileName = getFilePath(url: url),
              let data = image.pngData() else { return }
        FileManager.default.createFile(atPath: fileName, contents: data, attributes: nil) }
    
    
    ///getImageFromCache загружает изображение из файловой системы. При этом он проводит ряд проверок. Первым делом мы пытаемся получить атрибуты изображения FileManager.default.attributesOfItem. Этот метод вернёт всю техническую информацию о файле, если он существует. Нас интересует дата последнего изменения. Если со времени изменения файла прошло больше секунд, чем указано в нашем свойстве cacheLifeTime, файл считается устаревшем и мы не будем заново загружать его из сети.
    private func getImageFromCache(url: String) -> UIImage? {
        guard
            let fileName = getFilePath(url: url),
            let info = try? FileManager.default.attributesOfItem(atPath: fileName),
            let modificationDate = info[FileAttributeKey.modificationDate] as?  Date
        else { return nil }
        let lifeTime = Date().timeIntervalSince(modificationDate)
        guard
            lifeTime <= cacheLifeTime,
            let image = UIImage(contentsOfFile: fileName) else { return nil }
        DispatchQueue.main.async {
            self.images[url] = image
        }
        return image
    }
    
    
    private func loadPhoto(atIndexpath indexPath: IndexPath, byUrl url: String) {
        AF.request(url).responseData(queue: DispatchQueue.global()) { [weak self] response in
            guard
                let data = response.data,
                let self = self,
                let image = UIImage(data: data) else { return }
            
            DispatchQueue.main.async {
                self.images[url] = image
            }
            self.saveImageToCache(url: url, image: image)
            DispatchQueue.main.async {
                self.container.reloadRow(atIndexpath: indexPath) }
        }
    }
    
    
    //MARK: -public methods
    public func photo(atIndexpath indexPath: IndexPath, byUrl url: String) -> UIImage? {
        var image: UIImage?
        if let photo = images[url] {
            image = photo
        } else if let photo = getImageFromCache(url: url) {
            image = photo }
        else {
            loadPhoto(atIndexpath: indexPath, byUrl: url)
        }
        return image
    }
    
}


//MARK: -extension

extension PhotoService {
    
    private class Table: DataReloadable {
        let table: UITableView
        
        init(table: UITableView) {
            self.table = table
        }
        
        func reloadRow(atIndexpath indexPath: IndexPath) {
            table.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    private class Collection: DataReloadable {
        let collection: UICollectionView
        
        init(collection: UICollectionView) {
            self.collection = collection
        }
        
        func reloadRow(atIndexpath indexPath: IndexPath) {
            collection.reloadItems(at: [indexPath])
        }
    }
}
