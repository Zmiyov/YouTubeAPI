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
        .cyan,
        .yellow,
        .orange
    ]
    
    var pages: [UIViewController] = [UIViewController]()
    
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
            vc.theLabel.text = "Page: \(i)"
            vc.view.backgroundColor = colors[i]
            pages.append(vc)
        }
        
        setViewControllers([pages[0]], direction: .forward, animated: false, completion: nil)
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
