//
//  PlayerViewController.swift
//  YouTubeAPI
//
//  Created by Vladimir Pisarenko on 07.10.2022.
//

import UIKit
import YouTubePlayerKit

class PlayerViewController: UIViewController {

    @IBOutlet var handleArea: UIView!
    @IBOutlet var openCloseButton: UIButton!
    
    @IBOutlet var videoView: UIView!
    
    @IBOutlet var timeLineSlider: UISlider!
    @IBOutlet var recentTameLabel: UILabel!
    @IBOutlet var fullTimeLabel: UILabel!
    
    @IBOutlet var videoNameLabel: UILabel!
    @IBOutlet var amountOfViewsLabel: UILabel!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureGradientLayer()
        let timelineSliderThumbImage = UIImage(named: "Line.png")
        timeLineSlider.setThumbImage(timelineSliderThumbImage, for: .normal)
        
        
            
        addVideoPlayerView()
        

    }
    
    
    @IBAction func openCloseButtonTapped(_ sender: UIButton) {

    }
    
    func addVideoPlayerView() {
//        let youTubePlayer = YouTubePlayer(stringLiteral: "https://www.youtube.com/watch?v=w87fOAG8fjk")
        let configuration = YouTubePlayer.Configuration(
            autoPlay: true,
            showControls: false,
            loopEnabled: true
        )
//        let youTubePlayer = YouTubePlayer(source: .playlist(id: "PLHFlHpPjgk706qEJf9fkclIhdhTkH49Tb"), configuration: configuration)
        let hostingView = YouTubePlayerHostingView(source: .playlist(id: "PLHFlHpPjgk706qEJf9fkclIhdhTkH49Tb"), configuration: configuration)
        hostingView.frame = videoView.bounds
        videoView.addSubview(hostingView)
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
