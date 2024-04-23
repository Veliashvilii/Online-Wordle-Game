import UIKit
import Firebase
import FirebaseFirestore

class BattleAreaViewController: UIViewController {
    
    var gameMode: Int?
    var username: String?
    var email: String?
    var answer: String?
    
    var timer: Timer?
    var remainingTime: Int = 60
    var shortRemainingTime: Int = 10
    
    var database = Database()
    
    var isFound: Bool?
    
    var usernameLabel: UILabel!
    var timeLabel: UILabel!
    var textLabel: UILabel!
    var displayBox = [UILabel]()
    var currentAnswer: UITextField!
    var keyboard = [UIButton]()
    var recentlyPressed = [UIButton]()
    var numberOfSubmits = 0
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor(red: 236/255, green: 245/255, blue: 216/255, alpha: 1.0)
        
        addCloseButton()
        
        timeLabel = UILabel()
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.text = ""
        timeLabel.font = UIFont.systemFont(ofSize: 18)
        view.addSubview(timeLabel)
        
        usernameLabel = UILabel()
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.text = self.username
        usernameLabel.font = UIFont.systemFont(ofSize: 24)
        usernameLabel.textAlignment = .center
        view.addSubview(usernameLabel)
        
        textLabel = UILabel()
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.numberOfLines = 0
        view.addSubview(textLabel)
        
        currentAnswer = UITextField()
        currentAnswer.translatesAutoresizingMaskIntoConstraints = false
        currentAnswer.placeholder = "Tap the keyboard"
        currentAnswer.isUserInteractionEnabled = false
        currentAnswer.textAlignment = .center
        view.addSubview(currentAnswer)
        
        let keyboardLabel = UILabel()
        keyboardLabel.translatesAutoresizingMaskIntoConstraints = false
        keyboardLabel.isUserInteractionEnabled = true
        view.addSubview(keyboardLabel)
        
        let submit = UIButton(type: .system)//default type
        submit.translatesAutoresizingMaskIntoConstraints = false
        submit.setTitle("SUBMIT", for: .normal)
        submit.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        view.addSubview(submit)
        
        let clear = UIButton(type: .system)//default type
        clear.translatesAutoresizingMaskIntoConstraints = false
        clear.setTitle("CLEAR", for: .normal)
        clear.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        view.addSubview(clear)
        
