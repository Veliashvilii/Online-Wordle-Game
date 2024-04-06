import UIKit
import Firebase
import FirebaseFirestore

class NormalModeUserViewController: UITableViewController {
    
    var gameMode: Int?
    var username: String?
    var users = [String]()
    var database = Database()

    override func viewDidLoad() {
        super.viewDidLoad()
        let gameMode = self.gameMode!
        
        database.getEmailFromUsername(username: self.username!) { result in
            switch result {
            case .success(let email):
                print("E-posta adresi: \(email)")
            case .failure(let error):
                print("Hata: \(error.localizedDescription)")
            }
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
        showInviteMessage(title: "Game Invite", message: "Do you want to invite \(selectedUser)", selectedUser: selectedUser)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func showInviteMessage(title: String, message: String, selectedUser: String) {
        let inviteVc = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let noButton = UIAlertAction(title: "No", style: .default, handler: nil)
        let yesButton = UIAlertAction(title: "Yes", style: .default) { action in
            // Davet oluşturup Firestore'a kaydetme
            self.sendInvitationToUser(selectedUser)
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
    
    func sendInvitationToUser(_ selectedUser: String) {
        guard let currentUserEmail = Auth.auth().currentUser?.email else {
            return
        }
        
        database.getEmailFromUsername(username: selectedUser) { result in
            switch result {
            case .success(let email):
                let db = Firestore.firestore()
                let invitationData: [String: Any] = [
                    "sender": currentUserEmail,
                    "receiver": email,
                    "status": "pending", // Davetin durumu (kabul edilmedi, reddedilmedi)
                    "timestamp": Date() // Zaman damgası ekleyin
                ]
                
                db.collection("Invitations").addDocument(data: invitationData) { error in
                    if let error = error {
                        print("Error sending invitation: \(error)")
                    } else {
                        print("Invitation sent successfully")
                        self.startInvitationTimer(for: selectedUser)
                    }
                }
            case .failure(let error):
                print("Hata: \(error.localizedDescription)")
            }
        }
    }
    
    func startInvitationTimer(for selectedUser: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { // 10 saniye sonra
            self.checkInvitationStatus(for: selectedUser)
        }
    }

    func checkInvitationStatus(for selectedUser: String) {
        let db = Firestore.firestore()
        let currentUserEmail = Auth.auth().currentUser?.email ?? ""
        
        self.database.getEmailFromUsername(username: selectedUser) { result in
            switch result {
            case .success(let selectedEmail):
                db.collection("Invitations")
                    .whereField("sender", isEqualTo: currentUserEmail)
                    .whereField("receiver", isEqualTo: selectedEmail)
                    .getDocuments { querySnapshot, error in
                        if let error = error {
                            print("Error getting invitation status: \(error)")
                        } else {
                            var invitationFound = false
                            
                            for document in querySnapshot?.documents ?? [] {
                                invitationFound = true
                                
                                if let status = document.data()["status"] as? String {
                                    if status == "pending" {
                                        // Davet hala bekleniyor, reddetme işlemi gerçekleştirilir
                                        self.rejectInvitation(for: selectedUser)
                                        self.showAlertMessage(title: "Sorry..", message: "Your invite is not accepted!")
                                        print("Invitation automatically rejected due to timeout")
                                    } else {
                                        // Davet kabul edildi veya reddedildi, bu durumda bir işlem yapmayız
                                    }
                                }
                            }
                            
                            // Davet bulunamadıysa, davet gönderilmediği için reddetme işlemi gerçekleştirilir
                            if !invitationFound {
                                self.rejectInvitation(for: selectedUser)
                                self.showAlertMessage(title: "Sorry..", message: "We can't found the user!")
                                print("Invitation automatically rejected due to timeout")
                            }
                        }
                    }
            case .failure(let error):
                print("Hata: \(error.localizedDescription)")
            }
        }
        

    }

    func rejectInvitation(for selectedUser: String) {
        let db = Firestore.firestore()
        let currentUserEmail = Auth.auth().currentUser?.email ?? ""
        
        self.database.getEmailFromUsername(username: selectedUser) { result in
            switch result {
            case .success(let selectedEmail):
                db.collection("Invitations")
                    .whereField("sender", isEqualTo: currentUserEmail)
                    .whereField("receiver", isEqualTo: selectedEmail)
                    .getDocuments { querySnapshot, error in
                        if let error = error {
                            print("Error rejecting invitation: \(error)")
                        } else {
                            for document in querySnapshot?.documents ?? [] {
                                document.reference.updateData(["status": "rejected"])
                            }
                        }
                    }
            case .failure(let error):
                print("Hata: \(error.localizedDescription)")
            }
        }
        

    }
    
    // Şu an kullanıcı olarak bir istek yollanıyor backend tarafında ve 10 saniye içinde cevap alınmadığı durumda oyun isteğinin reddedildiği aktif kullanıcıya gösteriliyor. Ancak daveti alan kullanıcı tarafında şu an her hangi bir işlem gerçekleşmiyor. Alıcı gelen ,steği ekranında görem,yor bunun yapılması gerekiyor.


    
}
