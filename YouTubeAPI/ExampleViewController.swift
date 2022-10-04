//
//  ExampleViewController.swift
//  YouTubeAPI
//
//  Created by Vladimir Pisarenko on 04.10.2022.
//

import UIKit

class ExampleViewController: UIViewController {
    
    let backgroungImage: UIImageView = {
        let image = UIImageView()
        image.backgroundColor = .brown
        image.translatesAutoresizingMaskIntoConstraints = false
//        image.image = UIImage(systemName: <#T##String#>)
        return image
    }()

    let channelNameLabel: UILabel = {
        let v = UILabel()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .white
        v.textAlignment = .center
        v.layer.cornerRadius = 8
        return v
    }()
    
    let amoontOfSubscribersLabel: UILabel = {
        let v = UILabel()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .cyan
        v.textAlignment = .center
        v.layer.cornerRadius = 8
        return v
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.cornerRadius = 8
        
//        view.addSubview(backgroungImage)
//        NSLayoutConstraint.activate([
//            backgroungImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            backgroungImage.topAnchor.constraint(equalTo: view.topAnchor),
//            backgroungImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            backgroungImage.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//            ])
        
        view.addSubview(channelNameLabel)
        view.addSubview(amoontOfSubscribersLabel)
        NSLayoutConstraint.activate([
            channelNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            channelNameLabel.bottomAnchor.constraint(equalTo: amoontOfSubscribersLabel.topAnchor, constant: -10),
            channelNameLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4),
            amoontOfSubscribersLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            amoontOfSubscribersLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
            amoontOfSubscribersLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4)
        ])
    }
}

