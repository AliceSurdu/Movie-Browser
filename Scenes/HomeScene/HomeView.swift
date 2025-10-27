//
//  HomeView.swift
//  Movie Browser
//
//  Created by Alice Surdu on 18.10.2025.
//
import SwiftUI

/// The main view for the "Home" tab, displaying lists of movies.
struct HomeView: View {
    
    // MARK: - State
    
    /// The ViewModel managing the state for this view.
    @StateObject var viewModel: HomeViewModel
    
    /// A binding to the `NavigationStack` path from `AppRouter` to allow navigation.
    @Binding var path: [Movie]
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xxl) {
                nowShowingSection
                popularSection
            }
            .padding(.top, Spacing.xxl)
        }
        .onAppear {
            // Load data when the view first appears
            viewModel.load()
        }
        .background(Color(.systemBackground))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // Custom Navigation Bar title
            ToolbarItem(placement: .principal) {
                Text("FilmKu")
                    .font(.custom("Merriweather UltraBold", size: Spacing.lg))
                    .foregroundColor(Color.brand)
            }
            
            // Custom left bar button
            ToolbarItem(placement: .topBarLeading) {
                Image("Union") // Custom menu icon
            }
            
            // Custom right bar button
            ToolbarItem(placement: .topBarTrailing) {
                Image("Notif") // Custom notification icon
            }
        }
    }
    
    // MARK: - Private Subviews
    
    /// The "Now Showing" horizontal scrolling list.
    private var nowShowingSection: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            SectionHeader("Now Showing")
                .padding(.horizontal, Spacing.xxl)
            
            // Check loading/error/success states
            if viewModel.isLoading && viewModel.nowShowing.isEmpty {
                ProgressView().padding(.horizontal)
            } else if !viewModel.nowShowing.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.lg) {
                        ForEach(viewModel.nowShowing, id: \.id) { movie in
                            NowShowingCard(movie: movie) {
                                // Push the selected movie onto the navigation stack
                                path.append(movie)
                            }
                        }
                    }
                    .padding(.leading, Spacing.xxl)
                }
            } else if let error = viewModel.error {
                Text("Failed to load movies: \(error)").padding(.horizontal)
            }
        }
    }
    
    /// The "Popular" vertical list.
    private var popularSection: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            SectionHeader("Popular")
            
            if viewModel.isLoading && viewModel.popular.isEmpty {
                ProgressView()
            } else if !viewModel.popular.isEmpty {
                VStack(spacing: Spacing.lg) {
                    ForEach(viewModel.popular, id: \.id) { movie in
                        PopularCard(movie: movie) {
                            // Push the selected movie onto the navigation stack
                            path.append(movie)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, Spacing.xxl)
    }
}
