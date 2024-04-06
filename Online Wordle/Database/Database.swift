//
//  Database.swift
//  Online Wordle
//
//  Created by Metehan Veliashvili on 6.04.2024.
//

import Foundation
import Firebase
import FirebaseFirestore

class Database {
    private let database = Firestore.firestore()
    
    init() {
       
    }
    
    func getEmailFromUsername(username: String, completion: @escaping (Result<String, Error>) -> Void) {
        let usersCollection = self.database.collection("users")
        // Kullanıcı adına göre sorgu yap
        usersCollection.whereField("username", isEqualTo: username)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    // Hata durumunda geri dön
                    completion(.failure(error))
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    // Belirli bir belge bulunamadıysa
                    completion(.failure(NSError(domain: "Firestore", code: 404, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı bulunamadı"])))
                    return
                }
                
                // Belge bulundu, e-posta adresini al
                if let document = documents.first, let email = document.data()["email"] as? String {
                    completion(.success(email))
                } else {
                    // Belirli bir belge bulunamadıysa
                    completion(.failure(NSError(domain: "Firestore", code: 404, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı bulunamadı"])))
                }
        }
    }
    
    func takeAllUsername(gameMode: Int) async throws -> [String] {
        // This part is takes all usernames and pushes the array. Because we need to see online people in our room.
        let querySnapshot = try await self.database.collection("Modes").document("Normal Mode").collection("\(gameMode) Letters").getDocuments()
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
    
    func exitRoom(gameMode: Int) {
        if let email = Auth.auth().currentUser?.email {
            // When you close the screen you disconnet from the room's databaase.
            let group = DispatchGroup()
            group.enter()
            
            self.database.collection("Modes").document("Normal Mode").collection("\(gameMode) Letters").document(email).delete { error in
                if let error = error {
                    print("Error deleting document: \(error)")
                } else {
                    print("Document successfully deleted")
                }
                group.leave()
            }
            group.wait() // Wait all threads for ends.
        }
    }
    

}
