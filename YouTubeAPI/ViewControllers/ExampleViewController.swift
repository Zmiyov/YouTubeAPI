//
//  ExampleViewController.swift
//  YouTubeAPI
//
//  Created by Vladimir Pisarenko on 04.10.2022.
//

import UIKit

class ExampleViewController: UIViewController {
    
    var playlistId: String?
    
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
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        let darkGrey = UIColor(red: 56.0/255.0, green: 56.0/255.0, blue: 56.0/255.0, alpha: 1.0)
        label.textColor = darkGrey
        
        return label
    }()
    
    let amoontOfSubscribersLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        let labelColor = UIColor(red: 157.0/255.0, green: 157.0/255.0, blue: 157.0/255.0, alpha: 1.0)
        label.textColor = labelColor
        
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        
        view.addSubview(backgroungImage)
        backgroungImage.layer.cornerRadius = 8
        backgroungImage.clipsToBounds = true
        NSLayoutConstraint.activate([
            backgroungImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroungImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroungImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroungImage.widthAnchor.constraint(equalTo: view.widthAnchor),
            backgroungImage.heightAnchor.constraint(equalTo: backgroungImage.widthAnchor, multiplier: 0.55)
            ])
        
        view.addSubview(channelNameLabel)
        view.addSubview(amoontOfSubscribersLabel)
        NSLayoutConstraint.activate([
            channelNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            channelNameLabel.bottomAnchor.constraint(equalTo: amoontOfSubscribersLabel.topAnchor, constant: -3),
            channelNameLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4),
            amoontOfSubscribersLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            amoontOfSubscribersLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -25),
            amoontOfSubscribersLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4)
        ])
    }
}
