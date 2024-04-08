import UIKit
import Firebase
import FirebaseFirestore

class NormalModeUserViewController: UITableViewController {
    
    var gameMode: Int?
    var username: String?
    var users = [String]()
    var database = Database()
    var listener: ListenerRegistration?

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
        self.listener?.remove()
        database.exitRoom(gameMode: self.gameMode!)
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
    
    func showAlertMessage(title: String, message: String) {
        let alertVc = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertVc.addAction(okButton)
        self.present(alertVc, animated: true, completion: nil)
    }
    
    func listenInvitationRequest (currentEmail: String){
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
                    self.showAlertMessage(title: "Cong!!", message: "You have a request now.")
                }
            }
        self.listener = listener
    }
    

    
    // Şu an kullanıcı olarak bir istek yollanıyor backend tarafında ve 10 saniye içinde cevap alınmadığı durumda oyun isteğinin reddedildiği aktif kullanıcıya gösteriliyor. Ancak daveti alan kullanıcı tarafında şu an her hangi bir işlem gerçekleşmiyor. Alıcı gelen ,steği ekranında görem,yor bunun yapılması gerekiyor.


    
}
