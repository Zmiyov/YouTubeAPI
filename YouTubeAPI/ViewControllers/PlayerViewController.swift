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
    
    
//    var hostingView = YouTubePlayerHostingView(source: .playlist(id: ""), configuration: .init(autoPlay: false, showControls: false, loopEnabled: false))
    
    var hostingView: YouTubePlayerHostingView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
//        hostingView.frame = videoView.bounds
//        videoView.addSubview(hostingView)
        
        
        addVideoPlayerView(playlistID: self.playlistID)
        configureMetadata()
        setDuration()
        getElapsedTime()
        getViewCount()
        print("Playlist Id did")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("Will Appear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("Did Appear")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureGradientLayer()
        let timelineSliderThumbImage = UIImage(named: "Line.png")
        timeLineSlider.setThumbImage(timelineSliderThumbImage, for: .normal)

        print("Did layout")
        if let playlistFromChannel = playlistFromChannel {
            print("Playlist id in layout is", playlistFromChannel)
//            addVideoPlayerView(playlistID: playlistFromChannel)
            hostingView.player.source = .playlist(id: "PLHFlHpPjgk71PWkMe6CjZiQjJaUneFS28")
            hostingView.player.configuration.autoPlay = true
        }
    }
    
    //MARK: - Actions
    
    @IBAction func openCloseButtonTapped(_ sender: UIButton) {

    }
    
    @IBAction func previousVideoButton(_ sender: UIButton) {
        playingState = true
        playPauseButton.setImage(UIImage(named: "Pause"), for: .normal)
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
        playingState = true
        playPauseButton.setImage(UIImage(named: "Pause"), for: .normal)
        hostingView.player.nextVideo()
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
//                print(String(describing: formattedString))
                
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


