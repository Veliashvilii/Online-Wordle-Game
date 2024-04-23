//
//  RivalViewController.swift
//  Online Wordle
//
//  Created by Metehan Veliashvili on 23.04.2024.
//

import UIKit

class RivalViewController: UIViewController {
    
    var username: String?
    var email: String?
    var gridLength: Int?
    var textLabel: UILabel!
    var usernameLabel: UILabel!
    var displayBox = [UILabel]()
    
    var guessArray: [String] = []
    
    var database = Database()

    override func viewDidLoad() {
        super.viewDidLoad()


    }
    
    override func loadView() {
        
        view = UIView()
        view.backgroundColor = .white
        
        usernameLabel = UILabel()
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.text = "\(self.username!)"
        usernameLabel.font = UIFont.systemFont(ofSize: 24)
        usernameLabel.textAlignment = .center
        view.addSubview(usernameLabel)
        
        textLabel = UILabel()
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.numberOfLines = 0
        view.addSubview(textLabel)
        
        NSLayoutConstraint.activate([
            usernameLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 25),
            usernameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            textLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 10),
            textLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 75),
            textLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 35),
            textLabel.widthAnchor.constraint(equalToConstant: 400),
            textLabel.heightAnchor.constraint(equalToConstant: 425),
            textLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
        
        if let gridSize = self.gridLength {
            let width = 30
            let height = 30
            for row in 0..<gridSize{
                for column in 0..<gridSize{
                    let displayLabel = UILabel()
                    let frame = CGRect(x: 25+column*35, y: row*35, width: width, height: height)
                    displayLabel.frame = frame
                    displayLabel.font = UIFont.systemFont(ofSize: 24)
                    displayLabel.textAlignment = .center
                    displayLabel.textColor = .white
                    displayLabel.backgroundColor = UIColor.lightGray
                    textLabel.addSubview(displayLabel)
                    displayBox.append(displayLabel)
                }
            }
            
            self.database.getGuesses(user: self.email!) { allGuesses, error in
                if let error = error {
                    print("Hata: \(error)")
                } else if let allGuesses = allGuesses {
                    for guess in 0..<allGuesses.count {
                        let result = allGuesses[guess]
                        let resultArray = Array(result)
                        print("Result: \(result)")
                        print("ResultArray: \(resultArray)")
                        for i in 0..<gridSize {
                            let index = (guess * gridSize) + (i)
                            self.displayBox[index].text = "\(resultArray[i])"
                            print("ResultArray[i]: \(resultArray[i])")
                        }
                    }
                    
                }
            }

        }
        
        
        
    }

   
}



