import UIKit
import Firebase
import FirebaseFirestore

class NormalModeUserViewController: UITableViewController {
    
    var gameMode: Int?
    var username: String?
    var users = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        let gameMode = self.gameMode!

        Task {
            do {
                self.users = try await takeAllUsername()
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
    
    func takeAllUsername() async throws -> [String] {
        // This part is takes all usernames and pushes the array. Because we need to see online people in our room.
        let db = Firestore.firestore()
        let querySnapshot = try await db.collection("Modes").document("Normal Mode").collection("\(self.gameMode ?? 0) Letters").getDocuments()
        var usernames = [String]()
        for document in querySnapshot.documents {
            if let username = document.data()["username"] as? String, let isActive = document.data()["isActive"] as? Bool {
                if isActive {
                    usernames.append(username)
                } else {
                    print("User is offline: \(username)")
                }
            }
        }
        return usernames
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "normalModeUsersCell", for: indexPath)
        //let dene = deneme[indexPath.row]
        cell.textLabel?.text = users[indexPath.row]
        return cell
    }
}
