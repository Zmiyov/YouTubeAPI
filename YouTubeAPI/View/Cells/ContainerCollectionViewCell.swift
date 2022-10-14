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
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        
        return view
    }()

    var thePageVC: MyPageViewController!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(myContainerView)
        
        setPageVC()
        myContainerView.addSubview(thePageVC.view)

        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setPageVC() {
        thePageVC = MyPageViewController()
        thePageVC.delegatePlaylistId = self
        thePageVC.view.translatesAutoresizingMaskIntoConstraints = false
        thePageVC.view.layer.cornerRadius = 8
        thePageVC.view.clipsToBounds = true
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            myContainerView.topAnchor.constraint(equalTo: topAnchor, constant: 20.0),
            myContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            myContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            myContainerView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 0.65)
            ])
        
        NSLayoutConstraint.activate([
            thePageVC.view.topAnchor.constraint(equalTo: myContainerView.topAnchor, constant: 0.0),
            thePageVC.view.leadingAnchor.constraint(equalTo: myContainerView.leadingAnchor, constant: 0.0),
            thePageVC.view.trailingAnchor.constraint(equalTo: myContainerView.trailingAnchor, constant: 0.0),
            thePageVC.view.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 0.65)
            ])
    }
}

extension ContainerCollectionViewCell: MyPageViewControllerDelegate {
    func myPageViewControllerDelegate(_ controller: MyPageViewController, didSelect playlistId: String) {
        self.playlistId = playlistId
    }
}
