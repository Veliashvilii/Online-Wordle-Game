//
//  SettingsViewController.swift
//  Online Wordle
//
//  Created by Metehan Veliashvili on 28.03.2024.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController {



    @IBAction func quitButtonTapped(_ sender: Any) {
        showQuestionMessage(title: "Quit?", message: "Are you sure about that?")
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func showQuestionMessage(title: String, message: String){
        let questionVc = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let noButton = UIAlertAction(title: "No", style: .default, handler: nil)
        let yesButton = UIAlertAction(title: "Yes", style: .default) { action in
                do{
                    self.setIsActiveUser(email: Auth.auth().currentUser!.email!, isActive: false) { error in
                        if error != nil {
                            print("Kullanıcı Aktif")
                        } else {
                            print("Kullanıcı Pasif")
                        }
                    }
                    try Auth.auth().signOut()
                } catch {
                    print("Error")
                }
                self.performSegue(withIdentifier: "toViewController", sender: nil)
            }
        questionVc.addAction(noButton)
        questionVc.addAction(yesButton)
        
        self.present(questionVc, animated: true, completion: nil)
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
