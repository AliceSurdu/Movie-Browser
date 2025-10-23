//
//  Queries.swift
//  Movie Browser
//
//  Created by Alice Surdu on 18.10.2025.
//

import Foundation

enum Queries {
  /// Home / Now Showing – trending desc
  static let trending = """
  query Trending($page:Int=1,$perPage:Int=10){
    Page(page:$page, perPage:$perPage){
      media(type: ANIME, format: MOVIE, sort: TRENDING_DESC){
        id
        title { english romaji native }
        averageScore
        duration
        genres
        coverImage { extraLarge large }
        bannerImage
      }
    }
  }
  """

  /// Home / Popular – SCORE_DESC (potrivit linkului din cerință)
  static let popular = """
  query Popular($page:Int=1,$perPage:Int=10){
    Page(page:$page, perPage:$perPage){
      media(type: ANIME, format: MOVIE, sort: SCORE_DESC){
        id
        title { english romaji native }
        averageScore
        duration
        genres
        coverImage { extraLarge large }
        bannerImage
      }
    }
  }
  """

  /// Detail
  static let detail = """
  query Detail($id:Int!){
    Media(id:$id, type: ANIME){
      id
      title { english romaji native }
      averageScore
      duration
      genres
      bannerImage
      coverImage { extraLarge large }
      description(asHtml:false)
      countryOfOrigin
      status
      characters (role: MAIN, sort: ROLE){
        edges{
          node{ id name{ full } image{ large } }
        }
      }
    }
  }
  """
}
