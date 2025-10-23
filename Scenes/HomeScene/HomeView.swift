import SwiftUI

// MARK: - Componente Auxiliare

/// 1. Tag pentru Gen (reutilizat din MovieDetailView)
struct HomeGenreTag: View {
    let text: String
    
    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 10, weight: .medium))
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(Color(.systemGray5)) // Fundal gri deschis
            .foregroundColor(.secondary)
            .cornerRadius(6)
    }
}

/// 2. Card pentru secțiunea "Now Showing" (Orizontal)
struct NowShowingCard: View {
    let movie: Movie
    // Closure pentru a gestiona acțiunea de navigare
    var onTap: () -> Void
    
    // Înălțimea și lățimea fixă pentru card
    private let cardWidth: CGFloat = 140
    private let cardHeight: CGFloat = 212 // NOU: Înălțime fixă solicitată
    private let cardRadius: CGFloat = 5 // NOU: Radius fix solicitat
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
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
            .shadow(color: .black.opacity(0.08), radius: 6, y: 4) // Foarte important: taie imaginea la colțuri și dimensiune
            
            // Titlu
            Text(movie.title)
                .font(.headline)
                .lineLimit(2)
                .truncationMode(.tail)
            
            // Rating IMDb
            if let score = movie.score {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    Text("\(score, specifier: "%.1f")/10 IMDb")
                        .font(.caption)
                        .foregroundColor(.secondary)
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
        HStack(alignment: .top, spacing: 15) {
            // Poster
            AsyncImage(url: movie.posterURL) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Color.gray.opacity(0.2)
                }
            }
            .frame(width: 80, height: 120) // Dimensiuni mici, orientare portret
            .cornerRadius(8)
            .clipped()
            
            VStack(alignment: .leading, spacing: 5) {
                // Titlu
                Text(movie.title)
                    .font(.headline)
                    .lineLimit(2)
                
                // Rating IMDb
                if let score = movie.score {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.subheadline)
                        Text("\(score, specifier: "%.1f")/10 IMDb")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Genuri
                HStack {
                    ForEach(movie.genres.prefix(3), id: \.self) { genre in
                        HomeGenreTag(text: genre)
                    }
                }
                
                // Durată
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(formattedDuration(minutes: movie.duration))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 5)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onTapGesture(perform: onTap) // Acțiunea de navigare la tap
    }
}


// MARK: - View Principală

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel
    // Variabilă de mediu pentru a obține referința la stiva de navigare
    @Binding var path: [Movie]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                
                // 1. Navbar/Titlu (Imită structura din design)
                HStack {
                    Image(systemName: "line.horizontal.3")
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("FilmKu")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Image(systemName: "bell.fill")
                        .foregroundColor(.primary)
                }
                .padding(.horizontal)
                
                // 2. Secțiunea "Now Showing"
                VStack(alignment: .leading, spacing: 15) {
                    SectionHeader("Now Showing")
                        .padding(.horizontal)
                    
                    if viewModel.isLoading && viewModel.nowShowing.isEmpty {
                        ProgressView().padding(.horizontal)
                    } else if !viewModel.nowShowing.isEmpty {
                        // Listă Orizontală de filme
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(viewModel.nowShowing, id: \.id) { movie in
                                    NowShowingCard(movie: movie) {
                                        // Navigare: adaugă obiectul Movie în path (stiva)
                                        // Aceasta va declanșa .navigationDestination din AppRouter
                                        path.append(movie)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    } else if let error = viewModel.error {
                        Text("Eroare la încărcare: \(error)").padding(.horizontal)
                    }
                }
                
                // 3. Secțiunea "Popular"
                VStack(alignment: .leading, spacing: 15) {
                    SectionHeader("Popular")
                        .padding(.horizontal)
                    
                    if viewModel.isLoading && viewModel.popular.isEmpty {
                        ProgressView().padding(.horizontal)
                    } else if !viewModel.popular.isEmpty {
                        // Listă Verticală de filme
                        VStack(spacing: 15) {
                            ForEach(viewModel.popular, id: \.id) { movie in
                                PopularCard(movie: movie) {
                                    // Navigare: adaugă obiectul Movie în path
                                    path.append(movie)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.top, 10)
            .padding(.bottom, 80) // Spațiu pentru Tab Bar
        }
        .onAppear {
            viewModel.load() // Inițializează încărcarea datelor
        }
        .background(Color(.systemBackground))
        .navigationBarHidden(true) // Ascundem NavigationBar implicit
    }
}
