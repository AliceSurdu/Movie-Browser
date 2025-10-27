//
//  HomeViewModel.swift
//  Movie Browser
//
//  Created by Alice Surdu on 18.10.2025.
//

import Foundation
import Combine

/// Manages the state and business logic for the `HomeView`.
///
/// This ViewModel is responsible for fetching the "Now Showing" and "Popular"
/// movie lists from the API and exposing them to the view.
/// It must be used on the main thread.
@MainActor
final class HomeViewModel: ObservableObject {
    
    // MARK: - Published State
    
    /// The list of movies currently playing in theaters.
    @Published var nowShowing: [Movie] = []
    
    /// The list of popular movies.
    @Published var popular: [Movie] = []
    
    /// True if data is currently being fetched from the API.
    @Published var isLoading = false
    
    /// An optional error message if an API request fails.
    @Published var error: String?

    // MARK: - Dependencies
    
    /// The API service used to fetch movie data.
    private let api: MovieAPIServiceType
    
    // MARK: - Initializer
    
    init(api: MovieAPIServiceType) {
        self.api = api
    }

    // MARK: - Public Methods
    
    /// Fetches all required data for the home screen.
    ///
    /// This method fetches "Now Showing" and "Popular" movies concurrently.
    /// It sets the `isLoading` flag and updates the `error` or data properties
    /// upon completion.
    func load() {
        // Prevent duplicate API calls if already loading
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        
        Task {
            do {
                // Use 'async let' to fetch both lists in parallel
                async let nowShowingTask = api.getNowShowing(input: .init(page: 1, perPage: 10))
                async let popularTask = api.getPopular(input: .init(page: 1, perPage: 10))
                
                // Await the results from both concurrent tasks
                let (nowShowingResponse, popularResponse) = try await (nowShowingTask, popularTask)
                
                // Update the published properties on the main actor
                self.nowShowing = nowShowingResponse.movies
                self.popular = popularResponse.movies
                
            } catch {
                // Store the error message to be displayed in the view
                self.error = error.localizedDescription
            }
            
            // Ensure isLoading is set to false regardless of success or failure
            self.isLoading = false
        }
    }
}
