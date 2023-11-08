//
//  GetNewsViewController.swift
//  VKNewsFeedsGet
//
//  Created by Ivan Tulin on 02.10.2023.
//

import UIKit
import SDWebImage

final class GetNewsViewController: UIViewController {
    
    //MARK: -private properties
    private var arrayNews = [News]()
    private var photoService: PhotoService?
    private var lastDate: String?
    private var nextFrom = ""
    private var isLoading = false
    
    //MARK: -private constant
    private let vkNews = NewsManager()
    private let servicePromise = NewsManager()
    
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRefreshControl()
        photoService = PhotoService(container: tableView)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.prefetchDataSource = self
        tableView.register(NewsCell.self, forCellReuseIdentifier: "NewsCell")
        tableView.register(ImageViewCell.self, forCellReuseIdentifier: "ImageViewCell")
        tableView.register(TextViewCell.self, forCellReuseIdentifier: "TextViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        servicePromise.getUrl()
            .then(on: .global(), servicePromise.getData(_:))
            .then(servicePromise.getParseData(_:))
            .get({ response in
                self.nextFrom = response.response.nextFrom ?? ""
            })
            .then(servicePromise.getNews(_:))
            .done(on: .main) { news in
                let myNews = news
                self.arrayNews = myNews
                //self.lastDate = self.arrayNews.first?.getStringDate()
                self.lastDate = String(self.arrayNews.first?.date ?? 0)
                self.tableView.reloadData()
            }.catch { error in
                print(error)
            }

    }
    
    //MARK: -private methods
    fileprivate func setupRefreshControl() {
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.attributedTitle = NSAttributedString(string: "Refreshing...")
        tableView.refreshControl?.tintColor = .red
        tableView.refreshControl?.addTarget(self, action: #selector(refreshNews), for: .valueChanged)
    }
    
    
    @objc func refreshNews() {
        guard let date = lastDate else {
            tableView.refreshControl?.endRefreshing()
            return
        }
        
        servicePromise.getUrlWithTime(date)
            .then(on: .global(), servicePromise.getData(_:))
            .then(servicePromise.getParseData(_:))
            .then(servicePromise.getNews(_:))
            .done(on: .main) { [weak self] news in
                guard news.count > 0, let self = self else{return}
                self.arrayNews = news + self.arrayNews
    
                self.lastDate = String(self.arrayNews.first?.date ?? 0)
                
                self.tableView.reloadData()// обновляем таблицу
                
            }.ensure {[weak self] in
                guard let self = self else{return}
                self.tableView.refreshControl?.endRefreshing()
                
            }.catch { error in
                print(error)
            }
    }
}


//MARK: -UITableViewDataSource

extension GetNewsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        arrayNews.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "секция - \(arrayNews[section].posId)"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ImageViewCell") as? ImageViewCell else {fatalError()}
            guard let urlImage = arrayNews[indexPath.section].photosURL?.first else {return UITableViewCell()}
            
            let image = photoService?.photo(atIndexpath: indexPath, byUrl: urlImage)
            cell.configureImage(image)
            return cell
            
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TextViewCell") as? TextViewCell else {fatalError()}
            cell.configureText(arrayNews[indexPath.section].text)
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
}

//MARK: -UITableViewDelegate

extension GetNewsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.row {
        case 0:
            guard let urls = arrayNews[indexPath.section].photosURL, !urls.isEmpty else {return 0}
            
            let width = view.frame.width
            let post = arrayNews[indexPath.section]
            let cellHeight = width * post.aspectRatio
            return cellHeight
        case 1:
            if arrayNews[indexPath.section].text.isEmpty {
                return 0
            } else {
                return UITableView.automaticDimension
            }
        default:
             return 0
        }
    }
}


//MARK: -UITableViewDataSourcePrefetching
extension GetNewsViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        
        guard let maxSection = indexPaths.map({$0.section }).max() else {return}
        if maxSection > arrayNews.count - 3, !isLoading {
            isLoading = true
            servicePromise.getUrlNextFrom(nextFrom)
                .then(on: .global(), servicePromise.getData(_:))
                .then(servicePromise.getParseData(_:))
                .then(servicePromise.getNews(_:))
                .done(on: .main) { [weak self] news in
                    guard let self = self else{return}
                    
                    let indexSet = IndexSet(integersIn: self.arrayNews.count..<self.arrayNews.count + news.count)
                    self.arrayNews.append(contentsOf: news)
                    tableView.insertSections(indexSet, with: .automatic)
                    
                }.ensure { [weak self] in 
                    guard let self = self else{return}
                    self.isLoading = false
                }.catch { error in
                    print(error)
                }
        }
    }
    
    
}
