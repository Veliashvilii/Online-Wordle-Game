//
//  NormalChooseViewController.swift
//  Online Wordle
//
//  Created by Metehan Veliashvili on 19.04.2024.
//

import UIKit

class NormalChooseViewController: UIViewController {

    var username: String?
    var gameMode: Int?
    
    @IBOutlet var usernameLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        if let username = username {
            usernameLabel.text = username
        }
        if let gameMode = gameMode {
            makeLetterArea(gameMode: gameMode)
        }
    }
    
    func makeLetterArea(gameMode: Int) {
        // Yığın oluştur
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8 // Giriş alanları arasındaki boşluk
        
        // Giriş alanlarını oluştur ve yığına ekle
        for _ in 0..<gameMode {
            let textField = UITextField()
            textField.borderStyle = .roundedRect
            textField.widthAnchor.constraint(equalToConstant: 50).isActive = true // Giriş alanlarının genişliğini ayarla
            stackView.addArrangedSubview(textField)
        }
        
        // Yığını mevcut görünüme ekle
        view.addSubview(stackView)
        
        // Yığının yerini ve boyutunu ayarla (örneğin, yatay ortalamada)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    

}
