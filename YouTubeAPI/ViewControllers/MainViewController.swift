//
//  ViewController.swift
//  YouTubeAPI
//
//  Created by Vladimir Pisarenko on 04.10.2022.
//


import UIKit
import YouTubePlayerKit

class MainViewController: UIViewController, UICollectionViewDelegate {
    
    private enum SupplementaryViewKind {
        static let header = "header"
    }
        
    // MARK: Section Definitions
    private enum Section: Hashable {
        case uiPageVC
        case landscape(String)
        case square(String)

    }
    
    private enum PlayerState {
        case expanded
        case collapsed
    }

    @IBOutlet var collectionView: UICollectionView!
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    
    private let playlist1DispatchGroup = DispatchGroup()
    private let playlist2DispatchGroup = DispatchGroup()
    
    private var sections = [Section]()
    private let networkController = NetworkManager()

    private var playlistVideos1 = [PlaylistItemsVideoModel]()
    private var playlistVideos2 = [PlaylistItemsVideoModel]()
    
    private var playlist1Title: String?
    private var playlist2Title: String?
    
    private var playerViewController: PlayerViewController!
    private var visualEffectView: UIVisualEffectView!
    
    private let playerViewHandleAreaHeight: CGFloat = 50
    
    private var playerVisible = false
    
    private var runningAnimations = [UIViewPropertyAnimator]()
    private var animationProgressWhenInterrupted: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createSpinnerView()

        let darkGrey = UIColor(red: 29.0/255.0, green: 27.0/255.0, blue: 38.0/255.0, alpha: 1.0)
        collectionView.backgroundColor = darkGrey
        
        collectionView.delegate = self
        collectionView.collectionViewLayout = createLayout()
        
