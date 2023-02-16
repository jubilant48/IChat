//
//  AuthService.swift
//  IChat
//
//  Created by macbook on 11.01.2023.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

final class AuthService {
    // MARK: Properties
    
    static let shared = AuthService()
    private let auth = Auth.auth()
    
    // MARK: Methods
    
    func login(email: String?, password: String?, completion: @escaping (Result<User, Error>) -> Void) {
        guard let email = email,
              let password = password else {
            completion(.failure(AuthError.notFilled))
            return
        }
        
        auth.signIn(withEmail: email, password: password) { result, error in
            guard let result = result else {
                completion(.failure(error!))
                return
            }
            
            completion(.success(result.user))
        }
    }
    
    func signInGoogle(_ viewController: UIViewController, completion: @escaping (Result<User, Error>) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            completion(.failure(AuthError.clientIdNotFound))
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        
        GIDSignIn.sharedInstance.signIn(with: config, presenting: viewController) { [unowned self] user, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let authentication = user?.authentication,
                  let idToken = authentication.idToken else {
                completion(.failure(AuthError.tokenIdNotFound))
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
            
            auth.signIn(with: credential) { result, error in
                guard let result = result else {
                    completion(.failure(error!))
                    return
                }
                
                completion(.success(result.user))
            }
        }
        
    }
    
    func register(email: String?, password: String?, confirmPassword: String?, completion: @escaping (Result<User, Error>) -> Void) {
        guard Validators.isFilled(email: email, password: password, confirmPassword: confirmPassword) else {
            completion(.failure(AuthError.notFilled))
            return
        }
        
        guard password!.lowercased() == confirmPassword!.lowercased() else {
            completion(.failure(AuthError.passwordsNotMatched))
            return
        }
        
        guard Validators.isSimpleEmail(email!) else {
            completion(.failure(AuthError.invalidEmail))
            return
        }
        
        auth.createUser(withEmail: email!, password: password!) { result, error in
            guard let result = result else {
                completion(.failure(error!))
                return
            }
            
            completion(.success(result.user))
        }
    }
    
}
