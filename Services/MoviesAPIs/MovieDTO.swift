//
//  MovieDTO.swift
//  Movie Browser
//
//  Created by Alice Surdu on 27.10.2025.
//

import Foundation

// MARK: - List DTO
/// DTO for a paginated list of media items.
struct PageDTO<T: Decodable>: Decodable {
    let Page: Inner
    struct Inner: Decodable { let media: [T] }
}

/// DTO for a single movie item in a list.
struct MovieItemDTO: Decodable {
    let id: Int
    let title: Title
    let averageScore: Int?
    let duration: Int?
    let genres: [String]?
    let coverImage: Cover
    let bannerImage: String?
    
    struct Title: Decodable { let english: String?; let romaji: String?; let native: String? }
    struct Cover: Decodable { let extraLarge: String?; let large: String? }
}

// MARK: - Detail DTO
/// DTO for the full movie detail response.
struct DetailDTO: Decodable {
    let Media: Media
    
    struct Media: Decodable {
        let id: Int
        let title: MovieItemDTO.Title
        let averageScore: Int?
        let duration: Int?
        let genres: [String]?
        let bannerImage: String?
        let coverImage: MovieItemDTO.Cover
        let description: String?
        let countryOfOrigin: String?
        let status: String?
        let characters: Characters?
    }
    
    struct Characters: Decodable {
        let edges: [Edge]
    }
    
    struct Edge: Decodable {
        let node: Node
    }
    
    struct Node: Decodable {
        let id: Int
        let name: Name
        let image: Image?
        
        struct Name: Decodable { let full: String? }
        struct Image: Decodable { let large: String? }
    }
}
