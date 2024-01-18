//
//  ChatListViewController.swift
//  InshiyChat
//
//  Created by Denys Astapov on 31.12.2023.
//

import UIKit

class ChatListViewController: UIViewController {
    
    var viewModel = ChatListViewModel()
    
    var dataSource: UICollectionViewDiffableDataSource<ChatSection, ChatSectionItem>?
    var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .green
        
        title = "Chats"
        if let rootViewController = self.navigationController?.viewControllers.first as? ContainerViewController {
            rootViewController.title = self.title
        }
        
        viewModel.onChatUpdated = { [weak self] updatedSectionIndex, updatedItemIndex in
            guard let self = self else { return }
            
            var snapshot = self.dataSource?.snapshot()
            self.viewModel.chatSections.forEach { section in
                snapshot?.appendSections([section])
                snapshot?.appendItems(section.items, toSection: section)
            }
            self.dataSource?.apply(snapshot!, animatingDifferences: true) {
                let indexPath = IndexPath(item: updatedItemIndex, section: updatedSectionIndex)
                self.collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
            }
        }
        
        
        viewModel.observeChatsLastMessages { [weak self] chatRoomUID, newMessage in
            self?.viewModel.updateChatRoom(with: newMessage, for: chatRoomUID)
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
            ChatListCollectionViewCell.self,
            forCellWithReuseIdentifier: ChatListCollectionViewCell.reuseIdentifier
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
        dataSource = UICollectionViewDiffableDataSource<ChatSection, ChatSectionItem>(
            collectionView: collectionView,
            cellProvider: { (collectionView, indexPath, item) -> UICollectionViewCell? in
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: ChatListCollectionViewCell.reuseIdentifier,
                    for: indexPath) as? ChatListCollectionViewCell else {
                    return nil
                }
                cell.configure(with: ChatListCollectionViewCell.ChatListCellDTO(
                    userName: item.name,
                    userAvatar: item.avatar,
                    lastMessage: item.lastMessage,
                    numberOfUnread: item.unreadAmount
                ))
                return cell
            })
    }
    
    private func fillCollectionView() {
        viewModel.loadInitialChatRooms()
        
        viewModel.updateUI = { [weak self] in
            guard let self = self else { return }
            var snapshot = NSDiffableDataSourceSnapshot<ChatSection, ChatSectionItem>()
            
            self.viewModel.chatSections.forEach { section in
                snapshot.appendSections([section])
                snapshot.appendItems(section.items, toSection: section)
            }
            
            DispatchQueue.main.async {
                self.dataSource?.apply(snapshot, animatingDifferences: true)
                self.collectionView.reloadData()
            }
        }
    }
}

extension ChatListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let itemID = dataSource?.itemIdentifier(for: indexPath) {
            let chatRoomViewController = ChatRoomViewController()
            chatRoomViewController.userName = itemID.name
            chatRoomViewController.userAvatarURL = itemID.avatar
            chatRoomViewController.userUID = itemID.friendUID
            navigationController?.pushViewController(chatRoomViewController, animated: true)
        }
    }
}
