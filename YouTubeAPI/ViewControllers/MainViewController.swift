//
//  ViewController.swift
//  YouTubeAPI
//
//  Created by Vladimir Pisarenko on 04.10.2022.
//


import UIKit

class MainViewController: UIViewController {
    
    enum SupplementaryViewKind {
        static let header = "header"
    }
        
    // MARK: Section Definitions
    enum Section: Hashable {
        case uiPageVC
        case landscape(String)
        case square(String)

    }
    
    enum PlayerState {
        case expanded
        case collapsed
    }

    @IBOutlet var collectionView: UICollectionView!
    
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    
    let playlist1DispatchGroup = DispatchGroup()
    
    var sections = [Section]()
    let networkController = NetworkController()
    var playlistVideos1 = [PlaylistVideoModel]()
    var playlistVideos2 = [PlaylistVideoModel]()
    
    
    var playerViewController: PlayerViewController!
    var visualEffectView: UIVisualEffectView!
    
    let playerViewHandleAreaHeight: CGFloat = 50
    
    var playerVisible = false
    var playerNextState: PlayerState {
        return playerVisible ? .collapsed : .expanded
    }
    
    var runningAnimations = [UIViewPropertyAnimator]()
    var animationProgressWhenInterrupted: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let darkGrey = UIColor(red: 29.0/255.0, green: 27.0/255.0, blue: 38.0/255.0, alpha: 1.0)
        collectionView.backgroundColor = darkGrey
        
       
        // MARK: Collection View Setup
        collectionView.collectionViewLayout = createLayout()
        
