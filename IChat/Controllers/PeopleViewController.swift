//
//  PeopleViewController.swift
//  IChat
//
//  Created by macbook on 22.12.2022.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

final class PeopleViewController: UIViewController {
    // MARK:  - Enumerations
    
    enum Section: Int, CaseIterable {
        case users
        
        func description(usersCount: Int) -> String {
            switch self {
            case .users:
                return "\(usersCount) people nearby"
            }
        }
    }
    
    // MARK: - Properties
    
    var users: [MUser] = []
    private var usersListener: ListenerRegistration?
    
    private var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, MUser>!
    private let currentUser: MUser
    
    // MARK: - Init and deinit
    
    init(currentUser: MUser) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
        title = currentUser.username
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        usersListener?.remove()
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .purple
        
        setupSearchBar()
        setupCollectionView()
        createDataSource()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log out", style: .plain, target: self, action: #selector(signOut))
        
        usersListener = ListenerService.shared.usersObserve(users: users) { result in
            switch result {
            case .success(let users):
                self.users = users
                self.reloadData(with: nil)
            case .failure(let error):
                self.showAlert(with: "Ошибка!", and: error.localizedDescription)
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func signOut() {
        let alertController = UIAlertController(title: nil, message: "Are you sure you want to sign out?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let signOutAction = UIAlertAction(title: "Sign out", style: .destructive) { _ in
            do {
                try Auth.auth().signOut()
                
                let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                scene!.windows[0].rootViewController = AuthViewController()
            } catch {
                print("Error singing out: \(error.localizedDescription)")
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(signOutAction)
        
        present(alertController, animated: true)
    }
    
    // MARK: - Override methods
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        switch traitCollection.userInterfaceStyle {
        case .unspecified:
            break
        case .light:
            for cell in collectionView.visibleCells {
                cell.layer.shadowColor = UIColor.getShadowColor().cgColor
            }
        case .dark:
            for cell in collectionView.visibleCells {
                cell.layer.shadowColor = UIColor.getShadowColor().cgColor
            }
        @unknown default:
            break
        }
    }
    
    // MARK: - Methods
    
    private func setupSearchBar() {
        navigationController?.navigationBar.barTintColor = .getBackgroundAppColor()
        navigationController?.navigationBar.shadowImage = UIImage()
        
        let searchController = UISearchController(searchResultsController: nil)
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = true
        
        searchController.searchBar.delegate = self
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .getBackgroundAppColor()
        
        view.addSubview(collectionView)
        
        collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeader.reuseId)
        
        collectionView.register(UserCell.self, forCellWithReuseIdentifier: UserCell.reuseId)
        collectionView.delegate = self
    }
    
    private func reloadData(with searchText: String?) {
        let filtered = users.filter { user in
            user.contains(filter: searchText)
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, MUser>()

        snapshot.appendSections([.users])
        snapshot.appendItems(filtered, toSection: .users)

        dataSource?.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - Setup layout

extension PeopleViewController {
    private func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnviroment) -> NSCollectionLayoutSection? in
            // Create section for choosing kinds chats
            guard let section = Section(rawValue: sectionIndex) else {
                fatalError("Unkown section kind")
            }
            
            switch section {
            case .users:
                return self.createUsersSection()
            }
        }
        
        // Configure layout
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 20
        layout.configuration = config
        
        return layout
    }
    
    private func createUsersSection() -> NSCollectionLayoutSection {
        let spacing = CGFloat(15)
        
        // Setup size for item and group
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalWidth(0.6))
        
        // Create item
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // Create group and configure
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 2)
        group.interItemSpacing = .fixed(spacing)
        
        // Create header
        let sectionHeader = createSectionHeader()
        
        // Create section and configure 
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 15, bottom: 30, trailing: 0)
        section.boundarySupplementaryItems = [sectionHeader]
        
        return section
    }
    
    private func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        // Setup size for header
        let sectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(1))
        
        // Create header
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: sectionHeaderSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        
        return sectionHeader
    }
    
}

// MARK: - Data Source

extension PeopleViewController {
    private func createDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, MUser>(collectionView: collectionView, cellProvider: { collectionView, indexPath, users in
            guard let section = Section(rawValue: indexPath.section) else {
                fatalError("Unknown section kind")
            }
            
            switch section {
            case .users:
                return self.configure(collectionView: collectionView, cellType: UserCell.self, with: users, for: indexPath)
            }
        })
        
        dataSource?.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeader.reuseId, for: indexPath) as? SectionHeader else {
                fatalError("Can not create new section header")
            }
            
            guard let section = Section(rawValue: indexPath.section) else { fatalError("Uknown section kind") }
            
            let items = self.dataSource.snapshot().itemIdentifiers(inSection: .users)
            
            sectionHeader.configure(text: section.description(usersCount: items.count), font: .systemFont(ofSize: 36, weight: .light), textColor: .label)
            
           return sectionHeader
        }
    }
}

// MARK: - Search bar delegate

extension PeopleViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        reloadData(with: searchText)
    }
}


// MARK: - Collection view delegate

extension PeopleViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let user = self.dataSource.itemIdentifier(for: indexPath) else { return }
        let profileViewController = ProfileViewController(user: user)
        
        present(profileViewController, animated: true)
    }
}

// MARK: - Display Canvas

import SwiftUI

struct PeopleViewControllerProvider: PreviewProvider {
    static var previews: some View {
        ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        
        let viewController = MainTabBarController()
        
        func makeUIViewController(context: Context) -> some MainTabBarController {
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        }
    }
}
