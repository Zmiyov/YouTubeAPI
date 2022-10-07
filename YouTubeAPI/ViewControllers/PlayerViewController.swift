//
//  PlayerViewController.swift
//  YouTubeAPI
//
//  Created by Vladimir Pisarenko on 07.10.2022.
//

import UIKit

class PlayerViewController: UIViewController {

    @IBOutlet var handleArea: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        configureGradientLayer()
    }
    
    func configureGradientLayer() {
        view.backgroundColor = .clear
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.systemPurple.cgColor, UIColor.systemPink.cgColor]
        gradient.locations = [0, 1]
        gradient.frame = view.bounds
        view.layer.addSublayer(gradient)
    }

}
