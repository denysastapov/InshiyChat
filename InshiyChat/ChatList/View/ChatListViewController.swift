//
//  ChatListViewController.swift
//  InshiyChat
//
//  Created by Denys Astapov on 31.12.2023.
//

import UIKit

class ChatListViewController: UIViewController {
    
    private let viewModel: ChatListViewModel!
    private let collectionView: UICollectionView!
    private let dataSource: UICollectionViewDiffableDataSource<ChatSection, ChatSectionItem>!
    
    init(viewModel: ChatListViewModel) {
        self.collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: ChatListViewController.createLayout()
        )
        self.viewModel = viewModel
        self.dataSource = UICollectionViewDiffableDataSource<ChatSection, ChatSectionItem>(
            collectionView: collectionView,
            cellProvider: { (collectionView, indexPath, item) -> UICollectionViewCell? in
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: ChatListCollectionViewCell.reuseIdentifier,
                    for: indexPath) as? ChatListCollectionViewCell else {
                    print("Could not dequeue cell")
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
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        
        title = "Chats"
        view.backgroundColor = .white
        if let rootViewController = self.navigationController?.viewControllers.first as? ContainerViewController {
            rootViewController.title = self.title
        }
        
//        viewModel.onChatUpdated = { [weak self] updatedSectionIndex, updatedItemIndex in
//            guard let self = self else { return }
//            
//            var snapshot = self.dataSource?.snapshot()
//            self.viewModel.chatSections.forEach { section in
//                snapshot?.appendSections([section])
//                snapshot?.appendItems(section.items, toSection: section)
//            }
//            self.dataSource?.apply(snapshot!, animatingDifferences: true) {
//                let indexPath = IndexPath(item: updatedItemIndex, section: updatedSectionIndex)
//                self.collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
//            }
//        }
//
//        viewModel.observeChatsLastMessages { [weak self] chatRoomUID, newMessage in
//            self?.viewModel.updateChatRoom(with: newMessage, for: chatRoomUID)
//        }
        
        configureCollectionView()
        fillCollectionView()
    }
    
    private func configureCollectionView() {
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .white
        view.addSubview(collectionView)
        collectionView.register(
            ChatListCollectionViewCell.self,
            forCellWithReuseIdentifier: ChatListCollectionViewCell.reuseIdentifier
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
        viewModel.loadInitialChatRooms { [weak self] loadedChatRooms in
            guard let self = self else { return }
            print("Loaded chat rooms: \(loadedChatRooms.count)")
            
            var snapshot = NSDiffableDataSourceSnapshot<ChatSection, ChatSectionItem>()
            
            let chatSection = ChatSection(items: loadedChatRooms)
            
            snapshot.appendSections([chatSection])
            snapshot.appendItems(loadedChatRooms, toSection: chatSection)
            
            DispatchQueue.main.async {
                self.dataSource?.apply(snapshot, animatingDifferences: true) {
                }
            }
        }
    }
}

extension ChatListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let itemID = dataSource?.itemIdentifier(for: indexPath) {
            let chatRoomViewModel = ChatRoomViewModel()
            let chatRoomViewController = ChatRoomViewController(viewModel: chatRoomViewModel)
            chatRoomViewController.userName = itemID.name
            chatRoomViewController.userAvatarURL = itemID.avatar
            chatRoomViewController.userUID = itemID.friendUID
            navigationController?.pushViewController(chatRoomViewController, animated: true)
        }
    }
}
