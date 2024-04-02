//
//  User.swift
//  Online Wordle
//
//  Created by Metehan Veliashvili on 31.03.2024.
//

import Foundation

public struct User: Codable {
    let email: String
    let username: String
    let password: String
    let isActive: Bool
}

public struct UserForRooms: Codable {
    let email: String
    let username: String
    let isActive: Bool
}
