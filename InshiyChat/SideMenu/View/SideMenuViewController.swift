//
//  SideMenuViewController.swift
//  InshiyChat
//
//  Created by Denys Astapov on 07.12.2023.
//

import UIKit
import Firebase

protocol SideMenuViewControllerDelegate: AnyObject {
    func selectedCell(_ row: Int)
}

struct SideMenuModel {
    var icon: UIImage
    var title: String
}

class SideMenuViewController: UIViewController {
    
    var delegate: SideMenuViewControllerDelegate?
    
    var userFirstNameLabel = CreateUIElements.makeSmallLabel(
        text: "Tony",
        textColor: "ffffff",
        fontSize: 22,
        fontWeight: .bold
    )
    
    var userNameLabel = CreateUIElements.makeSmallLabel(
        text: "@username",
        textColor: "ffffff",
        fontSize: 14,
        fontWeight: .regular
    )
    
    var userPhoneNumberLabel = CreateUIElements.makeSmallLabel(
        text: "+62812345678",
        textColor: "ffffff",
        fontSize: 14,
        fontWeight: .regular
    )
    
    var userAvatarImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "profile_def"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let menu: [SideMenuModel] = [
        SideMenuModel(icon: UIImage(systemName: "person.3.fill")!, title: "Friends"),
        SideMenuModel(icon: UIImage(systemName: "bubble.right.fill")!, title: "Chats"),
        SideMenuModel(icon: UIImage(systemName: "slider.horizontal.3")!, title: "Settings"),
        SideMenuModel(icon: UIImage(systemName: "rectangle.portrait.and.arrow.right")!, title: "Log out")
    ]
    
    private let sideMenuCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(
            SideMenuCollectionViewCell.self,
            forCellWithReuseIdentifier: SideMenuCollectionViewCell.identifier
        )
        collectionView.backgroundColor = .white
        collectionView.isUserInteractionEnabled = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sideMenuCollectionView.delegate = self
        sideMenuCollectionView.dataSource = self

        setUp()
        
    }
    
    private func setUp() {
        
        self.view.backgroundColor = UIColor(hex: "412dc4")
        
        let stackViewUserLabels = UIStackView(arrangedSubviews: [
            userFirstNameLabel,
            userNameLabel,
            userPhoneNumberLabel
        ])
        
        let stackViewUserInfo = UIStackView(arrangedSubviews: [
            userAvatarImageView,
            stackViewUserLabels
        ])
        
        view.addSubview(stackViewUserInfo)
        view.addSubview(sideMenuCollectionView)
        
        stackViewUserLabels.axis = .vertical
        stackViewUserLabels.spacing = 15
        stackViewUserLabels.translatesAutoresizingMaskIntoConstraints = false
        
        stackViewUserInfo.axis = .horizontal
        stackViewUserInfo.spacing = 15
        stackViewUserInfo.alignment = .center
        stackViewUserInfo.distribution = .fillProportionally
        stackViewUserInfo.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackViewUserInfo.topAnchor.constraint(equalTo: view.topAnchor),
            stackViewUserInfo.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackViewUserInfo.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackViewUserInfo.heightAnchor.constraint(equalToConstant: 200),
            
            userAvatarImageView.widthAnchor.constraint(equalToConstant: 100),
            userAvatarImageView.heightAnchor.constraint(equalToConstant: 100),
            
            sideMenuCollectionView.topAnchor.constraint(equalTo: stackViewUserInfo.bottomAnchor),
            sideMenuCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sideMenuCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sideMenuCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }    
}

extension SideMenuViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menu.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SideMenuCollectionViewCell.identifier, for: indexPath) as? SideMenuCollectionViewCell else {
            fatalError("Unable to dequeue SideMenuCollectionViewCell")
        }
        cell.iconImageView.image = menu[indexPath.item].icon
        cell.titleLabel.text = menu[indexPath.item].title
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? SideMenuCollectionViewCell else {
            return
        }
        
        self.delegate?.selectedCell(indexPath.item)
        
        let myCustomSelectionColorView = UIView()
        myCustomSelectionColorView.backgroundColor = UIColor(hex: "5C45EF")
        cell.selectedBackgroundView = myCustomSelectionColorView
        
        cell.iconImageView.tintColor = .white
        cell.titleLabel.textColor = .white
        
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? SideMenuCollectionViewCell else {
            return
        }
        
        cell.iconImageView.tintColor = UIColor(hex: "a4a4a4")
        cell.titleLabel.textColor = UIColor(hex: "a4a4a4")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}
