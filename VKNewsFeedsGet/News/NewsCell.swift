//
//  NewsCell.swift
//  VKNewsFeedsGet
//
//  Created by Ivan Tulin on 03.10.2023.
//

import UIKit
import SDWebImage


final class NewsCell: UITableViewCell {
    //MARK: -private constant
    private let photo = UIImageView()
    private let newsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = .black
        return label
    }()
    
    //MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super .init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: -private methods
    private func setupCell() {
        [photo,newsLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        photo.contentMode = .scaleAspectFit
        newsLabel.numberOfLines = 0
        
        NSLayoutConstraint.activate([
            photo.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            photo.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            photo.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 5),
            photo.heightAnchor.constraint(equalToConstant: 160),
            photo.widthAnchor.constraint(equalToConstant: 160),
            
            newsLabel.topAnchor.constraint(equalTo: photo.bottomAnchor, constant: 10),
            newsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            newsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 5),
            newsLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 5),
            newsLabel.heightAnchor.constraint(equalToConstant: 160),
            newsLabel.widthAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    //MARK: -public methods
    func configureImage(_ image: UIImage?) {
        photo.image = image
    }
    
    func configureText(_ text: String) {
        newsLabel.text = text
    }
    
    func configure(news: News) {
        if let attachments = news.attachments {
            for attachment in attachments {
                if attachment.type == "photo", let photo = attachment.photo {
                    let sizes = photo.sizes
                    if var firstSize = sizes?.first{
                        firstSize.height = 155
                        firstSize.width = 155
                        let imageUrlString = "\(firstSize.url)"
                        if let imageUrl = URL(string: imageUrlString) {
                            self.photo.sd_setImage(with: imageUrl)
                            //cell.imageView?.sd_setImage(with: imageUrl)
                        }
                    }
                }
            }
        }
    }
}
