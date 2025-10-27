//
//  Movie_BrowserApp.swift
//  Movie Browser
//
//  Created by Alice Surdu on 18.10.2025.
//

import SwiftUI

/// The main entry point for the Movie Browser application.
@main
struct MovieApp: App {
    
    // The main window group for the app.
    var body: some Scene {
        WindowGroup {
            // AppRouter handles the root view logic (TabView, Navigation).
            AppRouter()
        }
    }
}
