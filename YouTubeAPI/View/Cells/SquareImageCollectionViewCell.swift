
//
//  SquareImageCollectionViewCell.swift
//  YouTubeAPI
//
//  Created by Vladimir Pisarenko on 04.10.2022.
//


import UIKit

class SquareImageCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "SquareImageCollectionViewCell"
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .green
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .white
        label.numberOfLines = 1
        label.setContentHuggingPriority(.required, for: .vertical)
        
        return label
    }()
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.setContentHuggingPriority(.required, for: .vertical)
        let labelColor = UIColor(red: 124.0/255.0, green: 123.0/255.0, blue: 129.0/255.0, alpha: 1.0)
        label.textColor = labelColor
        
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

        labelStackView.addArrangedSubview(titleLabel)
        labelStackView.addArrangedSubview(subtitleLabel)

        stackView.addArrangedSubview(labelStackView)

        addSubview(stackView)
        
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Set constrains
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: stackView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            imageView.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: stackView.widthAnchor)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: labelStackView.leadingAnchor),
            subtitleLabel.leadingAnchor.constraint(equalTo: labelStackView.leadingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            labelStackView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
        ])
    }
    
    //MARK: - Configure cell
    
    func configureCell(_ playlist: PlaylistItemsVideoModel, networkManager: NetworkManager) {
        titleLabel.text = playlist.title
        
        subtitleLabel.text = playlist.viewCount
        imageView.backgroundColor = .yellow
        
        let urlString = playlist.thumbnail!
        
        Task {
            do {
                imageView.image = try await networkManager.fetchImage(url: urlString )
            } catch {
                print(error)
            }
        }
    }
}
