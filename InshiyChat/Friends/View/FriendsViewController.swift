//
//  FriendsViewController.swift
//  InshiyChat
//
//  Created by Denys Astapov on 08.12.2023.
//

import UIKit
import Firebase

class FriendsViewController: UIViewController {
    
    var viewModel = FriendsViewModel()
    
    var dataSource: UICollectionViewDiffableDataSource<FriendsSection, FriendsSectionItem>?
    var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        title = "Friends"
        if let rootViewController = self.navigationController?.viewControllers.first as? ContainerViewController {
            rootViewController.title = self.title
        }
        
        configureCollectionView()
        createDataSource()
        fillCollectionView()

        collectionView.delegate = self
        
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(
            frame: view.bounds,
            collectionViewLayout: createLayout()
        )
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .white
        view.addSubview(collectionView)
        collectionView.register(
            FriendsCollectionViewCell.self,
            forCellWithReuseIdentifier: FriendsCollectionViewCell.reuseIdentifier
        )
    }
    
    private func createLayout() -> UICollectionViewLayout {
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
    
    private func createDataSource() {
        dataSource = UICollectionViewDiffableDataSource<FriendsSection, FriendsSectionItem>(
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
    }

    private func fillCollectionView() {
        viewModel.fetchFriends { items in
            var snapshot = NSDiffableDataSourceSnapshot<FriendsSection, FriendsSectionItem>()
            let mainSection = FriendsSection(items: items)
            snapshot.appendSections([mainSection])
            snapshot.appendItems(items, toSection: mainSection)
            self.dataSource?.apply(snapshot, animatingDifferences: true)
            self.collectionView.reloadData()
        }
    }
}

extension FriendsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let itemID = dataSource?.itemIdentifier(for: indexPath) {
            let chatRoomViewController = ChatRoomViewController()
            chatRoomViewController.userName = itemID.name
            chatRoomViewController.userAvatarURL = itemID.avatar
            chatRoomViewController.userUID = itemID.uid
            navigationController?.pushViewController(chatRoomViewController, animated: true)
        }
    }
}
