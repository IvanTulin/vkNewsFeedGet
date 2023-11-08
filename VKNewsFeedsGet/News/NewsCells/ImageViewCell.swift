//
//  ImageViewCell.swift
//  VKNewsFeedsGet
//
//  Created by Ivan Tulin on 21.10.2023.
//

import UIKit

class ImageViewCell: UITableViewCell {
    //MARK: -private constants
    private let photo: UIImageView = {
        let newsImage = UIImageView()
        newsImage.contentMode = .scaleAspectFit
        newsImage.clipsToBounds = true
        return newsImage
    }()
    
    //MARK: Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: -private methods
    private func setupCell() {
        [photo].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        // photo.contentMode = .scaleAspectFit
        
        NSLayoutConstraint.activate([
            photo.topAnchor.constraint(equalTo: contentView.topAnchor),
            photo.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            photo.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            photo.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 10)
        ])
    }
    
    //MARK: -public constants
    func configureImage(_ image: UIImage?) {
        photo.image = image
    }
    
}
