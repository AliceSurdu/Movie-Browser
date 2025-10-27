//
//  AppRouter.swift
//  Movie Browser
//
//  Created by Alice Surdu on 18.10.2025.
//

import SwiftUI

enum Tab {
    case home, bookmark, profile
}

struct AppRouter: View {
    @State private var path: [Movie] = []
    @State private var selectedTab: Tab = .home
    
    private var gql: GraphQLClient = DefaultGraphQLClient()
    private let movieAPI: MovieAPIServiceType
    
    init() {
        let client = DefaultGraphQLClient()
        self.gql = client
        self.movieAPI = MovieAPIService(gql: client)
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack(path: $path) {
                HomeView(viewModel: .init(api: movieAPI), path: $path)
                    .navigationDestination(for: Movie.self) { m in
                        MovieDetailView(viewModel: .init(id: m.id, api: self.movieAPI))
                    }
            }
            .tabItem {
                Image(systemName: "movieclapper")
            }
            .tag(Tab.home)
            
            Text("")
                .tabItem {
                    Image(systemName: "ticket")
                }
                .tag(Tab.profile)
            
            Text("Saved Movies")
                .tabItem {
                    Image(systemName: "bookmark")
                }
                .tag(Tab.bookmark)
            
        }
        .tint(.brand)
    }
}
