//
//  Movie.swift
//  Movie Browser
//
//  Created by Alice Surdu on 18.10.2025.
//

import Foundation

struct Movie: Identifiable, Hashable {
  let id: Int
  let title: String
  let score: Double?
  let duration: Int?
  let genres: [String]
  let posterURL: URL?
  let bannerURL: URL?
}
