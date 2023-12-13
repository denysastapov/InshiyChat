//
//  HomeViewController.swift
//  InshiyChat
//
//  Created by Denys Astapov on 08.12.2023.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {
    
    var viewModel = HomeViewModel()

    var sideMenuViewController: SideMenuViewController!
    var sideMenuShadowView: UIView!
    var sideMenuRevealWidth: CGFloat = 280
    let paddingForRotation: CGFloat = 150
    var isExpanded: Bool = false
    var draggingIsEnabled: Bool = false
    var panBaseLocation: CGFloat = 0.0
    var sideMenuTrailingConstraint: NSLayoutConstraint!
    var openSideMenuOnTop: Bool = true
    var gestureEnabled: Bool = true
    
    var dataSource: UICollectionViewDiffableDataSource<HomeSection, HomeSectionItem>?
    var collectionView: UICollectionView! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        getCurrentUser()
        
        configureCollectionView()
        createDataSource()
        fillCollectionView()
        
        setUp()
        
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
            HomeCollectionViewCell.self,
            forCellWithReuseIdentifier: HomeCollectionViewCell.reuseIdentifier
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
            heightDimension: .fractionalWidth(0.3)
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
        dataSource = UICollectionViewDiffableDataSource<HomeSection, HomeSectionItem>(
            collectionView: collectionView,
            cellProvider: { (collectionView, indexPath, item) -> UICollectionViewCell? in
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: HomeCollectionViewCell.reuseIdentifier,
                    for: indexPath) as? HomeCollectionViewCell else {
                    return nil
                }
                cell.configure(with: HomeCollectionViewCell.CellDTO(
                    friend: item.name,
                    userAvatar: item.avatar
                ))
                return cell
            })
    }
    
    private func fillCollectionView() {
        viewModel.fetchChatRooms { items in
            var snapshot = NSDiffableDataSourceSnapshot<HomeSection, HomeSectionItem>()
            let mainSection = HomeSection(items: items)
            snapshot.appendSections([mainSection])
            snapshot.appendItems(items, toSection: mainSection)
            self.dataSource?.apply(snapshot, animatingDifferences: true)
            self.collectionView.reloadData()
        }
    }
    
    func setUp() {
        
        self.title = "Home"
        let menuButton = UIBarButtonItem(
            image: UIImage(systemName: "line.horizontal.3"),
            primaryAction: UIAction(handler: { [weak self] _ in
                self?.openSideMenu()
            }))
        menuButton.tintColor = .white
        navigationItem.leftBarButtonItem = menuButton
        
        navigationController?.isNavigationBarHidden = false
        
        self.setNavBarAppearance(tintColor: .white, barColor: UIColor(hex: "412dc4"))
        
        self.sideMenuShadowView = UIView(frame: self.view.bounds)
        self.sideMenuShadowView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.sideMenuShadowView.backgroundColor = .black
        self.sideMenuShadowView.alpha = 0.0
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognizer))
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.delegate = self
        self.sideMenuShadowView.addGestureRecognizer(tapGestureRecognizer)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        panGestureRecognizer.delegate = self
        view.addGestureRecognizer(panGestureRecognizer)
        
        if self.openSideMenuOnTop {
            view.insertSubview(self.sideMenuShadowView, at: 1)
        }
        
        self.sideMenuViewController = SideMenuViewController()
        self.sideMenuViewController.delegate = self
        
        view.insertSubview(self.sideMenuViewController.view, at: self.openSideMenuOnTop ? 2 : 0)
        addChild(self.sideMenuViewController)
        self.sideMenuViewController.didMove(toParent: self)
        
        self.sideMenuViewController.view.translatesAutoresizingMaskIntoConstraints = false
        if self.openSideMenuOnTop {
            self.sideMenuTrailingConstraint = self.sideMenuViewController.view.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: -self.sideMenuRevealWidth - self.paddingForRotation
            )
            self.sideMenuTrailingConstraint.isActive = true
        }
        
        NSLayoutConstraint.activate([
            self.sideMenuViewController.view.widthAnchor.constraint(equalToConstant: self.sideMenuRevealWidth),
            self.sideMenuViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            self.sideMenuViewController.view.topAnchor.constraint(equalTo: view.topAnchor)
        ])
    }
    
    func setNavBarAppearance(tintColor: UIColor, barColor: UIColor) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = barColor
        appearance.titleTextAttributes = [.foregroundColor: tintColor]
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = tintColor
    }
    
    func animateShadow(targetPosition: CGFloat) {
        UIView.animate(withDuration: 0.5) {
            self.sideMenuShadowView.alpha = (targetPosition == 0) ? 0.6 : 0.0
        }
    }
    
    func openSideMenu() {
        self.sideMenuState(expanded: self.isExpanded ? false : true)
    }
    
    func sideMenuState(expanded: Bool) {
        if expanded {
            self.animateSideMenu(targetPosition: self.openSideMenuOnTop ? 0 : self.sideMenuRevealWidth) { _ in
                self.isExpanded = true
            }
            UIView.animate(withDuration: 0.5) { self.sideMenuShadowView.alpha = 0.6 }
        }
        else {
            self.animateSideMenu(targetPosition: self.openSideMenuOnTop ? (-self.sideMenuRevealWidth - self.paddingForRotation) : 0) { _ in
                self.isExpanded = false
            }
            UIView.animate(withDuration: 0.5) { self.sideMenuShadowView.alpha = 0.0 }
        }
    }
    
    func animateSideMenu(targetPosition: CGFloat, completion: @escaping (Bool) -> ()) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: .layoutSubviews, animations: {
            if self.openSideMenuOnTop {
                self.sideMenuTrailingConstraint.constant = targetPosition
                self.view.layoutIfNeeded()
            }
            else {
                self.view.subviews[1].frame.origin.x = targetPosition
            }
        }, completion: completion)
    }
}
