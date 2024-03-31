//
//  ViewController.swift
//  Online Wordle
//
//  Created by Metehan Veliashvili on 28.03.2024.
//

import UIKit
import Firebase
import FirebaseFirestore

class ViewController: UIViewController {

    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        if emailTextField.text != "" && passwordTextField.text != "" {
            Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { [self] authDataResult, error in
                if let error = error {
                    self.showErrorMessage(title: "Error", message: error.localizedDescription)
                } else {
                    print("It's time for login")
                    self.setActiveUser(email: emailTextField.text!) { error in
                        if let error = error {
                            self.showErrorMessage(title: "Error", message: "Failed to set active user: \(error.localizedDescription)")
                        } else {
                            self.performSegue(withIdentifier: "totabBarVC", sender: nil)
                        }
                    }
                }
            }
        } else {
            self.showErrorMessage(title: "Error", message: "Please fill all blanks!")
        }
    }

    
    func showErrorMessage(title: String, message: String){
        let errorVc = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
        errorVc.addAction(okButton)
        self.present(errorVc, animated: true, completion: nil)
    }
    
    func setActiveUser(email: String, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(email)
        userRef.updateData(["isActive": true]) { error in
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

