import UIKit
import Firebase
import FirebaseFirestore

class NormalModeUserViewController: UITableViewController {
    
    var gameMode: Int?
    var username: String?
    var users = [String]()
    
    var database = Database()
    
    var listener: ListenerRegistration?
    
    var autoRejectTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        let gameMode = self.gameMode!
        
        if let currentEmail = Auth.auth().currentUser?.email {
            self.listenInvitationRequest(currentEmail: currentEmail)
        }
        
        Task {
            do {
                self.users = try await database.takeAllUsername(gameMode: self.gameMode!)
                self.users = self.users.filter { $0 != self.username } // Remove currentUser from array. because we dont want to see ourself on table. Because we can't battle with ourself..
                print(users)
                // Reload Table
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch {
                print("Error: \(error)")
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //self.listener?.remove()
        database.exitRoom(gameMode: self.gameMode!)
    }
    
    deinit {
        // Invalidate the timer and remove the listener when the view controller is deallocated
        invalidateAutoRejectTimer()
        listener?.remove()
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "normalModeUsersCell", for: indexPath)
        cell.textLabel?.text = users[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedUser = users[indexPath.row]
        self.database.getEmailFromUsername(username: selectedUser) { result in
            switch result {
            case .success(let email):
                self.showInviteMessage(title: "Game Invite", message: "Do you want to invite \(selectedUser)", selectedUser: selectedUser, selectedEmail: email)
            case.failure(let error):
                print("Hata: \(error.localizedDescription)")
            }
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func startAutoRejectTimer(sender: String) {
        autoRejectTimer?.invalidate()
        autoRejectTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false) { timer in
            self.database.answerRequest(sender: sender, answer: "reject")
        }
    }
    
    func invalidateAutoRejectTimer() {
        autoRejectTimer?.invalidate()
    }
    
    
    
    
    func showInviteMessage(title: String, message: String, selectedUser: String, selectedEmail: String) {
        let inviteVc = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let noButton = UIAlertAction(title: "No", style: .default, handler: nil)
        let yesButton = UIAlertAction(title: "Yes", style: .default) { action in
            if let sender = Auth.auth().currentUser?.email {
                // isActive is mean have user active request for game.
                self.database.checkActiveInvitationRequest(sender: sender) { isActive in
                    if isActive {
                        self.showAlertMessage(title: "Active Invitation Exists", message: "You cannot send another invitation as there is an active invitation pending for this user. Please wait for the current invitation to be accepted or canceled before sending a new one.")
                    } else {
                        self.database.sendInvitationRequest(sender: sender, receiver: selectedEmail)
                    }
                }
            }
        }
        inviteVc.addAction(noButton)
        inviteVc.addAction(yesButton)
        self.present(inviteVc, animated: true, completion: nil)
    }
    
    func showInviteRequest(title: String, message: String, sender: String) {
        let requestVc = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let noButton = UIAlertAction(title: "Decline", style: .default) { action in
            self.database.answerRequest(sender: sender, answer: "reject")
        }
        let yesButton = UIAlertAction(title: "Accept", style: .default) { action in
            self.database.answerRequest(sender: sender, answer: "accept")
        }
        requestVc.addAction(noButton)
        requestVc.addAction(yesButton)
        self.present(requestVc, animated: true, completion: nil)
    }
    
    func showAlertMessage(title: String, message: String) {
        let alertVc = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertVc.addAction(okButton)
        self.present(alertVc, animated: true, completion: nil)
    }
    
    func listenInvitationRequest (currentEmail: String){
        /**This code snippet is used to monitor a user's invitations on Firebase Firestore. It filters invitations matching the user's email address and having a status of "pending". Upon receiving an invitation, the user is presented with a prompt titled "Game Invitation" and a message stating "You have been invited to join a multiplayer game." This code enhances user experience by promptly handling invitations as they arrive.*/
        
        let listener = Firestore.firestore().collection("Invitations")
            .whereField("receiver", isEqualTo: currentEmail)
            .whereField("status", isEqualTo: "pending")
            .addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching invitations: \(String(describing: error))")
                    return
                }
                
                if snapshot.isEmpty {
                    print("Snapshot is empty, Maybe user enter to room at first time or user don' t have a request!")
                } else {
                    for document in snapshot.documents {
                        let data = document.data()
                        
                        if let sender = data["sender"] as? String {
                            self.showInviteRequest(title: "Game Invitation", message: "You have been invited to join a multiplayer game.", sender: sender)
                            self.startAutoRejectTimer(sender:sender)
                        }
                    }
                }
            }
        self.listener = listener
    }
    
    func listenInvitationAnswers (currentEmail: String) {
        
    }
    
    
    
    
    
}
