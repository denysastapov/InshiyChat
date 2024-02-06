//
//  ChatRoomViewController.swift
//  InshiyChat
//
//  Created by Denys Astapov on 14.12.2023.
//

import UIKit

class ChatRoomViewController: UIViewController {
    
    var currentUserID: String?
    var userUID: String?
    var userName: String?
    var userAvatarURL: String?
    var chatUID: String?
    var messageBoxBottomConstraint: NSLayoutConstraint?
    
    private let viewModel: ChatRoomViewModel!
    private let collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<ChatRoomDTO, MessageDTO>!
    
    private let inputMessageField: UITextView = {
        CreateUIElements.createInputMessageField()
    }()
    
    private let sendButton: UIButton = {
        CreateUIElements.createSendButton()
    }()
    
    lazy var messageBoxStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            inputMessageField,
            sendButton
        ])
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    init(viewModel: ChatRoomViewModel) {
        self.currentUserID = ""
        self.viewModel = viewModel
        self.collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: ChatRoomViewController.createLayout()
        )
        super.init(nibName: nil, bundle: nil)
        self.dataSource = UICollectionViewDiffableDataSource<ChatRoomDTO, MessageDTO>(
            collectionView: collectionView,
            cellProvider: { [weak self] (collectionView, indexPath, item) -> UICollectionViewCell? in
                guard let self = self else { return nil }
                if item.messageOwnerID == self.currentUserID {
                    let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: SenderCollectionViewCell.reuseIdentifier,
                        for: indexPath
                    ) as? SenderCollectionViewCell
                    cell?.configure(with: item)
                    return cell
                } else {
                    let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: RecipientCollectionViewCell.reuseIdentifier,
                        for: indexPath
                    ) as? RecipientCollectionViewCell
                    cell?.configure(with: item)
                    return cell
                }
            }
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
        
        setupKeyboardHandling()
        configureCollectionView()
        fillCollectionView()
        
        setUpUI()
        
        sendButton.addAction(UIAction(handler: { [weak self] _ in
            self?.sendButtonPressed()
        }), for: .touchUpInside)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setUpUI() {
        
        prepareForLoadingChats()
        
        navigationItem.title = userName
        setUserAvatar(from: userAvatarURL)
        
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "background_inshiy_main")
        backgroundImage.contentMode = .scaleAspectFill
        
        view.layer.contents = backgroundImage.image?.cgImage
        
        view.addSubview(messageBoxStackView)
        
        messageBoxBottomConstraint = messageBoxStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        messageBoxBottomConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            messageBoxStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            messageBoxStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            inputMessageField.leadingAnchor.constraint(equalTo: messageBoxStackView.leadingAnchor, constant: 0),
            inputMessageField.topAnchor.constraint(equalTo: messageBoxStackView.topAnchor, constant: 0),
            inputMessageField.bottomAnchor.constraint(equalTo: messageBoxStackView.bottomAnchor, constant: 0),
            
            sendButton.widthAnchor.constraint(equalToConstant: 50),
            
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            collectionView.bottomAnchor.constraint(equalTo: messageBoxStackView.topAnchor, constant: -10)
            
        ])
        
    }
    
    private func prepareForLoadingChats() {
        viewModel.getCurrentUserUID { [weak self] currentUserUID in
            self?.currentUserID = currentUserUID
        }
        guard let userUID = self.userUID, let currentUserID = self.currentUserID else {
            return
        }
        viewModel.isChatExsists(
            userUID1: userUID,
            userUID2: currentUserID,
            completion: { [weak self] chatUID in
                self?.chatUID = chatUID
                self?.loadMessages()
                self?.viewModel.observeNewMessages(for: chatUID) { [weak self] message in
                    self?.handleNewMessage(message)
                }
            }
        )
    }
    
    private func handleNewMessage(_ message: MessageDTO) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if var snapshot = self.dataSource?.snapshot() {
                snapshot.appendItems([message], toSection: snapshot.sectionIdentifiers.first)
                
                self.dataSource?.apply(snapshot, animatingDifferences: true)
                self.scrollToLastItem()
            }
        }
    }
    
    func scrollToLastItem() {
        let lastSection = collectionView.numberOfSections - 1
        if lastSection < 0 {
            return
        }
        
        let lastItem = collectionView.numberOfItems(inSection: lastSection) - 1
        if lastItem >= 0 {
            let lastIndexPath = IndexPath(item: lastItem, section: lastSection)
            collectionView.scrollToItem(at: lastIndexPath, at: .bottom, animated: true)
        }
    }
    
    private func sendButtonPressed() {
        guard let text = inputMessageField.text, !text.isEmpty else {
            return
        }
        
        guard let chatUID = self.chatUID, let currentUserID = self.currentUserID else {
            return
        }
        
        viewModel.sendMessage(
            chatUID: chatUID,
            messageOwner: currentUserID,
            text: text,
            timestamp: Date().timeIntervalSince1970
        ) { [weak self] error in
            if let error = error {
                print("Error sending message: \(error.localizedDescription)")
            } else {
                self?.inputMessageField.text = ""
            }
        }
    }
    
    private func loadMessages() {
        guard let chatUID = self.chatUID else {
            print("Error get chatUID")
            return
        }
        viewModel.getMessages(for: chatUID) { [weak self] messages, error in
            if let error = error {
                print("Error loading messages: \(error.localizedDescription)")
            } else if let messages = messages {
                var snapshot = NSDiffableDataSourceSnapshot<ChatRoomDTO, MessageDTO>()
                let chatRoom = ChatRoomDTO(messages: messages, usersIDs: [self?.userUID, self?.currentUserID].compactMap { $0 })
                snapshot.appendSections([chatRoom])
                snapshot.appendItems(messages, toSection: chatRoom)
                self?.dataSource?.apply(snapshot, animatingDifferences: true)
            }
        }
    }
    
    private func configureCollectionView() {
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
        collectionView.backgroundColor = .clear
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.register(
            SenderCollectionViewCell.self,
            forCellWithReuseIdentifier: SenderCollectionViewCell.reuseIdentifier
        )
        
        collectionView.register(
            RecipientCollectionViewCell.self,
            forCellWithReuseIdentifier: RecipientCollectionViewCell.reuseIdentifier
        )
    }
    
    private static func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(100)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(100)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 0
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func createDataSource() -> UICollectionViewDiffableDataSource<ChatRoomDTO, MessageDTO> {
        return UICollectionViewDiffableDataSource<ChatRoomDTO, MessageDTO>(
            collectionView: collectionView,
            cellProvider: { (collectionView, indexPath, item) -> UICollectionViewCell? in
                if item.messageOwnerID == self.currentUserID {
                    let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: SenderCollectionViewCell.reuseIdentifier,
                        for: indexPath
                    ) as? SenderCollectionViewCell
                    cell?.configure(with: item)
                    return cell
                } else {
                    let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: RecipientCollectionViewCell.reuseIdentifier,
                        for: indexPath
                    ) as? RecipientCollectionViewCell
                    cell?.configure(with: item)
                    return cell
                }
            }
        )
    }
    
    private func fillCollectionView() {
        var snapshot = NSDiffableDataSourceSnapshot<ChatRoomDTO, MessageDTO>()
        let emptyChatRoom = ChatRoomDTO(messages: [], usersIDs: ["1"])
        snapshot.appendSections([emptyChatRoom])
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    private func setUserAvatar(from urlString: String?) {
        guard let urlString = urlString, let imageUrl = URL(string: urlString) else {
            setNavigationItemAvatarImage(UIImage(named: "profile_def"))
            return
        }
        
        DispatchQueue.global().async {
            if let imageData = try? Data(contentsOf: imageUrl),
               let image = UIImage(data: imageData) {
                DispatchQueue.main.async {
                    self.setNavigationItemAvatarImage(image)
                }
            } else {
                DispatchQueue.main.async {
                    self.setNavigationItemAvatarImage(UIImage(named: "profile_def"))
                }
            }
        }
    }
    
    private func setNavigationItemAvatarImage(_ image: UIImage?) {
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let widthConstraint = imageView.widthAnchor.constraint(equalToConstant: 40)
        let heightConstraint = imageView.heightAnchor.constraint(equalToConstant: 40)
        NSLayoutConstraint.activate([widthConstraint, heightConstraint])
        
        let barButtonItem = UIBarButtonItem(customView: imageView)
        self.navigationItem.rightBarButtonItem = barButtonItem
    }
}
