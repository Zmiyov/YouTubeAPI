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
    var playingVideoIndex = 0
    
    var fullTime: Int?
    var elapsedTime: Int?
    var timelineTimer: Timer?
    var timelineValue: Timer?
    
    var viewCount: String?
    let serialQueue = DispatchQueue(label: "serialQueue")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addVideoPlayerView(playlistID: self.playlistID)
        configureGradientLayer()
        
        let timelineSliderThumbImage = UIImage(named: "Line.png")
        timeLineSlider.setThumbImage(timelineSliderThumbImage, for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateUIfromAPI()
        self.updateAllUI()
    }
    
    
    //MARK: - Actions
    
    @IBAction func openCloseButtonTapped(_ sender: UIButton) {
        if playingState == true {
            hostingView.player.pause()
            playingState = false
            playPauseButton.setImage(UIImage(named: "Play"), for: .normal)
        }
    }
    
    @IBAction func timelineSlider(_ sender: UISlider) {
        guard let duration = self.fullTime else { return }
        let seekValue = round(Double(duration) * Double(sender.value))
        self.hostingView.player.seek(to: seekValue, allowSeekAhead: false)
    }
    
    @IBAction func previousVideoButton(_ sender: UIButton) {
        playPauseButton.setImage(UIImage(named: "Pause"), for: .normal)
        hostingView.player.previousVideo()
        playingState = true
        
        if self.playingVideoIndex > 0 {
            self.playingVideoIndex -= 1
        }
        
        self.updateUIfromAPI()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.updateAllUI()
        }
        
        self.timelineTimer?.invalidate()
        self.timelineTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.setTimelineSlider), userInfo: nil, repeats: true)
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
        
        if self.playingVideoIndex <= self.playlistVideosIds.count {
            self.playingVideoIndex += 1
        }
        
        self.updateUIfromAPI()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.updateAllUI()
        }
        
        self.timelineTimer?.invalidate()
        self.timelineTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.setTimelineSlider), userInfo: nil, repeats: true)
    }
  
    @IBAction func volumeSlider(_ sender: UISlider) {
        let volume = Int(sender.value * 100)
        print(volume)
        hostingView.player.set(volume: volume)
    }
    
    //MARK: - Set UI
    
    func setNewPlaylist() {
        if let playlistFromChannel = self.playlistFromChannel {
            hostingView.player.source = .playlist(id: playlistFromChannel)
            hostingView.player.configuration.autoPlay = true
            self.playingVideoIndex = 0
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.updateUIfromAPI()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.updateAllUI()
            }
            
            self.timelineTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.setTimelineSlider), userInfo: nil, repeats: true)
        }
    }
    
    func updateUIfromAPI() {
        
        Task {
            do {
                //Get playlist ids
                let playlistIdArray = try await getPlaylistVideosIds()
                self.setPlaylistVideosIds(playlistIdArray)
                
                //Get title
                let videoIdForTitle = self.playlistVideosIds[self.playingVideoIndex]
                let fetchedTitle = try await networkController.getTitleOfVideo(videoId: videoIdForTitle)

                //Get views count
                let videoId = self.playlistVideosIds[self.playingVideoIndex]
                let fetchedCount = try await networkController.getViewCountVideos(videoId: videoId)
                
                //Set ui
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    
                    self.setVideoName(fetchedTitle)
                    self.setViewCount(fetchedCount)
                }
                
            } catch {
                print(error)
            }
        }
    }
    
    func updateAllUI() {
        
        Task {
            do {
                //Get video duration
                let duration = try await getDuration()
                self.setDuration(duration)
                
                //Get elapded time
                let elapsedTime = try await getElapsedTime()
                self.setElapsedTime(elapsedTime)
            } catch {
                print(error)
            }
        }
    }
    
    //MARK: - Fetch data
    
    func configureMetadata() async throws -> String {
        
        return try await withCheckedThrowingContinuation { (inCont: CheckedContinuation<String, Error>) in
            hostingView.player.getPlaybackMetadata { result in
                switch result {
                case .success(let playbackMetadata):
                    inCont.resume(returning: playbackMetadata.title )
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
    
    func getPlaylistVideosIds() async throws -> [String] {
       
        return try await withCheckedThrowingContinuation { (inCont: CheckedContinuation<[String], Error>) in
            hostingView.player.getPlaylist { result in
                switch result {
                case .success(let success):
                    inCont.resume(returning: success)
                case .failure(let failure):
                    print(failure)
                }
            }
        }
    }
//    @MainActor
    private func setPlaylistVideosIds(_ playlistIdArray: [String]) {
        
        self.playlistVideosIds = playlistIdArray
    }
    
    func getPlayingVideoIndex() async throws -> Int {
        
        return try await withCheckedThrowingContinuation { (inCont: CheckedContinuation<Int, Error>) in
            hostingView.player.getPlaylistIndex { result in
                switch result {
                case .success(let success):
                    inCont.resume(returning: success)
                case .failure(let failure):
                    print(failure)
                }
            }
        }
    }
    
    @MainActor
    private func setViewCount(_ fetchedCount: String) {
        
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.locale = Locale(identifier: "fr_FR")

        guard let formattedString = formatter.string(for: Int(fetchedCount)) else { return }
        self.amountOfViewsLabel.text = formattedString + " views"
    }
    
    func getDuration() async throws -> Double {
        
        return try await withCheckedThrowingContinuation { (inCont: CheckedContinuation<Double, Error>) in
            hostingView.player.getDuration { result in
                switch result {
                case .success(let success):
                    inCont.resume(returning: success)
                case .failure(let failure):
                    print(failure)
                }
            }
        }
    }
    @MainActor
    private func setDuration(_ duration: Double) {
        
        let date = Date()
        let cal = Calendar(identifier: .gregorian)
        let start = cal.startOfDay(for: date)
        let newDate = start.addingTimeInterval(duration)
        let formatter = DateFormatter()
        formatter.dateFormat = "mm:ss"
        let resultString = formatter.string(from: newDate)
        
        self.fullTime = Int(duration)
        self.fullTimeLabel.text = resultString
    }
    
    @objc func getElapsedTime() async throws -> Double {
        
        return try await withCheckedThrowingContinuation { (inCont: CheckedContinuation<Double, Error>) in
            hostingView.player.getCurrentTime(completion: { result in
                switch result {
                case .success(let success):
                    inCont.resume(returning: success)
                case .failure(let failure):
                    print(failure)
                }
            })
        }
    }
    @MainActor
    private func setElapsedTime(_ elapsedTime: Double) {
        
        let date = Date()
        let cal = Calendar(identifier: .gregorian)
        let start = cal.startOfDay(for: date)
        let newDate = start.addingTimeInterval(elapsedTime)
        let formatter = DateFormatter()
        formatter.dateFormat = "mm:ss"
        let resultString = formatter.string(from: newDate)
        
        self.elapsedTime = Int(elapsedTime)
        self.recentTimeLabel.text = resultString
    }

    //MARK: - Configure UI
    
    @MainActor
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
        
        Task{
            let fullTime = try await self.getDuration()
            let secondsInOnePercent = Float(fullTime) / 100
            self.setDuration(fullTime)
            
            let elapsedTime = try await self.getElapsedTime()
            let timeLineValue = (Float(elapsedTime) / secondsInOnePercent)
            timeLineSlider.value = Float(timeLineValue)
            self.setElapsedTime(elapsedTime)
        }
    }
    
    @MainActor
    func addVideoPlayerView(playlistID: String) {
        let player = YouTubePlayerHostingView(source: .playlist(id: playlistID), configuration: .init(autoPlay: false, showControls: false, loopEnabled: false))
        self.hostingView = player
        hostingView.frame = videoView.bounds
        videoView.addSubview(hostingView)
    }
}
