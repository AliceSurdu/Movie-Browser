//
//  MovieDetail.swift
//  Movie Browser
//
//  Created by Alice Surdu on 18.10.2025.
//

import Foundation
struct MovieDetail: Hashable {
  let base: Movie
  let synopsis: String
  let country: String?
  let status: String?
  let cast: [Person]
}
