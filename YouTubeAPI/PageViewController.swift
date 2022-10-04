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
        
        // instantiate "pages"
        for i in 0..<colors.count {
            let vc = ExampleViewController()
            vc.channelNameLabel.text = "Page: \(i)"
            vc.amoontOfSubscribersLabel.text = "1 000 000" + " " + "Subscribers"
            vc.view.backgroundColor = colors[i]
            pages.append(vc)
        }
        
        setViewControllers([pages[0]], direction: .forward, animated: false, completion: nil)
        tTime = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(changeSlide), userInfo: nil, repeats: true)

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
    
}

// typical Page View Controller Data Source
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

// typical Page View Controller Delegate
extension MyPageViewController: UIPageViewControllerDelegate {
    
    // if you do NOT want the built-in PageControl (the "dots"), comment-out these funcs
    
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
