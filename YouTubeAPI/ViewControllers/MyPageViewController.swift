//
//  PageViewController.swift
//  YouTubeAPI
//
//  Created by Vladimir Pisarenko on 04.10.2022.
//

import UIKit

protocol MyPageViewControllerDelegate {
    func myPageViewControllerDelegate(_ controller: MyPageViewController, didSelect playlistId: String)
}

class MyPageViewController: UIPageViewController {
    
    
    var pages: [UIViewController] = [UIViewController]()
    var currentControllerIndex = 0
    
    var delegatePlaylistId: MyPageViewControllerDelegate?
    
    let networkManager = NetworkController()
    
    let query = "surfing"
    var channels = [SearchModel]()
    let myGroup = DispatchGroup()
    
    var tTime: Timer!
    var index = 0
    
    override init(transitionStyle style: UIPageViewController.TransitionStyle, navigationOrientation: UIPageViewController.NavigationOrientation, options: [UIPageViewController.OptionsKey : Any]? = nil) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    //MARK: - View DidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = nil
        
        getChannels { [self] success in
            getUploadsAndSubscriberCount()
        }
        self.tTime = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(changeSlide), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        tTime.invalidate()
    }
    
    @objc func changeSlide() {
        index += 1
        if index < self.pages.count {
            setViewControllers([pages[index]], direction: .forward, animated: true, completion: nil)
        }
        else {
            index = 0
            setViewControllers([pages[0]], direction: .forward, animated: true, completion: nil)
        }
    }
    
    //MARK: - Fetching Data
    
    func getChannels(completion: @escaping (_ success: Bool) -> Void) {
        
        Task {
            do {
                let searchResponse = try await networkManager.getSearchResponse(query: self.query)
                guard let channels = searchResponse.items else { return }
                self.channels = channels
                completion(true)
            } catch {
                print(error)
            }
        }
    }
    
    func getUploadsAndSubscriberCount() {
        for i in 0..<channels.count {
            myGroup.enter()
            
            Task {
                do {
                    guard let id = channels[i].channelId else { return }
                    let fetchedCount = try await networkManager.getChannels(channelId: id)
                   
                    channels[i].allVideoUploadsPlaylistId = fetchedCount.allVideoUploadsPlaylistId
                    channels[i].subscriberCount = fetchedCount.subscriberCount

                    myGroup.leave()
                } catch {
                    print(error)
                }
            }
        }
        myGroup.notify(queue: .main) {
            
            self.showChannels()
        }
    }
    
    func showChannels() {
        
        for i in 0..<channels.count {
            let vc = ExampleViewController()
            vc.playlistId = channels[currentControllerIndex].channelId
            vc.channelNameLabel.text = channels[i].channelTitle
            
            guard let subscriberCount = channels[i].subscriberCount else { return }
            
            let formatter = NumberFormatter()
            formatter.numberStyle = NumberFormatter.Style.decimal
            formatter.locale = Locale(identifier: "fr_FR")
            guard let formattedString = formatter.string(for: Int(subscriberCount)) else { return }
            vc.amoontOfSubscribersLabel.text = formattedString + " subscribers"
            
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapChannel))
            vc.view.addGestureRecognizer(tapGestureRecognizer)
            
            let urlString = channels[i].thumbnail!
            
            Task {
                do {
                    vc.backgroungImage.image = try await networkManager.fetchImage(url: urlString )
                } catch {
                    print(error)
                }
            }
            
            pages.append(vc)
        }
        
    }
    
    @objc func tapChannel() {
        var info = [String: String]()
        info["id"] = channels[currentControllerIndex].allVideoUploadsPlaylistId
        NotificationCenter.default.post(name: .playlistID, object: nil, userInfo: info)
    }
}

//MARK: -  Page View Controller Data Source

extension MyPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else { return pages.last }
        
        guard pages.count > previousIndex else { return nil }
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < pages.count else { return pages.first }
        
        guard pages.count > nextIndex else { return nil }
        
        return pages[nextIndex]
    }
}

//MARK: - Page View Controller Delegate

extension MyPageViewController: UIPageViewControllerDelegate {
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pages.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        
        guard let firstVC = pageViewController.viewControllers?.first else {
            return 0
        }
        guard let firstVCIndex = pages.firstIndex(of: firstVC) else {
            return 0
        }
        
        self.currentControllerIndex = firstVCIndex
        
        guard let currentPlaylistID = channels[firstVCIndex].channelId else  { return firstVCIndex }
        
        self.delegatePlaylistId?.myPageViewControllerDelegate(self, didSelect: currentPlaylistID)
        
        return firstVCIndex
    }
    
}

extension Notification.Name {
    static let playlistID = Notification.Name("playlistID")
}