        collectionView.register(ContainerCollectionViewCell.self, forCellWithReuseIdentifier: ContainerCollectionViewCell.reuseIdentifier)
        collectionView.register(LandscapeImageCollectionViewCell.self, forCellWithReuseIdentifier: LandscapeImageCollectionViewCell.reuseIdentifier)
        collectionView.register(SquareImageCollectionViewCell.self, forCellWithReuseIdentifier: SquareImageCollectionViewCell.reuseIdentifier)
        collectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: SupplementaryViewKind.header, withReuseIdentifier: SectionHeaderView.reuseIdentifier)
                

        fetchPlaylist1(playlistId: Constants.iosAcadememyPlaylistId) { success in
            self.getViewCount1()
//            self.configureDataSource()
        }
        
        fetchPlaylist2(playlistId: Constants.infoCarPlaylistId) { success in
            self.getViewCount2()
        }

        
        setupPlayer()
    }
    
    //MARK: - Fetching Data
    
    func fetchPlaylist1(playlistId: String, completion: @escaping (_ success: Bool) -> Void) {
        
        Task {
            do {
                let fetchedPlaylist = try await networkController.getPlaylistVideos(playlistId: playlistId)
                guard let playlistVideos = fetchedPlaylist.items else { return }
                playlistVideos1 = playlistVideos
//                print(self.playlistVideos1)
                completion(true)
            } catch {
                print(error)
            }
        }
    }
    
    func fetchPlaylist2(playlistId: String, completion: @escaping (_ success: Bool) -> Void) {
        
        Task {
            do {
                let fetchedPlaylist = try await networkController.getPlaylistVideos(playlistId: playlistId)
                guard let playlistVideos = fetchedPlaylist.items else { return }
                playlistVideos2 = playlistVideos
//                print(self.playlistVideos2)
                completion(true)
            } catch {
                print(error)
            }
        }
    }
    
    func getViewCount1() {
//        print("Count")
        for i in 0..<playlistVideos1.count {
            playlist1DispatchGroup.enter()
            
            Task {
                do {
                    guard let id = playlistVideos1[i].videoId else { return }
                    let fetchedCount = try await networkController.getViewCountVideos(videoId: id)
                   
                    playlistVideos1[i].viewCount = fetchedCount
//                    print(fetchedCount)
                    playlist1DispatchGroup.leave()
                } catch {
                    print(error)
                }
            }
        }
        playlist1DispatchGroup.notify(queue: .main) {
            
            print(self.playlistVideos1)
            self.configureDataSource()
            print("Finished playlist 1 requests.")
        }
    }
    
    func getViewCount2() {
//        print("Count")
        for i in 0..<playlistVideos2.count {
            Task {
                do {
                    guard let id = playlistVideos2[i].videoId else { return }
                    let fetchedCount = try await networkController.getViewCountVideos(videoId: id)
                   
                    playlistVideos2[i].viewCount = fetchedCount
//                    print("2", fetchedCount)
                    
                } catch {
                    print(error)
                }
            }
        }
    }
    
    //MARK: - Collection View Data Source
    
    func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            
            let supplementaryItemContentInsets = NSDirectionalEdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4)
            
            let headerItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
            let headerItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerItemSize, elementKind: SupplementaryViewKind.header, alignment: .top)
            headerItem.contentInsets = supplementaryItemContentInsets
            
            let section = self.sections[sectionIndex]
            
            switch section {
            case .uiPageVC:
                //MARK: Promoted Section Layout
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.92), heightDimension: .fractionalWidth(0.5))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 1)
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .groupPagingCentered
                
                section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 30, trailing: 0)
                
                return section
                
            case .landscape:
                //MARK: Lanscape Section Layout
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.46), heightDimension: .fractionalWidth(0.4))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, repeatingSubitem: item, count: 1)
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .groupPaging
                section.boundarySupplementaryItems = [headerItem]
                
                section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 15, bottom: 30, trailing: 0)
                
                return section
            case .square:
                //MARK: Square Section Layout
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.46), heightDimension: .fractionalWidth(0.55))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, repeatingSubitem: item, count: 1)
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .groupPaging
                section.boundarySupplementaryItems = [headerItem]
                
                section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 15, bottom: 20, trailing: 0)
                
                return section
            }
        }
        return layout
    }
    
    func configureDataSource() {
        // MARK: Data Source Initialization
        dataSource = .init(collectionView: collectionView, cellProvider: { (collectionView, indexPath, item) -> UICollectionViewCell? in
            let section = self.sections[indexPath.section]
            switch section {
            case .uiPageVC:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ContainerCollectionViewCell.reuseIdentifier, for: indexPath) as! ContainerCollectionViewCell
                
                return cell
            case .landscape:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LandscapeImageCollectionViewCell.reuseIdentifier, for: indexPath) as! LandscapeImageCollectionViewCell

                cell.configureCell(self.playlistVideos1[indexPath.row], networkManager: self.networkController)
                print("Configure")
                print(self.playlistVideos1[indexPath.row])
                return cell
            case .square:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SquareImageCollectionViewCell.reuseIdentifier, for: indexPath) as! SquareImageCollectionViewCell

                cell.configureCell(self.playlistVideos2[indexPath.row])
                
                return cell
            }
        })
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath -> UICollectionReusableView? in
            switch kind {
            case SupplementaryViewKind.header:
                let section = self.sections[indexPath.section]
                let sectionName: String
                switch section {
                case .uiPageVC:
                    return nil
                case .landscape(let name):
                    sectionName = name
                case .square(let name):
                    sectionName = name
                }
                
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: SupplementaryViewKind.header, withReuseIdentifier: SectionHeaderView.reuseIdentifier, for: indexPath) as! SectionHeaderView
                headerView.setTitle(sectionName)
                return headerView
            default:
                return nil
            }
        }
        
        //MARK: Snapshot definition
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.uiPageVC])
        snapshot.appendItems(Item.promotedApps, toSection: .uiPageVC)
        
        let landscapeSection = Section.landscape("Playlist name 1")
        let squareSection = Section.square("Playlist name 2")
        
        snapshot.appendSections([landscapeSection, squareSection])
        snapshot.appendItems(Item.landscapePlaylist, toSection: landscapeSection)
        snapshot.appendItems(Item.squarePlaylist, toSection: squareSection)
        sections = snapshot.sectionIdentifiers
        dataSource.apply(snapshot)
    }
    
    //MARK: - Setup player VC
    
    func setupPlayer() {
        
        playerViewController = PlayerViewController(nibName: "PlayerViewController", bundle: nil)
        self.addChild(playerViewController)
        self.view.addSubview(playerViewController.view)
        
        playerViewController.view.frame = CGRect(x: 5, y: self.view.frame.height - playerViewHandleAreaHeight, width: self.view.bounds.width - 10, height: self.view.frame.height - self.view.safeAreaInsets.top)
        
        playerViewController.view.clipsToBounds = true
        self.playerViewController.view.layer.cornerRadius = 12
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(MainViewController.handleCardPan(recognizer:)))
        playerViewController.handleArea.addGestureRecognizer(panGestureRecognizer)
        
        playerViewController.openCloseButton.addTarget(self, action: #selector(MainViewController.handleButtonTap), for: .touchUpInside)
    }
    
    @objc func handleButtonTap() {
        animateTransitionIfNeeded(state: playerNextState, duration: 0.9)
    }
    
    func deleteVisualEffect(state: PlayerState) {
        switch state {
        case .expanded:
            visualEffectView = UIVisualEffectView()
            visualEffectView.tag = 100
            visualEffectView.frame = self.view.frame
            self.view.insertSubview(visualEffectView, at: 1)

        case .collapsed:
            if let viewWithTag = self.view.viewWithTag(100) {
                viewWithTag.removeFromSuperview()
            }
        }
    }
    
    func changeButtonImage(state: PlayerState) {
        switch state {
        case .expanded:
            let image = UIImage(named: "Close_Open.png")
            playerViewController.openCloseButton.setImage(image, for: .normal)
        case .collapsed:
            let image = UIImage(named: "Close_Open_mirror.png")
            playerViewController.openCloseButton.setImage(image, for: .normal)
        }
    }
    
    @objc
    func handleCardPan (recognizer:UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            startInteractiveTransition(state: playerNextState, duration: 0.9)
        case .changed:
            let translation = recognizer.translation(in: self.playerViewController.handleArea)
            var fractionComplete = translation.y / (self.view.frame.height - self.view.safeAreaInsets.top)
            fractionComplete = playerVisible ? fractionComplete : -fractionComplete
            updateInteractiveTransition(fractionCompleted: fractionComplete)
        case .ended:
            continueInteractiveTransition()
        default:
            break
        }
    }
    
    func animateTransitionIfNeeded (state: PlayerState, duration: TimeInterval) {
        
        deleteVisualEffect(state: state)
        changeButtonImage(state: state)
        
        if runningAnimations.isEmpty {
            let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                
                switch state {
                case .expanded:
                    self.playerViewController.view.frame.origin.y = self.view.safeAreaInsets.top
                case .collapsed:
                    self.playerViewController.view.frame.origin.y = self.view.frame.height - self.playerViewHandleAreaHeight
                    
                }
            }
            
            frameAnimator.addCompletion { _ in
                self.playerVisible = !self.playerVisible
                self.runningAnimations.removeAll()
            }
            frameAnimator.startAnimation()
            runningAnimations.append(frameAnimator)
            
            let blurAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                switch state {
                case .expanded:
                    self.visualEffectView.effect = UIBlurEffect(style: .light)
                case .collapsed:
                    self.visualEffectView.effect = nil
                }
            }
            blurAnimator.startAnimation()
            runningAnimations.append(blurAnimator)
        }
    }
    
    func startInteractiveTransition(state: PlayerState, duration: TimeInterval) {
        if runningAnimations.isEmpty {
            animateTransitionIfNeeded(state: state, duration: duration)
        }
        for animation in runningAnimations {
            animation.pauseAnimation()
            animationProgressWhenInterrupted = animation.fractionComplete
        }
    }

    func updateInteractiveTransition(fractionCompleted: CGFloat) {
        for animation in runningAnimations {
            animation.fractionComplete = fractionCompleted + animationProgressWhenInterrupted
        }
    }

    func continueInteractiveTransition() {
        for animation in runningAnimations {
            animation.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
    }
    
}

