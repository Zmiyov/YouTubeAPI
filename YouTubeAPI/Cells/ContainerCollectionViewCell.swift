//
//  ContainerCollectionViewCell.swift
//  YouTubeAPI
//
//  Created by Vladimir Pisarenko on 04.10.2022.
//

import UIKit

class ContainerCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "ContainerCollectionViewCell"
    
    let myContainerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .clear
        return v
    }()

    var thePageVC: MyPageViewController!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(myContainerView)
        
        NSLayoutConstraint.activate([
            myContainerView.topAnchor.constraint(equalTo: topAnchor, constant: 20.0),
            myContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            myContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            myContainerView.heightAnchor.constraint(equalToConstant: 200.0),
            ])
        
        thePageVC = MyPageViewController()
//        addChild(thePageVC)
        
        thePageVC.view.translatesAutoresizingMaskIntoConstraints = false
        
        myContainerView.addSubview(thePageVC.view)
        
        NSLayoutConstraint.activate([
            thePageVC.view.topAnchor.constraint(equalTo: myContainerView.topAnchor, constant: 0.0),
            thePageVC.view.bottomAnchor.constraint(equalTo: myContainerView.bottomAnchor, constant: 0.0),
            thePageVC.view.leadingAnchor.constraint(equalTo: myContainerView.leadingAnchor, constant: 0.0),
            thePageVC.view.trailingAnchor.constraint(equalTo: myContainerView.trailingAnchor, constant: 0.0),
            ])
        
//        thePageVC.didMove(toParent: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
    //    let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    //    pageViewController.view.frame = view.frame//set frame
    //    self.addChildViewController(pageViewController)
    //    view.addSubview(pageViewController.view)
    //    pageViewController.didMove(toParentViewController: self)
        
//        func display(contentController content: UIViewController, on view: UIView) {
//            self.addChildViewController(content)
//            content.view.frame = view.bounds
//            view.addSubview(content.view)
//            content.didMove(toParentViewController: self)
//        }
}
