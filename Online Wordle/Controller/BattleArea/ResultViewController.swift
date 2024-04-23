//
//  ResultViewController.swift
//  Online Wordle
//
//  Created by Metehan Veliashvili on 23.04.2024.
//

import UIKit

class ResultViewController: UIViewController {
    
    var isFound: Bool?
    @IBOutlet var usernameLabel: UILabel!
    
    var database = Database()
    
    @IBAction func backTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "toBackToMenuVC", sender: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.database.finishedGame()

        if let isFound = isFound {
            if isFound {
                usernameLabel.text = "You Won!"
            } else {
                usernameLabel.text = "You Lose!"
            }
        }
    }
    


}