        collectionView.register(ContainerCollectionViewCell.self, forCellWithReuseIdentifier: ContainerCollectionViewCell.reuseIdentifier)
        collectionView.register(LandscapeImageCollectionViewCell.self, forCellWithReuseIdentifier: LandscapeImageCollectionViewCell.reuseIdentifier)
        collectionView.register(SquareImageCollectionViewCell.self, forCellWithReuseIdentifier: SquareImageCollectionViewCell.reuseIdentifier)
        collectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: SupplementaryViewKind.header, withReuseIdentifier: SectionHeaderView.reuseIdentifier)
                
        fetchPlaylist1(playlistId: Constants.iosAcadememyPlaylistId) { success in
            self.getViewCount1()
        }
        fetchPlaylist2(playlistId: Constants.infoCarPlaylistId) { success in
            self.getViewCount2()
        }

        NotificationCenter.default.addObserver(self, selector: #selector(obserber(notification: )), name: .playlistID, object: nil)
        
        setupPlayer(playlistId: "", visibilityState: playerVisible)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc
    private func obserber(notification: Notification) {

        if let dict = notification.userInfo as NSDictionary? {
            if let playlistId = dict["id"] as? String {
                
                self.playerViewController.playingState = true
                self.playerViewController.playlistFromChannel = playlistId
                self.playerViewController.playPauseButton.setImage(UIImage(named: "Pause"), for: .normal)
                self.playerViewController.setNewPlaylist()
                handleButtonTap()
            }
        }
    }
    
    
    //MARK: - Fetching Data
    
    private func fetchPlaylist1(playlistId: String, completion: @escaping (_ success: Bool) -> Void) {
        
        Task {
            do {
                let playlist1Title = try await networkController.getPlaylistTitle(playlistId: Constants.iosAcadememyPlaylistId)
                let fetchedPlaylist = try await networkController.getPlaylistVideos(playlistId: playlistId)
                guard let playlistVideos = fetchedPlaylist.items else { return }
                self.playlistVideos1 = playlistVideos
                self.playlist1Title = playlist1Title
                completion(true)
            } catch {
                print(error)
                Alert.alert(error: error, vc: self)
            }
        }
    }
    
    private func fetchPlaylist2(playlistId: String, completion: @escaping (_ success: Bool) -> Void) {
        
        Task {
            do {
                let playlist2Title = try await networkController.getPlaylistTitle(playlistId: Constants.infoCarPlaylistId)
                let fetchedPlaylist = try await networkController.getPlaylistVideos(playlistId: playlistId)
                guard let playlistVideos = fetchedPlaylist.items else { return }
                self.playlistVideos2 = playlistVideos
                self.playlist2Title = playlist2Title
                completion(true)
            } catch {
                print(error)
                Alert.alert(error: error, vc: self)
            }
        }
    }
    
    private func getViewCount1() {

        for i in 0..<playlistVideos1.count {
            playlist1DispatchGroup.enter()
            
            Task {
                do {
                    guard let id = playlistVideos1[i].videoId else { return }
                    let fetchedCount = try await networkController.getViewCountVideos(videoId: id)
                    
                    let formatter = NumberFormatter()
                    formatter.numberStyle = NumberFormatter.Style.decimal
                    
                    formatter.locale = Locale(identifier: "fr_FR")
                    
                    guard let formattedString = formatter.string(for: Int(fetchedCount)) else { return }
                   
                    playlistVideos1[i].viewCount = formattedString + " views"
                    playlist1DispatchGroup.leave()
                } catch {
                    print(error)
                    Alert.alert(error: error, vc: self)
                }
            }
        }
        playlist1DispatchGroup.notify(queue: .main) {
            self.configureDataSource()
        }
    }
    
    private func getViewCount2() {
        for i in 0..<playlistVideos2.count {
            playlist2DispatchGroup.enter()
            
            Task {
                do {
                    guard let id = playlistVideos2[i].videoId else { return }
                    let fetchedCount = try await networkController.getViewCountVideos(videoId: id)
                    
                    let formatter = NumberFormatter()
                    formatter.numberStyle = NumberFormatter.Style.decimal
                    
                    formatter.locale = Locale(identifier: "fr_FR")
                    
                    guard let formattedString = formatter.string(for: Int(fetchedCount)) else { return }
                   
                    playlistVideos2[i].viewCount = formattedString + " views"
                    playlist2DispatchGroup.leave()
                } catch {
                    print(error)
                    Alert.alert(error: error, vc: self)
                }
            }
        }
        playlist2DispatchGroup.notify(queue: .main) {
            self.configureDataSource()
        }
    }
    
    //MARK: - Collection View Data Source
    
    private func createLayout() -> UICollectionViewLayout {
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
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.92), heightDimension: .fractionalWidth(0.55))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 1)
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .groupPagingCentered
                
                section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 40, trailing: 0)
                
                return section
                
            case .landscape:
                //MARK: Lanscape Section Layout
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.45), heightDimension: .fractionalWidth(0.28))
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
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.42), heightDimension: .fractionalWidth(0.48))
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
    
    private func configureDataSource() {
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
                return cell
            case .square:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SquareImageCollectionViewCell.reuseIdentifier, for: indexPath) as! SquareImageCollectionViewCell
                cell.configureCell(self.playlistVideos2[indexPath.row], networkManager: self.networkController)
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
        
        guard let playlist1Title = playlist1Title, let playlist2Title = playlist2Title else { return }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.uiPageVC])
        snapshot.appendItems(Item.promotedApps, toSection: .uiPageVC)
        
        let landscapeSection = Section.landscape(playlist1Title)
        let squareSection = Section.square(playlist2Title)
        
        snapshot.appendSections([landscapeSection, squareSection])
        snapshot.appendItems(Item.landscapePlaylist, toSection: landscapeSection)
        snapshot.appendItems(Item.squarePlaylist, toSection: squareSection)
        sections = snapshot.sectionIdentifiers
        dataSource.apply(snapshot)
    }
    
    //MARK: - Setup player VC
    
    private func setupPlayer(playlistId: String, visibilityState: Bool) {

        self.playerVisible = visibilityState
        
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
    
    @objc
    private func handleButtonTap() {
        if playerVisible {
            animateTransitionIfNeeded(state: .collapsed, duration: 0.9)
        } else {
            animateTransitionIfNeeded(state: .expanded, duration: 0.9)
        }
    }
    
    private func deleteVisualEffect(state: PlayerState) {
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
    
    private func changeButtonImage(state: PlayerState) {
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
    private func handleCardPan (recognizer:UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            if playerVisible {
                startInteractiveTransition(state: .collapsed, duration: 0.9)
            } else {
                animateTransitionIfNeeded(state: .expanded, duration: 0.9)
            }
            
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
    
    private func animateTransitionIfNeeded (state: PlayerState, duration: TimeInterval) {
        
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
    
    private func startInteractiveTransition(state: PlayerState, duration: TimeInterval) {
        if runningAnimations.isEmpty {
            animateTransitionIfNeeded(state: state, duration: duration)
        }
        for animation in runningAnimations {
            animation.pauseAnimation()
            animationProgressWhenInterrupted = animation.fractionComplete
        }
    }

    private func updateInteractiveTransition(fractionCompleted: CGFloat) {
        for animation in runningAnimations {
            animation.fractionComplete = fractionCompleted + animationProgressWhenInterrupted
        }
    }

    private func continueInteractiveTransition() {
        for animation in runningAnimations {
            animation.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
    }
}

//MARK: - Activity Indicator

extension MainViewController {
    
    private func createSpinnerView() {
        let child = SpinnerViewController()

        addChild(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)

        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
    }
}

