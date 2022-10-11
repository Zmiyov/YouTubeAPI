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
    
    
    var viewCount: String?
    let viewCountDispatchGroup = DispatchGroup()
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
        
        serialQueue.async {
//            self.getPlaylistVideosIds()
//            self.getPlayingVideoIndex()
            
            self.updateAllUI()
//            self.getViewCount()
        }

        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
//        print("will layout channel")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        print("did layout channel")

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
        print("Previous button")
        updateAllUI()
    }
    
    @IBAction func playPauseButton(_ sender: UIButton) {
        print("Play button")
        updateAllUI()
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
        print("Next button")
        updateAllUI()
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
        }
    }
    
    func updateAllUI() {
        print("Update all ui")
        
        getDuration()
        getElapsedTime()
        
        Task {
            do {
                print("task title")
                let title = try await configureMetadata()
                print("Title", title)
                setVideoName(title)
            } catch {
                print(error)
            }
        }
        
        Task {
            do {
                print("task playlistIdArray")
                let playlistIdArray = try await getPlaylistVideosIds()
                print("playlistIdArray", playlistIdArray)
                setPlaylistVideosIds(playlistIdArray)
            } catch {
                print(error)
            }
        }
        
        Task {
            do {
                //Get video index
                print("task playingVideoIndex")
                let index = try await getPlayingVideoIndex()
                print("playingVideoIndex", index)
                setPlayingVideoIndex(index)
                
                //Get views count
                let videoId = playlistVideosIds[index]
                let fetchedCount = try await networkController.getViewCountVideos(videoId: videoId)
                print("fetched count", fetchedCount)
                //Set views count
                self.viewCount = fetchedCount
                self.setViewCount(fetchedCount)
            } catch {
                print(error)
            }
        }
//
//        Task {
//
//            do {
//                print("task view count")
//                guard let index = self.playingVideoIndex else { return }
//                let videoId = playlistVideosIds[index]
//                let fetchedCount = try await networkController.getViewCountVideos(videoId: videoId)
//
//                print("fetched count", fetchedCount)
//                self.viewCount = fetchedCount
//                self.setViewCount(fetchedCount)
//            } catch {
//                print(error)
//            }
//        }

    }
    
    //MARK: - fetch data
    
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
        print("setvideoname")
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
    
    @MainActor
    private func setPlaylistVideosIds(_ playlistIdArray: [String]) {
        print("setPlaylistVideosIds")
        self.playlistVideosIds = playlistIdArray
    }
    
    
    
    func getPlayingVideoIndex() async throws -> Int{
        print("getPlayingVideoIndex")
        return try await withCheckedThrowingContinuation { (inCont: CheckedContinuation<Int, Error>) in
            hostingView.player.getPlaylistIndex { result in
                switch result {
                case .success(let success):
                    inCont.resume(returning: success)
                    print("getPlayingVideoIndex", success)
                case .failure(let failure):
                    print(failure)
                }
            }
        }
    }
    
    @MainActor
    private func setPlayingVideoIndex(_ playingVideoIndex: Int) {
        print("setPlaylistVideosIds")
        self.playingVideoIndex = playingVideoIndex
    }
    
    
    
//    func getViewCount() {
//        print("get view count")
//        viewCountDispatchGroup.enter()
//
//        Task {
//            do {
//                print("Playing video index in view count", self.playingVideoIndex)
//                guard let index = self.playingVideoIndex else { return }
//                let videoId = playlistVideosIds[index]
//                let fetchedCount = try await networkController.getViewCountVideos(videoId: videoId)
//
//                print("fetched count", fetchedCount)
//                self.viewCount = fetchedCount
//                viewCountDispatchGroup.leave()
//            } catch {
//                print(error)
//            }
//        }
//        viewCountDispatchGroup.notify(queue: .main) {
//            print("viewCountDispatchGroup")
//            guard let viewCount = self.viewCount else { return }
//            self.setViewCount(viewCount)
//        }
//    }
    
    @MainActor
    private func setViewCount(_ fetchedCount: String) {
        print("Set view count")
        
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.locale = Locale(identifier: "fr_FR")
        
        print("Fetched count", fetchedCount)

        guard let formattedString = formatter.string(for: Int(fetchedCount)) else { return }
        self.amountOfViewsLabel.text = formattedString + " views"
    }
    
    
    
    func getDuration() {
        print("getDuration")
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
                
                self.setDuration(resultString)
                self.fullTime = Int(success)
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    @MainActor
    private func setDuration(_ duration: String) {
        print("setDuration")
        self.fullTimeLabel.text = duration
    }
    
    
    
    @objc func getElapsedTime() {
        print("getElapsedTime")
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
                
                self.setRecentTime(resultString)
                self.elapsedTime = Int(success)
                
            case .failure(let failure):
                print(failure)
            }
        })
    }
    
    @MainActor
    private func setRecentTime(_ time: String) {
        print("setRecentTime")
        self.recentTimeLabel.text = time
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
    
    
//    func getDuration() {
//        print("getDuration")
//        hostingView.player.getDuration { result in
//            switch result {
//            case .success(let success):
//                let date = Date()
//                let cal = Calendar(identifier: .gregorian)
//                let start = cal.startOfDay(for: date)
//                let newDate = start.addingTimeInterval(success)
//                let formatter = DateFormatter()
//                formatter.dateFormat = "mm:ss"
//                let resultString = formatter.string(from: newDate)
//
//                self.setDuration(resultString)
//                self.fullTime = Int(success)
//            case .failure(let failure):
//                print(failure)
//            }
//        }
//    }
//
//    @MainActor
//    private func setDuration(_ duration: String) {
//        print("setDuration")
//        self.fullTimeLabel.text = duration
//    }
    
//    @objc func getElapsedTime() {
//        print("getElapsedTime")
//        hostingView.player.getCurrentTime(completion: { result in
//            switch result {
//            case .success(let success):
//                let date = Date()
//                let cal = Calendar(identifier: .gregorian)
//                let start = cal.startOfDay(for: date)
//                let newDate = start.addingTimeInterval(success)
//                let formatter = DateFormatter()
//                formatter.dateFormat = "mm:ss"
//                let resultString = formatter.string(from: newDate)
//
//                self.setRecentTime(resultString)
//                self.elapsedTime = Int(success)
//
//            case .failure(let failure):
//                print(failure)
//            }
//        })
//    }
//
//    @MainActor
//    private func setRecentTime(_ time: String) {
//        print("setRecentTime")
//        self.recentTimeLabel.text = time
//    }
    
    

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


