//
//  GameModeViewController.swift
//  Online Wordle
//
//  Created by Metehan Veliashvili on 1.04.2024.
//

import UIKit

class GameModeViewController: UIViewController {
    
    
    @IBAction func randomLetterButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "toRandomLetterModeVC", sender: nil)
    }
    @IBAction func normalLetterButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "toNormalModeChooseVC", sender: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
}
