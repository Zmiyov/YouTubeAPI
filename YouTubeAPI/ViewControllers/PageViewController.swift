//
//  PageViewController.swift
//  YouTubeAPI
//
//  Created by Vladimir Pisarenko on 04.10.2022.
//

import UIKit

class MyPageViewController: UIPageViewController {
    
    let colors: [UIColor] = [
        .red,
        .green,
        .blue,
        .cyan
    ]
    
    let networkManager = NetworkController()
    
//    let channelNames: [String] = ["CodeWithChris", "voalearningenglish", "ptuxermann", "Apple"]
    let query = "surfing"
    var channels = [SearchModel]()
    
    var pages: [UIViewController] = [UIViewController]()
    
    var tTime: Timer!
    var index = 0
    
    override init(transitionStyle style: UIPageViewController.TransitionStyle, navigationOrientation: UIPageViewController.NavigationOrientation, options: [UIPageViewController.OptionsKey : Any]? = nil) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = nil

//        getChannels { [self] success in
////            print("Channel", channels)
//            DispatchQueue.main.async { [self] in
//                showChannels { [self] success in
//                    self.tTime = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(changeSlide), userInfo: nil, repeats: true)
//                }
//            }
//        }
        
        getChannels { [self] success in
            
            getUploadsAndSubscriberCount { [self] success in
                
                    showChannels { [self] success in
                        self.tTime = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(changeSlide), userInfo: nil, repeats: true)
                    }
                
            }

  
        }
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
    
    func getUploadsAndSubscriberCount(completion: @escaping (_ success: Bool) -> Void) {
        for i in 0..<channels.count {
            Task {
                do {
                    guard let id = channels[i].channelId else { return }
                    let fetchedCount = try await networkManager.getChannels(channelId: id)
                   
                    channels[i].uploads = fetchedCount.uploads
                    channels[i].subscriberCount = fetchedCount.subscriberCount
                    print(fetchedCount.uploads)
                    print(fetchedCount.subscriberCount)
                } catch {
                    print(error)
                }
            }
        }
        completion(true)
    }
    
    func showChannels(completion: @escaping (_ success: Bool) -> Void) {
        for i in 0..<channels.count {
            let vc = ExampleViewController()
            vc.channelNameLabel.text = channels[i].channelTitle
            vc.amoontOfSubscribersLabel.text = channels[i].subscriberCount
//            vc.view.backgroundColor = colors[i]
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
        completion(true)
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
        
        return firstVCIndex
    }
}
