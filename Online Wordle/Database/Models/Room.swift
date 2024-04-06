//
//  Room.swift
//  Online Wordle
//
//  Created by Metehan Veliashvili on 1.04.2024.
//

import Foundation

public struct Room: Codable {
    var users = [User]()
    var roomType: Int
}
