import UIKit
import Firebase
import FirebaseFirestore

class NormalModeUserViewController: UITableViewController {
    
    var gameMode: Int?
    var currentUsername: String?
    var users = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let gameMode = self.gameMode!
        print(gameMode)

        Task {
            do {
                // Asenkron fonksiyonu çağır ve sonuçları al
                self.users = try await takeAllUsername()
                // Sonuçları kullan
                print(users)
                // Tabloyu güncelle
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch {
                print("Error: \(error)")
            }
        }
    }
    
    func takeAllUsername() async throws -> [String] {
        let db = Firestore.firestore()
        let querySnapshot = try await db.collection("Modes").document("Normal Mode").collection("\(self.gameMode ?? 0) Letters").getDocuments()
        var usernames = [String]()
        for document in querySnapshot.documents {
            // Belge verisinden "username" alanını al
            if let username = document.data()["username"] as? String {
                usernames.append(username)
            }
        }
        return usernames
    }
    
    //Çözülmesi gereken durum currentUser ın usernameini bir şekilde alıp tableviewden çekmem gerekiyor ki kişi kendine istek atamasın!!!

    
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
