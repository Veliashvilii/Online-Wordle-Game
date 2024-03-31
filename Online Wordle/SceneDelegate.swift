//
//  SceneDelegate.swift
//  Online Wordle
//
//  Created by Metehan Veliashvili on 28.03.2024.
//

import UIKit
import Firebase
import FirebaseFirestore

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        // If we had a current user so when you tap to icon for open you don' t need a login every time.
        let currentUser  = Auth.auth().currentUser
        if currentUser != nil {
            let board = UIStoryboard(name: "Main", bundle: nil)
            let tabBar = board.instantiateViewController(identifier: "tabBar") as! UITabBarController
            window?.rootViewController = tabBar
        }
        
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        self.setIsActiveUser(email: Auth.auth().currentUser!.email!, isActive: false) { error in
            if error != nil {
                print("User is Still Active!")
            } else {
                print("User is Passive Now!")
            }
        }
        
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        self.setIsActiveUser(email: Auth.auth().currentUser!.email!, isActive: true) { error in
            if error != nil {
                print("User is Still Active!")
            } else {
                print("User is Passive Now!")
            }
        }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        self.setIsActiveUser(email: Auth.auth().currentUser!.email!, isActive: false) { error in
            if error != nil {
                print("User is Still Active!")
            } else {
                print("User is Passive Now!")
            }
        }
    }
    
    func setIsActiveUser(email: String, isActive: Bool ,completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(email)
        userRef.updateData(["isActive": isActive]) { error in
            if let error = error {
                print("Error updating document: \(error)")
                completion(error)
            } else {
                print("Document successfully updated")
                completion(nil)
            }
        }
    }
    
}

