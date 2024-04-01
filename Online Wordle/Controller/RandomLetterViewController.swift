//
//  RandomLetterViewController.swift
//  Online Wordle
//
//  Created by Metehan Veliashvili on 1.04.2024.
//

import UIKit

class RandomLetterViewController: UITableViewController {

    var deneme = [String()]
    override func viewDidLoad() {
        super.viewDidLoad()
        deneme = ["a", "b", "c", "d", "e"]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "randomLetterUser", for: indexPath)
        //let dene = deneme[indexPath.row]
        cell.textLabel?.text = "dene"
        return cell
    }

}
