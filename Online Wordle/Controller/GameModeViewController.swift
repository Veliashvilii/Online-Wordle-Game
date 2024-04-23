//
//  GameModeViewController.swift
//  Online Wordle
//
//  Created by Metehan Veliashvili on 1.04.2024.
//

import UIKit

class GameModeViewController: UIViewController {
    
    var gameModes = [4, 5, 6, 7]
    @IBAction func randomLetterButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "toRandomControllerVC", sender: nil)
    }
    @IBAction func normalLetterButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "toNormalModeChooseVC", sender: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toRandomControllerVC" {
            if let destination = segue.destination as? NormalModeUserViewController {
                self.gameModes.shuffle()
                destination.gameMode = gameModes[0]
            }
        }
            
    }
}
