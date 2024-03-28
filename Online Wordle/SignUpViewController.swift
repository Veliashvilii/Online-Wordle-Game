//
//  SignUpViewController.swift
//  Online Wordle
//
//  Created by Metehan Veliashvili on 28.03.2024.
//

import UIKit
import Firebase

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
        if emailTextField.text != "" && usernameTextField.text != "" && passwordTextField.text != "" && passwordAgainTextField.text != "" {
            if passwordTextField.text == passwordAgainTextField.text {
                Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { authDataResult, error in
                    if error != nil {
                        self.showErrorMessage(title: "Error", message: error?.localizedDescription ?? "Unavailable Server, Please Try Again!")
                    } else {
                        //self.performSegue(withIdentifier: "tologinVC", sender: nil)
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
