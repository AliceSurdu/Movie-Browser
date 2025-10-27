//
//  Person.swift
//  Movie Browser
//
//  Created by Alice Surdu on 18.10.2025.
//

import Foundation

/// Represents a single cast or crew member.
struct Person: Identifiable, Hashable {
    /// The unique identifier for the person.
    let id: Int
    
    /// The person's full name.
    let name: String
    
    /// The URL for the person's profile image.
    let imageURL: URL?
}
