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
        print("did channel")
        
        let timelineSliderThumbImage = UIImage(named: "Line.png")
        timeLineSlider.setThumbImage(timelineSliderThumbImage, for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("will channel")
        
        self.updateAllUI()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        print("will layout channel")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        print("did layout channel")
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

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.updateAllUI()
        }
        
    }
    
    @IBAction func playPauseButton(_ sender: UIButton) {

//        updateAllUI()
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.updateAllUI()
        }
        
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
            updateAllUI()
            self.playingVideoIndex = 0
        }
    }
    
    func updateUIfromAPI() {
        
    }
    
    func updateAllUI() {
        print("Update all ui")
        
        Task {
            do {
                print("task getPlaylistIdArray")
                let playlistIdArray = try await getPlaylistVideosIds()
                print("playlistIdArray", playlistIdArray)
                self.setPlaylistVideosIds(playlistIdArray)
                
//                //Get video index
//                print("task playingVideoIndex")
//                let index = try await getPlayingVideoIndex()
//                print("getPlayingVideoIndex", index)
//                self.setPlayingVideoIndex(index)
                
                print("task title")
                let title = try await configureMetadata()
                print("Title", title)
                self.setVideoName(title)
                
                print("task duration")
                let duration = try await getDuration()
                print("duration", duration)
                self.setDuration(duration)
                
                print("task elapsed time")
                let elapsedTime = try await getElapsedTime()
                print("Elapsed time", elapsedTime)
                self.setElapsedTime(elapsedTime)
                
                //Get views count
                print("task getViewCountVideos")
                let videoId = self.playlistVideosIds[self.playingVideoIndex]
                let fetchedCount = try await networkController.getViewCountVideos(videoId: videoId)
                print("fetched count", fetchedCount)
                //Set views count
                self.setViewCount(fetchedCount)
                
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
        print("set Video name")
        self.videoNameLabel.text = name
    }
    
    func getPlaylistVideosIds() async throws -> [String] {
        print("getPlaylistVideosIds")
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
        print("setPlaylistVideosIds")
        self.playlistVideosIds = playlistIdArray
    }
    
    func getPlayingVideoIndex() async throws -> Int {
//        print("getPlayingVideoIndex")
        return try await withCheckedThrowingContinuation { (inCont: CheckedContinuation<Int, Error>) in
            hostingView.player.getPlaylistIndex { result in
                switch result {
                case .success(let success):
                    inCont.resume(returning: success)
//                    print("getPlayingVideoIndex", success)
                case .failure(let failure):
                    print(failure)
                }
            }
        }
    }
//    @MainActor
    private func setPlayingVideoIndex(_ playingVideoIndex: Int) {
        print("setPlaylistVideosIndex")
        self.playingVideoIndex = playingVideoIndex
    }
    
    @MainActor
    private func setViewCount(_ fetchedCount: String) {
        print("SetViewCount")
        
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.locale = Locale(identifier: "fr_FR")

        guard let formattedString = formatter.string(for: Int(fetchedCount)) else { return }
        self.amountOfViewsLabel.text = formattedString + " views"
    }
    
    func getDuration() async throws -> Double {
        print("getDuration")
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
        print("setDuration")
        
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
        print("getElapsedTime")
        
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
        print("setElapsedTime")
        
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
    
    //MARK: - Get all player data, hasn't used
    
//    func getData() {
//
//        hostingView.player.getInformation { result in
//            switch result {
//            case .success(let success):
//                let volume = success.volume
//                print(volume)
//                let duration = success.duration
//                print(duration)
//                let currentTime = success.currentTime
//                print("current", currentTime)
//                let videoUrl = success.videoUrl
//                print(videoUrl)
//            case .failure(let failure):
//                print(failure)
//            }
//        }
//    }

    //MARK: - Configure UI
    
    @MainActor
    func configureGradientLayer() {
        print("gradient")
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


