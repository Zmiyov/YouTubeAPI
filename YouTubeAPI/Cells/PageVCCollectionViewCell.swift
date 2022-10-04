//
//  PageVCCollectionViewCell.swift
//  YouTubeAPI
//
//  Created by Vladimir Pisarenko on 04.10.2022.
//

import UIKit

class PageVCCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "PageVCCollectionViewCell"
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.distribution = .fill
        stackView.alignment = .fill

        return stackView
    }()

    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 5.0
        return imageView
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .regular)
        label.textColor = UIColor.label
        label.setContentHuggingPriority(.required, for: .vertical)

        return label
    }()

    let subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .regular)
        label.textColor = UIColor.secondaryLabel
        label.setContentHuggingPriority(.required, for: .vertical)

        return label
    }()


    override init(frame: CGRect) {
        super.init(frame: frame)

        stackView.addArrangedSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: stackView.topAnchor),
            imageView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            imageView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            imageView.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 200)
        ])

        stackView.setCustomSpacing(10, after: imageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subTitleLabel)



        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor)

        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureCell(_ app: App) {
        titleLabel.text = app.title
        subTitleLabel.text = app.subtitle
        imageView.backgroundColor = app.color
    }
    

}
