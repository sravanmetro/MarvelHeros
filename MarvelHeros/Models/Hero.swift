//
//  Hero.swift
//  MarvelHeros
//
//  Created by Sravan on 16/07/2025.
//


import Foundation
struct Hero: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    let name, teamName, realName, imageURL, createdBy, publisher, firstAppearance, bio: String
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case teamName = "team"
        case realName = "realname"
        case firstAppearance = "firstappearance"
        case createdBy = "createdby"
        case publisher = "publisher"
        case imageURL = "imageurl"
        case bio = "bio"
    }
}
