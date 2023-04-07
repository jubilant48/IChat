//
//  ListViewController.swift
//  IChat
//
//  Created by macbook on 22.12.2022.
//

import UIKit
import FirebaseFirestore

final class ListViewController: UIViewController {
    // MARK: - Enumerations
    
    enum Layout {
        case filled
        case empty
    }
    
    enum Section: Int, CaseIterable {
        case waitingChats
        case activeChats
        
        func description() -> String {
            switch self {
            case .waitingChats:
                return "Waiting chats"
            case .activeChats:
                return "Active chats"
            }
        }
    }
    
    // MARK: - Properties
    
    private var activeChats = [MChat]()
    private var waitingChats = [MChat]()
    
    private var waitingLayout: Layout = .filled
    private var isEmptyWaitingChats: Bool = false {
        willSet {
            switch newValue {
            case true:
                waitingLayout = .empty
            case false:
                waitingLayout = .filled
            }
        }
    }
    private var activeLayout: Layout = .filled
    private var isEmptyActiveChats: Bool = false {
        willSet {
            switch newValue {
            case true:
                activeLayout = .empty
            case false:
                activeLayout = .filled
            }
        }
    }
    
    private var waitingChatsListener: ListenerRegistration?
    private var activeChatsListener: ListenerRegistration?
    
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, MChat>?
    
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
        waitingChatsListener?.remove()
        activeChatsListener?.remove()
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchBar()
        setupCollectionView()
        createDataSource()
        addListeners()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.reloadData()
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
        collectionView.register(ActivePlugCell.self, forCellWithReuseIdentifier: ActivePlugCell.reuseId)
        collectionView.register(ActiveChatCell.self, forCellWithReuseIdentifier: ActiveChatCell.reuseId)
        collectionView.register(WaitingPlugCell.self, forCellWithReuseIdentifier: WaitingPlugCell.reuseId)
        collectionView.register(WaitingChatCell.self, forCellWithReuseIdentifier: WaitingChatCell.reuseId)
        
        collectionView.delegate = self
    }
    
    private func addWaitingChatsListeners() {
        waitingChatsListener = ListenerService.shared.waitingChatsObserve(chats: waitingChats) { result in
            switch result {
            case .success(let chats):
                if self.waitingChats != [], self.waitingChats.count <= chats.count {
                    let chatRequestViewController = ChatRequsetViewController(chat: chats.last!)
                    chatRequestViewController.delegate = self
                    
                    self.present(chatRequestViewController, animated: true)
                }
                
                self.waitingChats = chats
                self.isEmptyWaitingChats = self.waitingChats.isEmpty
                
                self.reloadData()
            case .failure(let error):
                self.showAlert(with: "Ошибка!", and: error.localizedDescription)
            }
        }
    }
    
    private func addActiveChatsListeners() {
        activeChatsListener = ListenerService.shared.activeChatsObserve(chats: activeChats) { result in
            switch result {
            case .success(let chats):
                self.activeChats = chats
                self.isEmptyActiveChats = self.activeChats.isEmpty
                
                self.reloadData()
                self.reloadData()
            case .failure(let error):
                self.showAlert(with: "Ошибка!", and: error.localizedDescription)
            }
        }
    }
    
    private func addListeners() {
        addWaitingChatsListeners()
        addActiveChatsListeners()
    }
    
    private func reloadData() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, MChat>()

        snapshot.appendSections([.waitingChats, .activeChats])
    
        switch waitingLayout {
        case .filled:
            snapshot.appendItems(waitingChats, toSection: .waitingChats)
        case .empty:
            snapshot.appendItems([MChat.waitingPlugModel], toSection: .waitingChats)
        }
        
        switch activeLayout {
        case .filled:
            snapshot.appendItems(activeChats, toSection: .activeChats)
        case .empty:
            snapshot.appendItems([MChat.activePlugModel], toSection: .activeChats)
        }
        
        snapshot.reloadItems(waitingChats)
        snapshot.reloadItems(activeChats)
        
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    private func reloadData(with searchText: String) {
        let waitingFiltered = waitingChats.filter { $0.contains(filter: searchText) }
        let activeFiltered = activeChats.filter { $0.contains(filter: searchText) }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, MChat>()

        snapshot.appendSections([.waitingChats, .activeChats])

        switch waitingLayout {
        case .filled:
            snapshot.appendItems(waitingFiltered, toSection: .waitingChats)
        case .empty:
            snapshot.appendItems([MChat.waitingPlugModel], toSection: .waitingChats)
        }

        switch activeLayout {
        case .filled:
            snapshot.appendItems(activeFiltered, toSection: .activeChats)
        case .empty:
            snapshot.appendItems([MChat.activePlugModel], toSection: .activeChats)
        }
        
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - Data Source

extension ListViewController {
    private func createDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, MChat>(collectionView: collectionView, cellProvider: { collectionView, indexPath, chat in
            guard let section = Section(rawValue: indexPath.section) else {
                fatalError("Unkown section kind")
            }
            
            switch section {
            case .activeChats:
                switch self.activeLayout {
                case .filled:
                    return self.configure(collectionView: collectionView, cellType: ActiveChatCell.self, with: chat, for: indexPath)
                case .empty:
                    return self.configure(collectionView: collectionView, cellType: ActivePlugCell.self, with: "is Empty", for: indexPath)
                }
                
            case .waitingChats:
                switch self.waitingLayout {
                case .filled:
                    return self.configure(collectionView: collectionView, cellType: WaitingChatCell.self, with: chat, for: indexPath)
                case .empty:
                    return self.configure(collectionView: collectionView, cellType: WaitingPlugCell.self, with: "is Empty", for: indexPath)
                }
            }
        })
        
        dataSource?.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeader.reuseId, for: indexPath) as? SectionHeader else {
                fatalError("Can not create new section header")
            }
            
            guard let section = Section(rawValue: indexPath.section) else { fatalError("Uknown section kind") }
            
            sectionHeader.configure(text: section.description(), font: .laoSangamMN20(), textColor: .getHeaderGrayColor())
           return sectionHeader
        }
    }
}

