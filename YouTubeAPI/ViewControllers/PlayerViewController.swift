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
    @IBOutlet var recentTimeLabel: UILabel!
    @IBOutlet var fullTimeLabel: UILabel!
    
    @IBOutlet var videoNameLabel: UILabel!
    @IBOutlet var amountOfViewsLabel: UILabel!
    
    @IBOutlet var previousButton: UIButton!
    @IBOutlet var playPauseButton: UIButton!
    @IBOutlet var nextButton: UIButton!
    
    @IBOutlet var volumeSlider: UISlider!
    
    enum PlayingMode {
        case play
        case pause
    }
    var playingState = false
    
    var playlistID: String? 
    
    let hostingView = YouTubePlayerHostingView(source: .playlist(id: "PLHFlHpPjgk706qEJf9fkclIhdhTkH49Tb"), configuration: .init(autoPlay: false, showControls: false, loopEnabled: false))
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureGradientLayer()
        let timelineSliderThumbImage = UIImage(named: "Line.png")
        timeLineSlider.setThumbImage(timelineSliderThumbImage, for: .normal)
        
        hostingView.player.getPlaybackState { result in
//            switch result {
//
//            case .success(let state):
//
//            case .failure(error):
//
//            }
        }
        addVideoPlayerView()
        configureMetadata()
    }
    
    //MARK: - Actions
    
    @IBAction func openCloseButtonTapped(_ sender: UIButton) {

    }
    
    @IBAction func previousVideoButton(_ sender: UIButton) {
        hostingView.player.previousVideo()
    }
    
    @IBAction func playPauseButton(_ sender: UIButton) {
        
        if playingState == false {
            hostingView.player.play()
            playingState = true
            playPauseButton.setImage(UIImage(named: "Pause"), for: .normal)
        } else {
            hostingView.player.pause()
            playingState = false
            playPauseButton.setImage(UIImage(named: "Play"), for: .normal)
        }
    }
    
    @IBAction func nextVideoButton(_ sender: UIButton) {
        hostingView.player.nextVideo()
    }
  
    @IBAction func volumeSlider(_ sender: UISlider) {
        let volume = Int(sender.value * 100)
        print(volume)
        hostingView.player.set(volume: volume)
    }
    
    
    //MARK: - Configure UI
    
    func addVideoPlayerView() {
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
    
    func configureMetadata() {
        hostingView.player.getPlaybackMetadata { result in
            switch result {
                
            case .success(let playbackMetadata):
                self.videoNameLabel.text = playbackMetadata.title
                
            case .failure(let youTubePlayerAPIError):
                print("Error", youTubePlayerAPIError)
            }
        }
    }
}


