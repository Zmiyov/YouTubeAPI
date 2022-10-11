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
    var playlistVideosIds = [String]()
    var playingVideoIndex: Int?

    
    var fullTime: Int?
    var elapsedTime: Int?
    var timelineTimer: Timer?
    var timelineValue: Timer?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        addVideoPlayerView(playlistID: self.playlistID)
        
        print("did channel")
        
        let timelineSliderThumbImage = UIImage(named: "Line.png")
        timeLineSlider.setThumbImage(timelineSliderThumbImage, for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getPlaylistVideosIds()
        
        print("will channel")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        getPlayingVideoIndex()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("layout channel")
        configureGradientLayer()
        getViewCount()
        setDuration()
        getElapsedTime()
        
        if let playlistFromChannel = playlistFromChannel {
            hostingView.player.source = .playlist(id: playlistFromChannel)
            hostingView.player.configuration.autoPlay = true
        }
        
        Task {
            configureMetadata { name in
                self.setVideoName(name)
            }
        }
    }
    
    //MARK: - Actions
    
    @IBAction func openCloseButtonTapped(_ sender: UIButton) {
        if playingState == true {
            hostingView.player.pause()
            playingState = false
            playPauseButton.setImage(UIImage(named: "Play"), for: .normal)
        }
    }
    
    @IBAction func previousVideoButton(_ sender: UIButton) {
        playPauseButton.setImage(UIImage(named: "Pause"), for: .normal)
        hostingView.player.previousVideo()
        playingState = true
        
        self.setDuration()
        self.getElapsedTime()
        self.getPlayingVideoIndex()
        self.getViewCount()
    }
    
    @IBAction func playPauseButton(_ sender: UIButton) {
        
        if playingState == false {
            hostingView.player.play()
            playingState = true
            playPauseButton.setImage(UIImage(named: "Pause"), for: .normal)
            
            self.timelineTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.setTimelineSlider), userInfo: nil, repeats: true)
            self.timelineValue = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.setTimelineSlider), userInfo: nil, repeats: true)
            

        } else {
            hostingView.player.pause()
            playingState = false
            playPauseButton.setImage(UIImage(named: "Play"), for: .normal)
            self.timelineTimer?.invalidate()
            self.timelineValue?.invalidate()
        }
    }
    
    @IBAction func nextVideoButton(_ sender: UIButton) {
        playPauseButton.setImage(UIImage(named: "Pause"), for: .normal)
        hostingView.player.nextVideo()
        playingState = true
        
        self.setDuration()
        self.getElapsedTime()
        self.getPlayingVideoIndex()
        self.getViewCount()
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
                guard let index = playingVideoIndex else { return }
                let videoId = playlistVideosIds[index]
                let fetchedCount = try await networkController.getViewCountVideos(videoId: videoId)
                
                let formatter = NumberFormatter()
                formatter.numberStyle = NumberFormatter.Style.decimal
                
                formatter.locale = Locale(identifier: "fr_FR")
                
                guard let formattedString = formatter.string(for: Int(fetchedCount)) else { return }
                
                self.setViewCount(formattedString)
            } catch {
                print(error)
            }
        }
    }
    
    func getPlaylistVideosIds() {
        
        hostingView.player.getPlaylist { result in
            switch result {
            case .success(let success):
                self.playlistVideosIds = success
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    func getPlayingVideoIndex() {
        hostingView.player.getPlaylistIndex { result in
            switch result {
            case .success(let success):
                self.playingVideoIndex = success
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    func getData() {
        
        hostingView.player.getInformation { result in
            switch result {
            case .success(let success):
                let volume = success.volume
                print(volume)
                let duration = success.duration
                print(duration)
                let currentTime = success.currentTime
                print("current", currentTime)
                let videoUrl = success.videoUrl
                print(videoUrl)
            case .failure(let failure):
                print(failure)
            }
        }
    }

    //MARK: - Configure UI
    
    @MainActor
    private func setViewCount(_ formattedString: String) {
        self.amountOfViewsLabel.text = formattedString + " views"
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
    
    @MainActor
    @objc func setTimelineSlider() {
        guard let fullTime = self.fullTime else { return }
        let secondsInOnePercent = Float(fullTime) / 100
        guard let elapsedTime = self.elapsedTime else { return }
        
        let timeLineValue = (Float(elapsedTime) / secondsInOnePercent)
        timeLineSlider.value = Float(timeLineValue)
    }
    
    @MainActor
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
                print("DuraTion", success)
                let date = Date()
                let cal = Calendar(identifier: .gregorian)
                let start = cal.startOfDay(for: date)
                let newDate = start.addingTimeInterval(success)
                let formatter = DateFormatter()
                formatter.dateFormat = "mm:ss"
                let resultString = formatter.string(from: newDate)
                
                self.setFullTime(resultString)
                self.fullTime = Int(success)
                
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    @MainActor
    private func setFullTime(_ duration: String) {
        self.fullTimeLabel.text = duration
    }
    
    @objc func getElapsedTime() {
        hostingView.player.getCurrentTime(completion: { result in
            switch result {
            case .success(let success):
                print("Elapsed", success)
                let date = Date()
                let cal = Calendar(identifier: .gregorian)
                let start = cal.startOfDay(for: date)
                let newDate = start.addingTimeInterval(success)
                let formatter = DateFormatter()
                formatter.dateFormat = "mm:ss"
                let resultString = formatter.string(from: newDate)
                
                self.setRecentTime(resultString)
                print(success )
                self.elapsedTime = Int(success)
                
            case .failure(let failure):
                print(failure)
            }
        })
    }
    
    @MainActor
    private func setRecentTime(_ time: String) {
        self.recentTimeLabel.text = time
    }
    
    func configureMetadata(completion: @escaping (_ name: String) -> Void) async throws {

        Task {
            hostingView.player.getPlaybackMetadata { result in
                switch result {
                    
                case .success(let playbackMetadata):
                    completion(playbackMetadata.title)
                    
                case .failure(let youTubePlayerAPIError):
                    print("Error", youTubePlayerAPIError)
                }
            }
        }
    }
    
    @MainActor
    private func setVideoName(_ name: String) {
        self.videoNameLabel.text = name
    }
}

extension DispatchQueue {
    static public func asyncMainIfNeeded(work: @escaping () -> Void) {
        if Thread.isMainThread {
            work()
            return
        }
        DispatchQueue.main.async {
            work()
        }
    }
}


