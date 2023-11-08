//
//  TextViewCell.swift
//  VKNewsFeedsGet
//
//  Created by Ivan Tulin on 21.10.2023.
//

import UIKit

class TextViewCell: UITableViewCell {
    
    //MARK: -private constants
    let newsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = .black
        return label
    }()
    
    //MARK: Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super .init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: -private methods
    private func setupCell() {
        [newsLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        newsLabel.numberOfLines = 0
        
        NSLayoutConstraint.activate([
            
            newsLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            newsLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            newsLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            newsLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            
        ])
    }
    
    //MARK: -public constants
    func configureText(_ text: String) {
        newsLabel.text = text
    }
    
}
