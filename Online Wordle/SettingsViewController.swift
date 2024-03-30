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

}
