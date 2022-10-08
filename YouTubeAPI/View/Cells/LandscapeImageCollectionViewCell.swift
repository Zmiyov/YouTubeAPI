//
//  LandscapeImageCollectionViewCell.swift
//  YouTubeAPI
//
//  Created by Vladimir Pisarenko on 04.10.2022.
//


import UIKit

class LandscapeImageCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "LandscapeImageCollectionViewCell"
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 8
        
        return stackView
    }()
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 15

        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = .white
        label.numberOfLines = 2
        label.setContentHuggingPriority(.required, for: .vertical)
        
        return label
    }()
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .white
        label.setContentHuggingPriority(.required, for: .vertical)
        
        return label
    }()
    
    let labelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.distribution = .equalSpacing
        
        return stackView
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        stackView.addArrangedSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: stackView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            imageView.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.66)
        ])
        
        labelStackView.addArrangedSubview(titleLabel)
        labelStackView.addArrangedSubview(subtitleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: labelStackView.leadingAnchor),
            subtitleLabel.leadingAnchor.constraint(equalTo: labelStackView.leadingAnchor)
        ])
        
        stackView.addArrangedSubview(labelStackView)
        NSLayoutConstraint.activate([
            labelStackView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor)
        ])
        
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(_ app: App) {
        titleLabel.text = app.title
        subtitleLabel.text = app.subtitle
        imageView.backgroundColor = app.color
    }
}
