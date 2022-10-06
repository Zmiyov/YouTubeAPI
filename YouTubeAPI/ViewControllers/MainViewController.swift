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

    @IBOutlet var collectionView: UICollectionView!
    
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    
    var sections = [Section]()
    let networkController = NetworkController()
    var playlistVideos1 = [PlaylistVideoModel]()
    var playlistVideos2 = [PlaylistVideoModel]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: Collection View Setup
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

        configureDataSource()
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
            Task {
                do {
                    guard let id = playlistVideos1[i].videoId else { return }
                    let fetchedCount = try await networkController.getViewCountVideos(videoId: id)
                   
                    playlistVideos1[i].countViews = fetchedCount
//                    print(fetchedCount)
                    
                } catch {
                    print(error)
                }
            }
        }
    }
    
    func getViewCount2() {
//        print("Count")
        for i in 0..<playlistVideos2.count {
            Task {
                do {
                    guard let id = playlistVideos2[i].videoId else { return }
                    let fetchedCount = try await networkController.getViewCountVideos(videoId: id)
                   
                    playlistVideos2[i].countViews = fetchedCount
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
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.8))
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
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.46), heightDimension: .fractionalHeight(0.19))
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
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.46), heightDimension: .fractionalHeight(0.26))
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

                cell.configureCell(item.app!)
                
                return cell
            case .square:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SquareImageCollectionViewCell.reuseIdentifier, for: indexPath) as! SquareImageCollectionViewCell

                cell.configureCell(item.app!)
                
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
}

