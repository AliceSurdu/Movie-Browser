//
//  README.md
//  Movie Browser
//
//  Created by Alice Surdu on 27.10.2025.
//

# FilmKu Movie Browser

FilmKu is a modern, SwiftUI-based iOS application for browsing and discovering movies. It's built using a clean MVVM architecture, leverages Swift Concurrency for networking, and communicates with the AniList GraphQL API to fetch movie data.

## Features

* **Discover Movies:** Browse two main sections: "Now Showing" (Trending) and "Popular" (Top Scored).
* **Movie Details:** View a detailed screen for each movie, including a custom hero banner, synopsis, cast, and metadata.
* **Modern UI:** A clean, custom-designed user interface.
* **Native Navigation:** Uses SwiftUI's `NavigationStack` for detail presentation and a native `TabView` for root navigation.

---

## 🛠️ Tech Stack & Architecture

* **Architecture:** **MVVM** (Model-View-ViewModel)
* **UI:** **SwiftUI**
* **State Management:** **Combine** (`@Published`, `@StateObject`)
* **Networking:** **Swift Concurrency** (`async/await`, `Task`, `async let`)
* **API:** **GraphQL** (AniList API)
* **Navigation:** `TabView` and `NavigationStack`

---

## Build & Run Instructions

To build and run this project successfully, you must configure the required custom assets (fonts and icons) first.

### 1. Prerequisites

* Xcode 15.0 or later
* iOS 17.0+

### 2. Asset Configuration

This project will not build or run correctly until these assets are added to **`Assets.xcassets`**:

**a) Colors:**
You must add these custom color sets:
* `Brand` (The primary brand color)
* `TextSecondary` (The light gray color for subtitles)
* `TextPrimary` (The primary text color for selected chips)
* `ChipBG` (The light background for selected chips)
* `ChipText` (The light background for selected chips)


**b) Icons:**
Add these custom PNG/SVG images:
* `Union` (The "hamburger" menu icon for `HomeView`)
* `Notif` (The notification bell icon for `HomeView`)

**c) Fonts:**
The UI relies on custom fonts.
1.  Add the font files (e.g., `.ttf`) to your project.
2.  In your `Info.plist` file, add the key **"Fonts provided by application"** (`UIAppFonts`) and add string items for each font file name (e.g., `Mulish-Bold.ttf`, `Mulish-Regular.ttf`, `Merriweather-UltraBold.ttf`).

### 3. Run the App

Once all assets are configured:
1.  Open the `.xcodeproj` file in Xcode.
2.  Select your target device or simulator.
3.  Press **Cmd + R** to build and run.

---

## 🧠 Design Decisions, Trade-offs & Challenges

This section documents key architectural decisions made during development.

### 1. Networking: Custom GraphQL Client
* **Decision:** We built a lightweight, `async/await`-based `GraphQLClient` from scratch instead of using a large third-party library like Apollo.
* **Trade-off:**
    * **Pro:** Zero external dependencies. Full control over the networking stack and it's lightweight.
    * **Con:** We must manually write all GraphQL query strings (`Queries.swift`) and maintain all DTOs and Mappers.

### 2. Data Flow: DTOs vs. Models
* **Decision:** We strictly separated API-facing models (**DTOs**, e.g., `MovieItemDTO`) from UI-facing models (**Models**, e.g., `Movie`). The `MovieMapper` converts between them.
* **Trade-off:**
    * **Pro:** This **decouples the UI from the API**. If the API response changes, we only update the DTO and the Mapper. The SwiftUI Views remain unchanged.
    * **Con:** It requires slightly more boilerplate code (DTOs + Mapper logic).

### 3. UI: Native Tab Bar
* **Decision:** The application uses native SF Symbols (e.g., `Image(systemName: "ticket")`) for the `TabView` icons instead of attempting to use fully custom-designed icons.
* **Trade-off:**
    * **Pro:** This ensures a **consistent visual state** (selected vs. unselected) for all tab items. It is generally good practice to use native components like `TabView` as they provide reliability, accessibility, and platform-familiarity out-of-the-box.
    * **Rationale:** The custom "Home" icon (`movieRoll`) was provided without a corresponding "not selected" state. To avoid a jarring UI where one icon has a custom style and the others have a native (gray) style, we opted for **visual unity** by using native icons for all tabs.

### 4. UI: Custom Hero vs. Native Navigation
* **Decision:** The `MovieDetailView` features a completely custom header. The hero image is part of the `ScrollView`, and custom "Back" / "Menu" buttons are overlaid. The native `UINavigationBar` is hidden.
* **Trade-off:**
    * **Pro:** Achieves the pixel-perfect design specified in Figma (overlapping card, buttons directly on the image).
    * **Con:** This is more complex than using a native navigation bar. We must manually handle:
        1.  **Safe Area:** Manually adding padding (`.padding(.top, 55)`) to avoid the status bar.
        2.  **Back Action:** Manually injecting `@Environment(\.dismiss)` to make our custom back button work.
        3.  **Hiding Native UI:** We must explicitly call `.navigationBarBackButtonHidden(true)` and `.toolbar(.hidden, for: .tabBar)`.
