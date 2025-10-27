//
//  MovieDetailViewModel.swift
//  Movie Browser
//
//  Created by Alice Surdu on 18.10.2025.
//

import Foundation
import Combine

/// Manages the state and business logic for the `MovieDetailView`.
///
/// This ViewModel fetches the detailed information for a *single* movie
/// based on its ID.
/// It must be used on the main thread.
@MainActor
final class MovieDetailViewModel: ObservableObject {
    
    // MARK: - Published State
    
    /// The detailed movie object. Nil if not yet loaded.
    @Published var detail: MovieDetail?
    
    /// True if data is currently being fetched from the API.
    @Published var isLoading = false
    
    /// An optional error message if the API request fails.
    @Published var error: String?

    // MARK: - Properties
    
    /// The unique ID of the movie to fetch.
    private let id: Int
    
    /// The API service used to fetch movie data.
    private let api: MovieAPIServiceType

    // MARK: - Initializer
    
    init(id: Int, api: MovieAPIServiceType) {
        self.id = id
        self.api = api
    }

    // MARK: - Public Methods
    
    /// Fetches the movie details from the API.
    func load() {
        // Prevent duplicate API calls
        guard !isLoading else { return }
        
        isLoading = true
        error = nil

        Task {
            do {
                let output = try await api.getMovieDetail(input: .init(id: id))
                self.detail = output.detail
            } catch let err {
                self.error = err.localizedDescription
            }
            self.isLoading = false
        }
    }
}
