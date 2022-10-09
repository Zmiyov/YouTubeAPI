//
//  ExampleViewController.swift
//  YouTubeAPI
//
//  Created by Vladimir Pisarenko on 04.10.2022.
//

import UIKit

class ExampleViewController: UIViewController {
    
    var backgroungImage: UIImageView = {
        let image = UIImageView()
        image.backgroundColor = .brown
        image.contentMode = .scaleAspectFill
        image.translatesAutoresizingMaskIntoConstraints = false

        return image
    }()

    let channelNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        
        return label
    }()
    
    let amoontOfSubscribersLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .systemGray2
        
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.cornerRadius = 8
        
        view.addSubview(backgroungImage)
        backgroungImage.layer.cornerRadius = 8
        backgroungImage.clipsToBounds = true
        NSLayoutConstraint.activate([
            backgroungImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroungImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroungImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroungImage.widthAnchor.constraint(equalTo: view.widthAnchor),
            backgroungImage.heightAnchor.constraint(equalTo: backgroungImage.widthAnchor, multiplier: 0.5)
            ])
        
        view.addSubview(channelNameLabel)
        view.addSubview(amoontOfSubscribersLabel)
        NSLayoutConstraint.activate([
            channelNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            channelNameLabel.bottomAnchor.constraint(equalTo: amoontOfSubscribersLabel.topAnchor, constant: 0),
            channelNameLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4),
            amoontOfSubscribersLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            amoontOfSubscribersLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
            amoontOfSubscribersLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4)
        ])
    }
}
