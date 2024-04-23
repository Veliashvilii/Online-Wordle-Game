import UIKit
import Firebase
import FirebaseFirestore

class BattleAreaViewController: UIViewController {
    
    var gameMode: Int?
    var username: String?
    var answer: String?
    
    var database = Database()
    
    var usernameLabel: UILabel!
    var textLabel: UILabel!
    var displayBox = [UILabel]()
    var currentAnswer: UITextField!
    var keyboard = [UIButton]()
    var recentlyPressed = [UIButton]()
    //var answer: String = ""
    var winstreak = 0
    var numberOfSubmits = 0
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        
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
        
        NSLayoutConstraint.activate([
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
            clear.bottomAnchor.constraint(equalTo: submit.bottomAnchor)
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
        guard let guess = currentAnswer?.text else {return}
        
        //Gerçek kelime kontrolü
        
        if guess.count != self.gameMode {
            showError()
            currentAnswer.text = ""
            return
        }
        
        let guessArray = Array(guess)
        let answerArray = Array(self.answer!)
        
        for i in 0..<self.gameMode! {
            let index = (numberOfSubmits*self.gameMode!) + (i)
            if guessArray[i] == answerArray [i] {
                displayBox[index].backgroundColor = .green
            } else if answerArray.contains(guessArray[i]) {
                displayBox[index].backgroundColor = .yellow
            } else {
                displayBox[index].backgroundColor = .gray
            }
            displayBox[index].text = "\(guessArray[i])"
        }
        numberOfSubmits += 1
        currentAnswer.text = ""
        
        if guess == answer {
            //Eğer kullanıcı doğru bilirse yapılacak işlemler
            print("Oyun Sonuç Ekranına Gidilmeli")
            showError()
            return
        }
        
        if numberOfSubmits == self.gameMode! {
            print("Kelime bilme hakkı kalmadı")
            showError()
            return
        }
        
    }
    
    
    
    
    func showError(){
        let alertVC = UIAlertController(title: "Error", message: "Invalid Input", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alertVC, animated: true)
    }
    

}
