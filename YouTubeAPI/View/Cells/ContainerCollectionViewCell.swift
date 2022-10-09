//
//  ContainerCollectionViewCell.swift
//  YouTubeAPI
//
//  Created by Vladimir Pisarenko on 04.10.2022.
//

import UIKit

class ContainerCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "ContainerCollectionViewCell"
    var playlistId: String?
    
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
        thePageVC.delegatePlaylistId = self
        
        thePageVC.view.translatesAutoresizingMaskIntoConstraints = false
        
        myContainerView.addSubview(thePageVC.view)
        
        NSLayoutConstraint.activate([
            thePageVC.view.topAnchor.constraint(equalTo: myContainerView.topAnchor, constant: 0.0),
            thePageVC.view.bottomAnchor.constraint(equalTo: myContainerView.bottomAnchor, constant: 0.0),
            thePageVC.view.leadingAnchor.constraint(equalTo: myContainerView.leadingAnchor, constant: 0.0),
            thePageVC.view.trailingAnchor.constraint(equalTo: myContainerView.trailingAnchor, constant: 0.0),
            ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension ContainerCollectionViewCell: MyPageViewControllerDelegate {
    func myPageViewControllerDelegate(_ controller: MyPageViewController, didSelect playlistId: String) {
        self.playlistId = playlistId
        print(playlistId)
    }
}
