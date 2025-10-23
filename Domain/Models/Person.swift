//
//  Person.swift
//  Movie Browser
//
//  Created by Alice Surdu on 18.10.2025.
//

import Foundation

struct Person: Identifiable, Hashable {
  let id: Int
  let name: String
  let imageURL: URL?
}
