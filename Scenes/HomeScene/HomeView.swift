import SwiftUI

// MARK: - Componente Auxiliare

/// 2. Card pentru secțiunea "Now Showing" (Orizontal)
struct NowShowingCard: View {
    let movie: Movie
    // Closure pentru a gestiona acțiunea de navigare
    var onTap: () -> Void
    
    // Înălțimea și lățimea fixă pentru card
    private let cardWidth: CGFloat = 140
    private let cardHeight: CGFloat = 212
    private let cardRadius: CGFloat = 5
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Poster (AsyncImage)
            AsyncImage(url: movie.posterURL) { result in
                if let result = result.image {
                    result
                        .resizable()
                        .scaledToFill()
                } else {
                    Color.gray.opacity(0.2)
                    // Asigurăm că placeholder-ul are aceleași dimensiuni
                        .frame(width: cardWidth, height: cardHeight)
                }
            }
            .frame(width: cardWidth, height: cardHeight)    // 👈 fixed size
            .clipShape(RoundedRectangle(cornerRadius: cardRadius, style: .continuous))
            .clipped()
            .shadow(color: .black.opacity(0.08), radius: 6, y: Spacing.xs)
            
            // Titlu
            Text(movie.title)
                .font(.custom("Mulish-Bold", size: Spacing.mdPlus))
                .lineLimit(2)
                .truncationMode(.tail)
            
            // Rating IMDb
            if let score = movie.score {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    Text("\(score, specifier: "%.1f")/10 IMDb")
                        .font(.custom("Mulish-Regular", size: Spacing.md))
                        .foregroundColor(Color.textSecondary)
                }
            }
        }
        // Setăm lățimea fixă a întregului card
        .frame(width: cardWidth)
        .onTapGesture(perform: onTap)
    }
}

/// 3. Card pentru secțiunea "Popular" (Vertical)
struct PopularCard: View {
    let movie: Movie
    // Closure pentru a gestiona acțiunea de navigare
    var onTap: () -> Void
    
    private func formattedDuration(minutes: Int?) -> String {
        guard let minutes = minutes, minutes > 0 else { return "N/A" }
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        return "\(hours)h \(remainingMinutes)min"
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: Spacing.lg) {
            AsyncImage(url: movie.posterURL) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Color.gray.opacity(0.2)
                }
            }
            .frame(width: 80, height: 120)
            .cornerRadius(5)
            .clipped()
            
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text(movie.title)
                    .font(.custom("Mulish-Bold", size: Spacing.mdPlus))
                    .lineLimit(3)
                
                // Rating IMDb
                if let score = movie.score {
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("\(score, specifier: "%.1f")/10 IMDb")
                            .font(.custom("Mulish-Regular", size: Spacing.md))
                            .foregroundColor(Color.textSecondary)
                    }
                }
                
                // Genuri
                HStack {
                    ForEach(movie.genres.prefix(3), id: \.self) { genre in
                        GenreTag(text: genre)
                    }
                }
                
                // Durată
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "clock")
                        .foregroundColor(.black)
                    Text(formattedDuration(minutes: movie.duration))
                        .font(.custom("Mulish-Regular", size: Spacing.md))
                        .foregroundColor(.black)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onTapGesture(perform: onTap) // Acțiunea de navigare la tap
    }
}


// MARK: - View Principală

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel
    @Binding var path: [Movie]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xxl) {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    SectionHeader("Now Showing")
                        .padding(.horizontal, Spacing.xxl)
                    
                    if viewModel.isLoading && viewModel.nowShowing.isEmpty {
                        ProgressView().padding(.horizontal)
                    } else if !viewModel.nowShowing.isEmpty {
                        // Listă Orizontală de filme
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: Spacing.lg) {
                                ForEach(viewModel.nowShowing, id: \.id) { movie in
                                    NowShowingCard(movie: movie) { path.append(movie) }
                                }
                            }
                            .padding(.leading, Spacing.xxl)
                        }
                    } else if let error = viewModel.error {
                        Text("Eroare la încărcare: \(error)").padding(.horizontal)
                    }
                }
                
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    SectionHeader("Popular")
                    
                    if viewModel.isLoading && viewModel.popular.isEmpty {
                        ProgressView().padding(.horizontal)
                    } else if !viewModel.popular.isEmpty {
                        VStack(spacing: Spacing.lg) {
                            ForEach(viewModel.popular, id: \.id) { movie in
                                PopularCard(movie: movie) { path.append(movie) }
                            }
                        }
                    }
                }
                .padding(.horizontal, Spacing.xxl)
            }
            .padding(.top, Spacing.lg)
        }
        .onAppear {
            viewModel.load()
        }
        .background(Color(.systemBackground))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            
            // MARK: - Titlul Personalizat (Înlocuiește .navigationTitle)
            ToolbarItem(placement: .principal) {
                Text("FilmKu")
                    .font(.custom("Merriweather UltraBold", size: Spacing.lg))
                    .foregroundColor(Color.brand)
            }
            
            // MARK: - Iconițe pe Stânga (Leading)
            ToolbarItem(placement: .topBarLeading) {
                // Grupăm în HStack pentru controlul spațierii și a două iconițe
                HStack(spacing: Spacing.lg) {
                    Image("Union") // Meniu
                }
            }
            
            // MARK: - Iconițe pe Dreapta (Trailing)
            ToolbarItem(placement: .topBarTrailing) {
                // Grupăm în HStack pentru controlul spațierii și a două iconițe
                HStack(spacing: Spacing.lg) {
                    Image("Notif") // Notificări
                }
            }
        }
    }
}