// MARK: - Setup Layout

extension ListViewController {
    private func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        // Setup size for header
        let sectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(1))
        
        // Create header
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: sectionHeaderSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        
        return sectionHeader
    }
    
    private func createActiveChats() -> NSCollectionLayoutSection {
        // Setup size for item and group
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(78))
        
        // Create item
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // Create group
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        // Create header
        let sectionHeader = createSectionHeader()

        // Create section and configure
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.contentInsets = NSDirectionalEdgeInsets.init(top: 16, leading: 20, bottom: 0, trailing: 20)
        section.boundarySupplementaryItems = [sectionHeader]
        
        return section
    }
    
    private func createPlugForActiveChats() -> NSCollectionLayoutSection {
        // Setup size for item and ground
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.43))
        
        // Create item
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // Create group
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        // Create header
        let sectionHeader = createSectionHeader()
        
        // Create section and configure
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: 0, trailing: 20)
        section.boundarySupplementaryItems = [sectionHeader]
        
        return section
    }
    
    private func createWaitingChats() -> NSCollectionLayoutSection {
        // Setup size for item and group
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(88), heightDimension: .absolute(88))
        
        // Create item
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // Create group
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        // Create header
        let sectionHeader = createSectionHeader()
        
        // Create section and configure
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 20
        section.contentInsets = NSDirectionalEdgeInsets.init(top: 16, leading: 20, bottom: 0, trailing: 20)
        section.orthogonalScrollingBehavior = .continuous
        section.boundarySupplementaryItems = [sectionHeader]
        
        return section
    }
    
    private func createPlugForWaitingChats() -> NSCollectionLayoutSection {
        // Setup size for item and ground
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(88))
        
        // Create item
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // Create group
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        // Create header
        let sectionHeader = createSectionHeader()
        
        // Create section and configure
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: 0, trailing: 20)
        section.boundarySupplementaryItems = [sectionHeader]
        section.orthogonalScrollingBehavior = .groupPagingCentered
        
        return section
    }
    
    private func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnviroment) -> NSCollectionLayoutSection? in
            // Create section for choosing kinds chats
            guard let section = Section(rawValue: sectionIndex) else {
                fatalError("Unkown section kind")
            }
            
            switch section {
            case .waitingChats:
                switch self.waitingLayout {
                case .filled:
                    return self.createWaitingChats()
                case .empty:
                    return self.createPlugForWaitingChats()
                }
            case .activeChats:
                switch self.activeLayout {
                case .filled:
                    return self.createActiveChats()
                case .empty:
                    return self.createPlugForActiveChats()
                }
            }
        }
        
        // Configure layout
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 20
        layout.configuration = config
        
        return layout
    }
}

// MARK: - Search bar delegate

extension ListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        reloadData(with: searchText)
    }
}

// MARK: - Collection view delegate

extension ListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let chat = self.dataSource?.itemIdentifier(for: indexPath) else { return }
        guard let section = Section(rawValue: indexPath.section) else { return }
        
        switch section {
        case .waitingChats:
            guard !isEmptyWaitingChats else { return }
            
            let chatRequestViewController = ChatRequsetViewController(chat: chat)
            chatRequestViewController.delegate = self
            
            self.present(chatRequestViewController, animated: true)
        case .activeChats:
            guard !isEmptyActiveChats else { return }
            
            let chatsViewController = ChatsViewController(user: currentUser, chat: chat)
            navigationController?.pushViewController(chatsViewController, animated: true)
        }
    }
}

// MARK: - Waiting chats navigation

extension ListViewController: WaitingChatsNavigation {
    func removeWaitingChat(chat: MChat) {
        FirestoreService.shared.deleteWaitingChat(chat: chat) { result in
            switch result {
            case .success():
                break
            case .failure(let error):
                self.showAlert(with: "Ошибка", and: error.localizedDescription)
            }
        }
    }
    
    func changeToActive(chat: MChat) {
        FirestoreService.shared.changeToActive(chat: chat) { result in
            switch result {
            case .success():
                break
            case .failure(let error):
                self.showAlert(with: "Ошибка!", and: error.localizedDescription)
            }
        }
    }
}
