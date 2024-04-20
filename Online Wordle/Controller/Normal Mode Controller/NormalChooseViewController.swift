import UIKit

class NormalChooseViewController: UIViewController, UITextFieldDelegate {

    var username: String?
    var gameMode: Int?
    
    var remainingTime: Int = 60

    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var wordInput: UITextField!
    
    var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let username = username {
            usernameLabel.text = username
        }

        // UITextFieldDelegate'i ayarla
        wordInput.delegate = self

        // Gesture Recognizer ekle
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        startTimer()
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
                timer?.invalidate()
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
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimeLabel), userInfo: nil, repeats: true)
    }

    @objc func updateTimeLabel() {
        if remainingTime > 0 {
            remainingTime -= 1
            timeLabel.text = "\(remainingTime) saniye"
        } else {
            timer?.invalidate() // Timer'ı durdur
            timeLabel.text = "Süre doldu"
            self.showAlertMessage(title: "Time's Up", message: "The time has expired. Please proceed to the next steps.")
        }
    }
    
    func showAlertMessage (title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertVC.addAction(okButton)
        present(alertVC, animated: true)
    }
    
    
    
    
}
