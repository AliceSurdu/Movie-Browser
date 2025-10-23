//
//  MovieAPIServiceType.swift
//  Movie Browser
//
//  Created by Alice Surdu on 18.10.2025.
//

import Foundation

protocol MovieAPIServiceType {
  func getNowShowing(input: GetNowShowingInput) async throws -> MoviesListOutput
  func getPopular(input: GetPopularInput) async throws -> MoviesListOutput
  func getMovieDetail(input: GetMovieDetailInput) async throws -> MovieDetailOutput
}
