//
//  PlayerViewController.swift
//  YouTubeAPI
//
//  Created by Vladimir Pisarenko on 07.10.2022.
//

import UIKit

class PlayerViewController: UIViewController {

    @IBOutlet var handleArea: UIView!
    
    @IBOutlet var openCloseButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureGradientLayer()
    }
    
    
    @IBAction func openCloseButtonTapped(_ sender: UIButton) {
//        if let image = UIImage(named:"Unchecked") {
//            sender.setImage(UIImage(named:"Checked.png"), for: .normal)
//        }
//        if let image = UIImage(named:"Checked") {
//            sender.setImage(UIImage(named:"Unchecked.png"), for: .normal)
//        }
    }
    
    func configureGradientLayer() {
        view.backgroundColor = .clear
        let gradient = CAGradientLayer()
        let pink = UIColor(red: 238.0/255.0, green: 66.0/255.0, blue: 137.0/255.0, alpha: 1.0).cgColor
        let violet = UIColor(red: 99.0/255.0, green: 11.0/255.0, blue: 245.0/255.0, alpha: 1.0).cgColor
        gradient.colors = [pink, violet]
        gradient.locations = [0, 1]
        gradient.frame = view.bounds
        view.layer.insertSublayer(gradient, at: 0)
    }

}
