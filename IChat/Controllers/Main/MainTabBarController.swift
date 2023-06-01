//
//  MainTabBarController.swift
//  IChat
//
//  Created by macbook on 22.12.2022.
//

import UIKit

final class MainTabBarController: UITabBarController {
    // MARK: Properties
    
    private let currentUser: MUser
    
    // MARK: Init
    
    init(currentUser: MUser = MUser(username: "Test", email: "test@mail.ru", avatarStringUrl: "nil", description: "nil", sex: "Male", id: "00007")) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        if appDelegate.activeChatsListener == nil {
            appDelegate.addActiveChatsListener()
        }
        
        if appDelegate.waitingChatsListener == nil {
            appDelegate.addWaitingChatsListener()
        }
         
        tabBar.tintColor = #colorLiteral(red: 0.5568627451, green: 0.3529411765, blue: 0.968627451, alpha: 1)
        
        let listViewController = ListViewController(currentUser: currentUser)
        let peopleViewController = PeopleViewController(currentUser: currentUser)
        
        let boldConfiguration = UIImage.SymbolConfiguration(weight: .medium)
        
        let personImage = UIImage(systemName: "person.2", withConfiguration: boldConfiguration)!
        let conversationImage = UIImage(systemName: "bubble.left.and.bubble.right", withConfiguration: boldConfiguration)!
        
        viewControllers = [
            generateNavigationController(rootViewController: peopleViewController, title: "People", image: personImage),
            generateNavigationController(rootViewController: listViewController, title: "Conversation", image: conversationImage)
        ]
    }
    
    // MARK: Methods
    
    private func generateNavigationController(rootViewController: UIViewController, title: String, image: UIImage) -> UIViewController {
        let navigationViewController = UINavigationController(rootViewController: rootViewController)
        
        navigationViewController.tabBarItem.title = title
        navigationViewController.tabBarItem.image = image
        
        return navigationViewController
    }
}


