//
//  SignUpViewController.swift
//  Online Wordle
//
//  Created by Metehan Veliashvili on 28.03.2024.
//

import UIKit
import Firebase
import FirebaseFirestore


class SignUpViewController: UIViewController {

    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var passwordAgainTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        
        // Gesture recognizer'ı view'a ekliyoruz
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func signUpButtonTapped(_ sender: Any) {
        //When users try the sign up the app
        if emailTextField.text != "" && usernameTextField.text != "" && passwordTextField.text != "" && passwordAgainTextField.text != "" {
            if passwordTextField.text == passwordAgainTextField.text {
                Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { authDataResult, error in
                    if error != nil {
                        self.showErrorMessage(title: "Error", message: error?.localizedDescription ?? "Unavailable Server, Please Try Again!")
                    } else {
                        let user = User(email: self.emailTextField.text!, username: self.usernameTextField.text!, password: self.passwordTextField.text!, isActive: false)
                        self.saveUserToDatabase(user: user) // for save to storage
                        self.showErrorMessage(title: "Cong..!", message: "Your Account is Created")
                        self.emailTextField.text = ""
                        self.usernameTextField.text = ""
                        self.passwordTextField.text = ""
                        self.passwordAgainTextField.text = ""
                        print("Üyelik İşlemi tamamlandı!")
                    }
                }
            } else {
                showErrorMessage(title: "Wrong Password", message: "Passwords is not match!")
            }
        } else {
            showErrorMessage(title: "Error", message: "Please fill all blanks!")
        }
    }
    
    func showErrorMessage(title: String, message: String){
        let errorVc = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
        errorVc.addAction(okButton)
        self.present(errorVc, animated: true, completion: nil)
    }
    
    func saveUserToDatabase(user: User){
        let db = Firestore.firestore()
        do {
            try db.collection("users").document(user.email).setData(from: user)
        } catch let error {
          print("Error writing city to Firestore: \(error)")
        }
    }

}