        let rivalButton = UIButton(type: .system)
        rivalButton.translatesAutoresizingMaskIntoConstraints = false
        rivalButton.setTitle("RIVAL", for: .normal)
        rivalButton.addTarget(self, action: #selector(rivalTapped), for: .touchUpInside)
        view.addSubview(rivalButton)
        
        
        NSLayoutConstraint.activate([
            
            timeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            timeLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            usernameLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 25),
            usernameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            textLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 10),
            textLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 75),
            textLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 35),
            textLabel.widthAnchor.constraint(equalToConstant: 400),
            textLabel.heightAnchor.constraint(equalToConstant: 425),
            textLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            currentAnswer.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 10),
            currentAnswer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            currentAnswer.widthAnchor.constraint(equalToConstant: 200),
            
            keyboardLabel.topAnchor.constraint(equalTo: currentAnswer.bottomAnchor,constant: 10),
            keyboardLabel.widthAnchor.constraint(equalToConstant: 350),
            keyboardLabel.heightAnchor.constraint(equalToConstant: 170),
            keyboardLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            submit.topAnchor.constraint(equalTo: keyboardLabel.bottomAnchor, constant: 10),
            submit.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -100),
            submit.heightAnchor.constraint(equalToConstant: 44),
            submit.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
            
            clear.topAnchor.constraint(equalTo: submit.topAnchor),
            clear.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 100),
            clear.heightAnchor.constraint(equalTo: submit.heightAnchor),
            clear.bottomAnchor.constraint(equalTo: submit.bottomAnchor),
            
            rivalButton.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: -50),
            rivalButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
        



        if let gridSize = self.gameMode {
            let width = 30
            let height = 30
            for row in 0..<gridSize{
                for column in 0..<gridSize{
                    
                    let displayLabel = UILabel()
                    let frame = CGRect(x: 25+column*35, y: row*35, width: width, height: height)
                    displayLabel.frame = frame
                    displayLabel.font = UIFont.systemFont(ofSize: 24)
                    displayLabel.textAlignment = .center
                    displayLabel.backgroundColor = UIColor.lightGray
                    textLabel.addSubview(displayLabel)
                    displayBox.append(displayLabel)
                }
                
            }
        }


        let alphabet =  "ABCÇDEFGĞHIİJKLMNOÖPRSŞTUÜVYZ "
        let alphabetArray = Array(alphabet)
        let buttonWidth = 30
        let buttonHeight = 50
        for row in 0..<3{
            for column in 0..<10{
                let letterButton = UIButton(type: .system)
                letterButton.addTarget(self, action: #selector(letterButtonTapped), for: .touchUpInside)
                let buttonFrame = CGRect(x: column*40, y: row*60, width: buttonWidth, height: buttonHeight)
                letterButton.frame = buttonFrame
                keyboardLabel.addSubview(letterButton)
                keyboard.append(letterButton)
            }
        }
        
        if keyboard.count == alphabetArray.count{
            for i in 0..<keyboard.count{
                keyboard[i].setTitle("\(alphabetArray[i])", for: .normal)
            }
        }
        
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let currentUser = Auth.auth().currentUser?.email {
            self.database.takeAnswer(user: currentUser) { isAnswer in
                self.answer = isAnswer
            }
        }
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    @objc func updateTime() {
        if remainingTime > 0 {
            remainingTime -= 1
        } else {
            timer?.invalidate()
            self.showMessage(title: "Warning!", message: "İf you don't enter a word within 10 seconds, you will lose the game.") {
                // 10 saniyelik sayaç başlatılacaktır.
                self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateShortTime), userInfo: nil, repeats: true)
            }
        }
    }
    
    @objc func updateShortTime() {
        if shortRemainingTime > 0 {
            shortRemainingTime -= 1
            self.timeLabel.text = "\(shortRemainingTime)"
        } else {
            timer?.invalidate()
            self.showMessage(title: "Upps..!", message: "Game Over..") {
                self.isFound = false
                self.performSegue(withIdentifier: "toResultVC", sender: nil)
            }
        }
    }
    
    @objc func letterButtonTapped(_ sender: UIButton){
        guard let buttonTitle = sender.titleLabel?.text else{return}
        currentAnswer.text = currentAnswer.text?.appending(buttonTitle)
        recentlyPressed.append(sender)
    }
    
    @objc func clearTapped(_ sender: UIButton){
        currentAnswer.text = ""
        recentlyPressed.removeAll()
    }
    
    @objc func submitTapped(_ sender: UIButton){
        remainingTime = 60
        shortRemainingTime = 10
        timer?.invalidate()
        startTimer()

        guard let guess = currentAnswer?.text else {return}
        
        if isWordInFile(word: guess.lowercased(), fileName: "words.txt") == false {
            showError()
            currentAnswer.text = ""
            return
        }
        
        if guess.count != self.gameMode {
            showError()
            currentAnswer.text = ""
            return
        }
        
        if let answer = self.answer {
            print("Aranan Cevap: \(answer)")
            let upperAnswer = answer.uppercased()
            let guessArray = Array(guess)
            let answerArray = Array(upperAnswer)
            
            print("Tahmin: \(guessArray)")
            print("Cevap: \(answerArray)")
            
            for i in 0..<self.gameMode! {
                let index = (numberOfSubmits*self.gameMode!)+(i)
                if guessArray[i] == answerArray [i] {
                    displayBox[index].backgroundColor =  UIColor(red: 34/255, green: 139/255, blue: 34/255, alpha: 1.0)
                    displayBox[index].textColor = .white
                } else if answerArray.contains(guessArray[i]) {
                    displayBox[index].backgroundColor = UIColor(red: 255/255, green: 215/255, blue: 0/255, alpha: 1.0)
                    displayBox[index].textColor = .white
                } else {
                    displayBox[index].backgroundColor = UIColor(red: 105/255, green: 105/255, blue: 105/255, alpha: 1.0)
                    displayBox[index].textColor = .white
                }
                displayBox[index].text = "\(guessArray[i])"
            }
            self.database.pushGuess(user: self.email!, answer: guess.lowercased(), wordCounter: numberOfSubmits)
            numberOfSubmits += 1
            currentAnswer.text = ""
            
            if guess == upperAnswer {
                //Eğer kullanıcı doğru bilirse yapılacak işlemler
                print("Oyun Sonuç Ekranına Gidilmeli")
                showMessage(title: "Cong!", message: "You found the answer") {
                    self.isFound = true
                    self.performSegue(withIdentifier: "toResultVC", sender: nil)
                }
                return
            }
        } else {
            print("Cevap Değeri Bulunamadı!")
        }
        

        
        if numberOfSubmits == self.gameMode! {
            print("Kelime bilme hakkı kalmadı")
            showError()
            return
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

    func addCloseButton() {
         let closeButton = UIButton(type: .custom)
         closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
         closeButton.tintColor = .black // veya uygun bir renk
         closeButton.addTarget(self, action: #selector(crossButtonTapped), for: .touchUpInside)
         
         view.addSubview(closeButton)
         closeButton.translatesAutoresizingMaskIntoConstraints = false
         
         NSLayoutConstraint.activate([
             closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
             closeButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
             closeButton.widthAnchor.constraint(equalToConstant: 40),
             closeButton.heightAnchor.constraint(equalToConstant: 40)
         ])
     }
    
    @objc func crossButtonTapped () {
        let ac = UIAlertController(title: "Warning!", message: "Exiting the game will result in losing your progress. If you wish to exit, please press the confirm button.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        ac.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { _ in
            self.performSegue(withIdentifier: "toResultVC", sender: nil)
        }))
        present(ac, animated: true, completion: nil)
    }
    
    @objc func rivalTapped () {
        self.performSegue(withIdentifier: "toRivalScreenVc", sender: nil)
    }
    
    
    
    func showError(){
        let alertVC = UIAlertController(title: "Error", message: "Invalid Input", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alertVC, animated: true)
    }
    
    func showMessage(title: String, message: String, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            completion()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toRivalScreenVc" {
            if let destination = segue.destination as? RivalViewController {
                destination.username = self.username!
                destination.email = self.email!
                destination.gridLength = self.gameMode!
            }
        } else if segue.identifier == "toResultVC" {
            if let destination = segue.destination as? ResultViewController {
                destination.isFound = self.isFound!
            }
        }
    }
    

}
