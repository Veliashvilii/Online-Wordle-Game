import UIKit
import Firebase
import FirebaseFirestore

class NormalChooseViewController: UIViewController, UITextFieldDelegate {

    var username: String?
    var email: String?
    var gameMode: Int?
    
    var remainingTime: Int = 60

    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var wordInput: UITextField!
    
    var timer: Timer?
    
    var database = Database()
    let group = DispatchGroup()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.email = Auth.auth().currentUser?.email
        
        self.group.enter()
        self.database.inGame()
        self.group.leave()
        

        if let username = username {
            usernameLabel.text = username
        }

        // UITextFieldDelegate'i ayarla
        wordInput.delegate = self

        // Gesture Recognizer ekle
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        startTimer()
        
        //self.database.debug()
    }

    // UITextFieldDelegate metodları
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let gameMode = gameMode else {
            return true // gameMode nil ise, sınırlama yapma
        }

        // Eğer karakter eklenmek isteniyorsa ve mevcut karakter sayısı gameMode'dan büyükse eklemeyi engelle
        if let text = textField.text, let textRange = Range(range, in: text) {
            let newText = text.replacingCharacters(in: textRange, with: string)
            if newText.count > gameMode {
                return false
            }
        }
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Klavyeyi kapat
        return true
    }

    @objc func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        view.endEditing(true) // Klavyeyi kapat
    }
    
    @IBAction func confirmTapped(_ sender: Any) {
        // Kelime dosyadan kontrol edilecek
        if let word = wordInput.text, !word.isEmpty {
            if isWordInFile(word: word, fileName: "words.txt") {
                print("Kelime dosyada bulundu.")
                //timer?.invalidate()
                timeLabel.text = "Please wait"
                self.group.enter()
                self.showAlertMessage(title: "Word Submission Successful.", message: "Please wait for your rival..") {
                    self.database.pushWord(user: self.email!, word: word)
                    self.group.leave()
                }
                //self.database.pushWord(user: self.email!, word: word)
                // Kelime dosyada bulunuyorsa burada yapılacak işlemleri ekle
            } else {
                print("Kelime dosyada bulunamadı.")
                // Kelime dosyada bulunmuyorsa burada yapılacak işlemleri ekle
            }
        } else {
            print("Kelime girişi yapılmadı.")
            // Kelime girilmemişse burada yapılacak işlemleri ekle
        }
    }
    
    func isWordInFile(word: String, fileName: String) -> Bool {
        guard let filePath = Bundle.main.path(forResource: fileName, ofType: nil) else {
            print("Dosya bulunamadı.")
            return false
        }
        
        do {
            let content = try String(contentsOfFile: filePath, encoding: .utf8)
            let words = content.components(separatedBy: .whitespacesAndNewlines)
            return words.contains(word)
        } catch {
            print("Dosya içeriği okunamadı: \(error.localizedDescription)")
            return false
        }
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(updateTimeLabel), userInfo: nil, repeats: true)
    }

    @objc func updateTimeLabel() {
        /**
         updateTimeLabel() function is responsible for updating a countdown timer label called timeLabel, which is periodically called by a timer.
         
         This function checks the value of a variable named remainingTime. If the value of remainingTime is greater than zero, the countdown continues, and it updates the remaining time on the timeLabel. If the remainingTime is equal to or less than zero, it indicates that the time has expired, and it displays the text "Time's Up" on the timeLabel. Then, it invalidates the timer, preventing further calls to this function.

         When the time runs out, the checkWord function is called. This function checks a specific word submitted by a user in the database. If the word submitted by the user is found, it displays a warning message with the title "Defeat", indicating that the user has lost the game. If the word is not found, it displays a warning message with the title "Time's Up", indicating that the time has expired, and it restarts the timer.

         This function displays the remaining time for the user during the game process and directs the user's actions when the time expires.
         */
        if remainingTime > 0 {
            remainingTime -= 1
            timeLabel.text = "\(remainingTime) saniye"
        } else {
            timeLabel.text = "Süre doldu"
            timer?.invalidate()
            self.group.enter()
            self.database.checkWord(user: self.email!) { isFoundWord in
                self.group.leave()
                
                if isFoundWord {
                    // Şimdi burada yeni method çalışmalı. Eğer ben de kelime girdiysem oyun alanına segue atıcaz. Eğer sadece rakip girdiyse kayıp ekranına segue atıcaz.
                    self.database.checkWordMine(user: self.email!) { isFoundWordMine in
                        if isFoundWordMine {
                            print("Abi Oyunu Başlatmak İçin Segue Atarım Şimdi!")
                            self.performSegue(withIdentifier: "toBattleAreaVC", sender: nil)
                        } else {
                            print("Segue yapıp kayıp ekranına yönelmeli!")
                        }
                    }
                } else {
                    self.database.checkWordMine(user: self.email!) { isFoundWordMine in
                        if isFoundWordMine {
                            print("Abi Sen Oyunu Kazandın Galip Ekranına Segue Atarım!")
                        } else {
                            self.showAlertMessage(title: "Time's Up", message: "The time has expired. Please proceed to the next steps.") {
                                self.remainingTime = 60
                                self.startTimer() // Zamanlayıcıyı yeniden başlat
                            }
                        }
                    }
                }
            }
        }
    }

    
    func showAlertMessage(title: String, message: String, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            completion()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toBattleAreaVC" {
            if let destination = segue.destination as? BattleAreaViewController {
                destination.gameMode = self.gameMode
                destination.username = self.username
            }
        }
    }
    
    
    
    
}
