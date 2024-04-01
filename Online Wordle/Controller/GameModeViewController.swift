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
        performSegue(withIdentifier: "toNormalModeVC", sender: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
