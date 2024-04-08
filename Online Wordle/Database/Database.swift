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
    
    func sendInvitationRequest(sender: String, receiver: String) {
        let invitationData: [String: Any] = [
            "sender": sender,
            "receiver": receiver,
            "status": "pending",
            "timestamp": Date()
        ]
        self.database.collection("Invitations").addDocument(data: invitationData) { error in
            if let error = error {
                print("Error sending invitation: \(error)")
            } else {
                print("Invitation sent successfully")
            }
            
        }
    }
    
    func checkActiveInvitationRequest(sender: String, completion: @escaping (Bool) -> Void) {
        /**
           This function checks if there is an active invitation request from the specified sender in the Firestore database.
           It queries the 'Invitations' collection for documents where the sender is equal to the provided sender's email and
           the status is 'pending'. If any such document is found, it sets 'isActive' to true; otherwise, it remains false.
           Upon completion, the 'isActive' status is passed to the completion handler.
        */

        var isActive = false
        self.database.collection("Invitations")
            .whereField("sender", isEqualTo: sender)
            .whereField("status", isEqualTo: "pending")
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching invitations when checking active: \(error)")
                } else {
                    for document in querySnapshot?.documents ?? [] {
                        if let status = document.data()["status"] as? String {
                            if status == "pending" {
                                isActive = true
                                break
                            }
                        }
                    }
                }
                completion(isActive)
            }
    }
    
    func listenInvitationRequest(receiver: String, completion: @escaping (Bool, Error?) -> Void) {
        self.database.collection("Invitations")
            .whereField("receiver", isEqualTo: receiver)
            .whereField("status", isEqualTo: "pending")
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching invitations: \(error)")
                    completion(false, error)
                    return
                }
                
                if let documents = querySnapshot?.documents, !documents.isEmpty {
                    // Davet isteği var
                    completion(true, nil)
                } else {
                    // Davet isteği yok
                    completion(false, nil)
                }
            }
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
