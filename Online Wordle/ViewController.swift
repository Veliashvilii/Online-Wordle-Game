//
//  ViewController.swift
//  Online Wordle
//
//  Created by Metehan Veliashvili on 28.03.2024.
//

import UIKit
import Firebase

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
            Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { authDataResult, error in
                if error != nil {
                    self.showErrorMessage(title: "Error", message: error?.localizedDescription ?? "Unavailable Server, Please Try Again!")
                } else {
                   // self.performSegue(withIdentifier: "toMainVC", sender: nil)
                    print("It's time for login")
                    self.performSegue(withIdentifier: "totabBarVC", sender: nil)
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
    

}

