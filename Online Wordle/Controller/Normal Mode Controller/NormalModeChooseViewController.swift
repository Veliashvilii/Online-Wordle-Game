//
//  NormalModeChooseViewController.swift
//  Online Wordle
//
//  Created by Metehan Veliashvili on 1.04.2024.
//

import UIKit
import Firebase
import FirebaseFirestore

class NormalModeChooseViewController: UIViewController {
    
    private var gameMode: Int = 0
    private var username: String = ""
    
    @IBAction func fourLetterRoomTapped(_ sender: Any) {
        self.gameMode = 4
        loginToRoom(roomType: self.gameMode)
    }
    
    @IBAction func fiveLetterRoomTapped(_ sender: Any) {
        self.gameMode = 5
        loginToRoom(roomType: self.gameMode)
    }
    
    
    @IBAction func sixLetterRoomTapped(_ sender: Any) {
        self.gameMode = 6
        loginToRoom(roomType: self.gameMode)
    }
    
    
    @IBAction func sevenLetterButtonTapped(_ sender: Any) {
        self.gameMode = 7
        loginToRoom(roomType: self.gameMode)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toNormalModeUserVC" {
            if let destination = segue.destination as? NormalModeUserViewController {
                destination.gameMode = self.gameMode
                if let username = sender as? String {
                    destination.username = username
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func loginToRoom(roomType: Int) {
        // Facilitates the login process for users into a specific room type within a Firestore database. It first checks for the currently authenticated user and retrieves their username from the database. Then, it writes the user's email and username to the Firestore database under a specific location based on the room type provided. The function includes error handling to manage scenarios such as document not found or errors during data writing...
        let db = Firestore.firestore()
        if let email = Auth.auth().currentUser?.email {
            let userRef = db.collection("users").document(email)
            userRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    
                    if let userData = document.data(), let username = userData["username"] as? String, let isActive = userData["isActive"] as? Bool {
                        self.username = username
                        let user = UserForRooms(email: email, username: username, isActive: isActive)
                        do {
                            try db.collection("Modes").document("Normal Mode").collection("\(roomType) Letters").document(email).setData(from: user)
                            self.performSegue(withIdentifier: "toNormalModeUserVC", sender: username)
                        } catch let error {
                          print("Error writing user to Firestore (Normal Mode): \(error)")
                        }
                    } else {
                        print("Username Not Found!")
                    }
                } else {
                    print("Document is not found!: \(error?.localizedDescription ?? "Unknown Error!")")
                }
            }
        }
    }

}
