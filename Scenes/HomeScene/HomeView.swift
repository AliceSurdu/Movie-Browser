import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel
    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            Color("Background").ignoresSafeArea()
            
            if viewModel.isLoading {
                loadingState
            } else if !viewModel.nowShowing.isEmpty || !viewModel.popular.isEmpty {
                contentState
            } else {
                emptyState
            }
        }
        .onAppear {
            if viewModel.nowShowing.isEmpty { viewModel.load() }
        }
    }
    
    // MARK: - States
    
    private var loadingState: some View {
        ScrollView {
            VStack(spacing: 24) {
                topBar
                
                Text("Now Showing")
                    .font(Fonts.h1)
                    .foregroundColor(Color("Brand"))
                
                HStack(spacing: 16) {
                    skeletonCard
                    skeletonCard
                }
                
                Text("Popular")
                    .font(Fonts.h1)
                    .foregroundColor(Color("Brand"))
                
                VStack(spacing: 16) {
                    skeletonRow
                    skeletonRow
                }
                .padding(.bottom, 80)
            }
            .padding(.top, 16)
            .padding(.horizontal, 24)
        }
    }
    
    private var contentState: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // Now Showing
                VStack(spacing: 16) {
                    topBar
                    SectionHeader("Now Showing")
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(viewModel.nowShowing) { m in
                                NavigationLink(value: m) { posterCard(m) }
                                    .buttonStyle(.plain)
                            }
                        }
                    }
                }
                
                // Popular
                VStack(spacing: 16) {
                    SectionHeader("Popular")
                    ForEach(viewModel.popular) { m in
                        NavigationLink(value: m) { popularRow(m) }
                            .buttonStyle(.plain)
                    }
                }
                .padding(.bottom, 80)
            }
            .padding(.leading, 24) // 👈 singurul padding orizontal global
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 32) {
            topBar
            Spacer()
            Text("No movies available")
                .font(Fonts.h2)
                .foregroundColor(Color("TextPrimary"))
            Spacer()
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Components
    
    private var topBar: some View {
        HStack {
            Image(systemName: "line.3.horizontal")
            
            Spacer()
            
            Text("FilmKu")
                .font(Fonts.h1)
                .foregroundColor(Color("Brand"))
            
            Spacer()
            
            ZStack(alignment: .topTrailing) {
                Image(systemName: "bell")
                Circle()
                    .fill(.red)
                    .frame(width: 8, height: 8)
                    .offset(x: 4, y: -4)
            }
        }
    }
    
    private var skeletonCard: some View {
        RoundedRectangle(cornerRadius: 14)
            .fill(.gray.opacity(0.15))
            .frame(width: 180, height: 260)
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    private var skeletonRow: some View {
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 12)
                .fill(.gray.opacity(0.15))
                .frame(width: 84, height: 120)
            
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 4).fill(.gray.opacity(0.15)).frame(width: 220, height: 16)
                RoundedRectangle(cornerRadius: 4).fill(.gray.opacity(0.15)).frame(width: 180, height: 14)
                RoundedRectangle(cornerRadius: 4).fill(.gray.opacity(0.15)).frame(width: 120, height: 14)
            }
            
            Spacer()
        }
    }
    
    private func posterCard(_ m: Movie) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 12) {
                AsyncImage(url: m.posterURL) { img in
                    img.resizable().scaledToFill()
                } placeholder: {
                    Rectangle().fill(Color("Brand").opacity(0.15))
                }
                .frame(width: 180, height: 260)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                
                Text(m.title)
                    .font(Fonts.h2)
                    .foregroundColor(Color("TextPrimary"))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            
            HStack() {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
                    .font(.system(size: 12))
                Text(scoreText(m))
                    .font(Fonts.sub)
                    .foregroundColor(Color("TextPrimary"))
            }
        }
    }
    
    private func popularRow(_ m: Movie) -> some View {
        HStack(spacing: 16) {
            AsyncImage(url: m.posterURL) { $0.resizable().scaledToFill() } placeholder: {
                Rectangle().fill(Color("Brand").opacity(0.15))
            }
            .frame(width: 84, height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(m.title)
                    .font(Fonts.h2)
                    .foregroundColor(Color("TextPrimary"))
                    .lineLimit(2)
                
                HStack(alignment: .center) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                        .font(.system(size: 12))
                    Text(scoreText(m) + " IMDb")
                        .font(Fonts.sub)
                        .foregroundColor(Color("TextPrimary"))
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(m.genres.prefix(3), id: \.self) { Chip(text: $0) }
                    }
                    .scrollClipDisabled() // 🟢 evită „tăierea” ultimului chip
                }
                
                HStack() {
                    Image(systemName: "clock")
                        .font(.system(size: 12))
                        .foregroundStyle(Color("TextPrimary"))
                    Text(durationText(m.duration))
                        .font(Fonts.sub)
                        .foregroundColor(Color("TextPrimary"))
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private func scoreText(_ m: Movie) -> String {
        guard let s = m.score else { return "–/10" }
        return String(format: "%.1f/10", s)
    }
    
    private func durationText(_ d: Int?) -> String {
        guard let d else { return "—" }
        return "\(d / 60)h \(d % 60)m"
    }
}
