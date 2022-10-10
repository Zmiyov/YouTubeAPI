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
    
    let networkController = NetworkController()
    
    var playingState = false
    
    let playlistID: String = "PLHFlHpPjgk706qEJf9fkclIhdhTkH49Tb"
    
    var playlistFromChannel: String?
    
    var hostingView: YouTubePlayerHostingView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        addVideoPlayerView(playlistID: self.playlistID)
        setDuration()
        getElapsedTime()
        getViewCount()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureGradientLayer()
        setDuration()
        getElapsedTime()
        getViewCount()
        
        if let playlistFromChannel = playlistFromChannel {
            hostingView.player.source = .playlist(id: playlistFromChannel)
            hostingView.player.configuration.autoPlay = true
        }
        configureMetadata { name in
            self.setVideoName(name)
        }
        
        let timelineSliderThumbImage = UIImage(named: "Line.png")
        timeLineSlider.setThumbImage(timelineSliderThumbImage, for: .normal)
    }
    
    //MARK: - Actions
    
    @IBAction func openCloseButtonTapped(_ sender: UIButton) {

    }
    
    @IBAction func previousVideoButton(_ sender: UIButton) {
        hostingView.player.previousVideo()
        playingState = true
        playPauseButton.setImage(UIImage(named: "Pause"), for: .normal)
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
        playPauseButton.setImage(UIImage(named: "Pause"), for: .normal)
        hostingView.player.nextVideo()
        playingState = true
    }
  
    @IBAction func volumeSlider(_ sender: UISlider) {
        let volume = Int(sender.value * 100)
        print(volume)
        hostingView.player.set(volume: volume)
    }
    
    //MARK: - fetch data
    
    func getViewCount() {
        
        Task {
            do {
                let fetchedCount = try await networkController.getViewCountVideos(videoId: "175GAmhgzSk")
                
                let formatter = NumberFormatter()
                formatter.numberStyle = NumberFormatter.Style.decimal
                
                formatter.locale = Locale(identifier: "fr_FR")
                
                guard let formattedString = formatter.string(for: Int(fetchedCount)) else { return }
                
                self.amountOfViewsLabel.text = formattedString + " views"
            } catch {
                print(error)
            }
        }
    }

    //MARK: - Configure UI
    
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
    
    func addVideoPlayerView(playlistID: String) {
        
        let player = YouTubePlayerHostingView(source: .playlist(id: playlistID), configuration: .init(autoPlay: false, showControls: false, loopEnabled: false))
        self.hostingView = player
        
        
        hostingView.frame = videoView.bounds
        videoView.addSubview(hostingView)
    }
    
    func setDuration() {
        hostingView.player.getDuration { result in
            switch result {
            case .success(let success):
                let date = Date()
                let cal = Calendar(identifier: .gregorian)
                let start = cal.startOfDay(for: date)
                let newDate = start.addingTimeInterval(success)
                let formatter = DateFormatter()
                formatter.dateFormat = "mm:ss"
                let resultString = formatter.string(from: newDate)
                
                self.fullTimeLabel.text = resultString
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    func getElapsedTime() {
        hostingView.player.getCurrentTime(completion: { result in
            switch result {
            case .success(let success):
                let date = Date()
                let cal = Calendar(identifier: .gregorian)
                let start = cal.startOfDay(for: date)
                let newDate = start.addingTimeInterval(success)
                let formatter = DateFormatter()
                formatter.dateFormat = "mm:ss"
                let resultString = formatter.string(from: newDate)
                
                self.recentTimeLabel.text = resultString
            case .failure(let failure):
                print(failure)
            }
        })
    }
    
    func configureMetadata(completion: @escaping (_ name: String) -> Void) {

        
        hostingView.player.getPlaybackMetadata { result in
            switch result {
                
            case .success(let playbackMetadata):
                
                completion(playbackMetadata.title)
            case .failure(let youTubePlayerAPIError):
                print("Error", youTubePlayerAPIError)
            }
        }
    }
    
    @MainActor
    private func setVideoName(_ name: String) {
        self.videoNameLabel.text = name
    }
}


