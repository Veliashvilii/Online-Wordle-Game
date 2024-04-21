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
    
    func answerRequest(sender: String, answer: String, completion: @escaping () -> Void) {
        /**
         This function allows the user to respond to invitations. It queries the "Invitations" collection in Firebase Firestore with the provided sender and answer parameters, filtering documents with a "pending" status. Then, as it processes each document, it updates the status of the document with the specified response (answer). This update operation is performed by referencing the document and executed individually for each document. If an error occurs, an error message is printed; otherwise, a message indicating successful completion is displayed. This piece of code manages the user's response to invitations and updates documents in Firestore accordingly.
         */
        self.database.collection("Invitations")
            .whereField("sender", isEqualTo: sender)
            .whereField("status", isEqualTo: "pending")
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error answer invitations when checking active: \(error)")
                } else {
                    for document in querySnapshot!.documents {
                        let documentRef = self.database.collection("Invitations").document(document.documentID)
                        documentRef.updateData(["status": answer]) { error in
                            if let error = error {
                                print("Error updating document: \(error)")
                            } else {
                                print("Document successfully updated")
                                // Firestore işlemleri tamamlandığında tamamlama bloğunu çağır
                                completion()
                            }
                        }
                    }
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
    
    func inGame() {
        /**
         This code snippet contains a function that updates the status of game invitations in a Firestore database based on the email address of the currently logged-in user. It checks invitations sent by or received by the user and updates their status to "in-game". Error handling is included to print error messages to the console if any occur. This organized and comprehensible code is used to accurately update the status of game invitations.
         */
        if let email = Auth.auth().currentUser?.email {
            self.database.collection("Invitations")
                .whereField("sender", isEqualTo: email)
                .getDocuments { (snapshot, error) in
                    if let error = error {
                        print("Error getting documents: \(error)")
                    } else {
                        if snapshot!.isEmpty {
                            // Gönderen olarak belirtilmiş belge yok, o zaman alıcı olarak kontrol et
                            self.database.collection("Invitations")
                                .whereField("receiver", isEqualTo: email)
                                .getDocuments { (receiverSnapshot, receiverError) in
                                    if let receiverError = receiverError {
                                        print("Error getting documents: \(receiverError)")
                                    } else {
                                        for document in receiverSnapshot!.documents {
                                            let documentID = document.documentID
                                            self.updateStatus(documentID: documentID, status: "in-game")
                                        }
                                    }
                                }
                        } else {
                            for document in snapshot!.documents {
                                let documentID = document.documentID
                                self.updateStatus(documentID: documentID, status: "in-game")
                            }
                        }
                    }
                }
        }
    }
    
    
    func updateStatus(documentID: String, status: String) {
        let documentRef = self.database.collection("Invitations").document(documentID)
        documentRef.updateData(["status": status]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    func getBattleInfos(completion: @escaping (String?, String?) -> Void) {
        /**
         The "getBattleInfos" function aims to retrieve documents from a collection in Firebase based on specific conditions. The function first checks the user's authentication status, and if the user is authenticated, it retrieves the current user's email address. It then queries documents that contain this email address either as the sender or the receiver. It first attempts to fetch documents where the email address is listed as the sender, and if none are found, it retrieves documents where the email address is listed as the receiver. In both cases, it processes the data of the retrieved documents and calls a completion block when the relevant operation is completed. If no documents are found or an error occurs, it calls the completion block with nil values and prints appropriate error messages. This function can be used to fetch information related to invitations for a specific user.
         */
        if let email = Auth.auth().currentUser?.email {
            self.database.collection("Invitations")
                .whereField("sender", isEqualTo: email)
                .getDocuments { (snapshot, error) in
                    if let error = error {
                        print("Error getting documents: \(error)")
                        completion(nil, nil)
                    } else {
                        if snapshot!.isEmpty {
                            // Gönderen olarak belirtilmiş belge yok, o zaman alıcı olarak kontrol et
                            self.database.collection("Invitations")
                                .whereField("receiver", isEqualTo: email)
                                .getDocuments { (receiverSnapshot, receiverError) in
                                    if let receiverError = receiverError {
                                        print("Error getting documents: \(receiverError)")
                                        completion(nil, nil)
                                    } else {
                                        for document in receiverSnapshot!.documents {
                                            let data = document.data()
                                            if let sender = data["sender"] as? String {
                                                completion(sender, document.documentID)
                                                return
                                            }
                                        }
                                        completion(nil, nil) // Alıcı olarak belirtilmiş belge yok
                                    }
                                }
                        } else {
                            for document in snapshot!.documents {
                                let data = document.data()
                                if let receiver = data["receiver"] as? String {
                                    completion(receiver, document.documentID)
                                    return
                                }
                            }
                            completion(nil, nil) // Gönderen olarak belirtilmiş belge yok
                        }
                    }
                }
        } else {
            completion(nil, nil) // Kullanıcı oturumu yok
        }
    }


    
    func pushWord(user: String, word: String) {
        /**
         The "pushWord" function is designed to add a word to a subcollection named "Words" within a specific document in the "Invitations" collection in Firebase. First, it calls the getBattleInfos function to obtain information about the battle, including the rival's user ID and the ID of the document containing the battle details. If this information is successfully retrieved, it constructs a dictionary containing the user's ID, the rival's ID, and the word to be pushed. Subsequently, it accesses the Firebase database, navigates to the specified document within the "Invitations" collection, and then to the "Words" subcollection, where it adds a new document containing the word data. This function facilitates the process of submitting words during a battle or game between users.
         */
        self.getBattleInfos { rival, documentID in
            if let rival = rival, let documentID = documentID {
                let wordData: [String: Any] = [
                    "user": user,
                    "rival": rival,
                    "word": word,
                ]
                self.database.collection("Invitations").document(documentID).collection("Words").addDocument(data: ["words": wordData])
            }
        }
    }

    

}
