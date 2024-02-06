//
//  FriendsViewController.swift
//  InshiyChat
//
//  Created by Denys Astapov on 08.12.2023.
//

import UIKit

class FriendsViewController: UIViewController {
    
    private let viewModel: FriendsViewModel!
    private let collectionView: UICollectionView!
    private let dataSource: UICollectionViewDiffableDataSource<FriendsSection, FriendsSectionItem>!
    
    init(viewModel: FriendsViewModel) {
        self.collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: FriendsViewController.createLayout()
        )
        self.viewModel = viewModel
        self.dataSource = UICollectionViewDiffableDataSource<FriendsSection, FriendsSectionItem>(
            collectionView: collectionView,
            cellProvider: { (collectionView, indexPath, item) -> UICollectionViewCell? in
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: FriendsCollectionViewCell.reuseIdentifier,
                    for: indexPath) as? FriendsCollectionViewCell else {
                    return nil
                }
                cell.configure(with: FriendsCollectionViewCell.CellDTO(
                    friend: item.name,
                    userAvatar: item.avatar
                ))
                return cell
            })
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Please use designated init instead of calling ViewVC storyboard")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        title = "Friends"
        if let rootViewController = self.navigationController?.viewControllers.first as? ContainerViewController {
            rootViewController.title = self.title
        }
        
        configureCollectionView()
        fillCollectionView()
        
        collectionView.delegate = self
        
    }
    
    private func configureCollectionView() {
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .white
        view.addSubview(collectionView)
        collectionView.register(
            FriendsCollectionViewCell.self,
            forCellWithReuseIdentifier: FriendsCollectionViewCell.reuseIdentifier
        )
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private static func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(100)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            repeatingSubitem: item,
            count: 1
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 0,
            bottom: 0,
            trailing: 0
        )
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    private func fillCollectionView() {
        viewModel.fetchFriends { [weak self] items in
            guard let self = self else { return }
            var snapshot = NSDiffableDataSourceSnapshot<FriendsSection, FriendsSectionItem>()
            let mainSection = FriendsSection(items: items)
            snapshot.appendSections([mainSection])
            snapshot.appendItems(items, toSection: mainSection)
            
            if let dataSource = self.dataSource {
                dataSource.apply(snapshot, animatingDifferences: true)
            } else {
                print("dataSource is nil")
            }
        }
    }
}

extension FriendsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let itemID = dataSource?.itemIdentifier(for: indexPath) {
            let chatRoomViewModel = ChatRoomViewModel()
            let chatRoomViewController = ChatRoomViewController(viewModel: chatRoomViewModel)
            chatRoomViewController.userName = itemID.name
            chatRoomViewController.userAvatarURL = itemID.avatar
            chatRoomViewController.userUID = itemID.uid
            navigationController?.pushViewController(chatRoomViewController, animated: true)
        }
    }
}
