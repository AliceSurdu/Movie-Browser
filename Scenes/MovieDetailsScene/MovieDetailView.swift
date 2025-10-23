//
//  MovieDetailView.swift
//  Movie Browser
//
//  Created by Alice Surdu on 18.10.2025.
//

import SwiftUI

struct MovieDetailView: View {
  let movie: Movie
  @StateObject private var vm: MovieDetailViewModel

  init(movie: Movie, api: MovieAPIServiceType) {
    self.movie = movie
    _vm = StateObject(wrappedValue: MovieDetailViewModel(id: movie.id, api: api))
  }

    var body: some View {
      ZStack {
        Color("Background").ignoresSafeArea()
        ScrollView {
          VStack(spacing: 0) {

            ZStack {
              AsyncImage(url: movie.bannerURL ?? movie.posterURL) { $0.resizable().scaledToFill() } placeholder: {
                Rectangle().fill(.gray.opacity(0.2))
              }
              .frame(height: 280)
              .clipped()

              VStack {
                Spacer()
                HStack {
                  Spacer()
                  Circle()
                    .fill(.white.opacity(0.9))
                    .frame(width: 60, height: 60)
                    .overlay(
                      Image(systemName: "play.fill")
                        .foregroundStyle(.black)
                        .font(.system(size: 20))
                    )
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                  Spacer()
                }
                .padding(.bottom, 40)
              }

              VStack {
                HStack {
                  Spacer()
                  Button(action: {}) {
                    Image(systemName: "ellipsis")
                      .foregroundStyle(.white)
                      .font(.system(size: 18, weight: .medium))
                      .padding(12)
                      .background(.black.opacity(0.3))
                      .clipShape(Circle())
                  }
                  .padding(.trailing, 16)
                  .padding(.top, 16)
                }
                Spacer()
              }
            }

            VStack(alignment: .leading, spacing: Spacing.lg) {
              HStack {
                Text(movie.title)
                  .font(.system(size: 24, weight: .semibold))
                  .foregroundStyle(Color("TextPrimary"))
                Spacer()
                Button(action: {}) {
                  Image(systemName: "bookmark")
                    .foregroundStyle(Color("TextPrimary"))
                    .font(.system(size: 20))
                }
              }

              HStack(spacing: 6) {
                Image(systemName: "star.fill")
                  .foregroundStyle(.yellow)
                  .font(.system(size: 14))
                Text(scoreText(movie) + " IMDb")
                  .font(Fonts.sub)
                  .foregroundStyle(Color("TextPrimary"))
              }

              ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                  ForEach(movie.genres.prefix(3), id: \.self) { Chip(text: $0) }
                }
              }

              HStack(spacing: Spacing.xl) {
                VStack(alignment: .leading, spacing: 4) {
                  Text("Length")
                    .font(Fonts.cap)
                    .foregroundStyle(Color("TextPrimary"))
                  Text(durationText(movie.duration))
                    .font(Fonts.body)
                    .foregroundStyle(Color("TextPrimary"))
                }
                VStack(alignment: .leading, spacing: 4) {
                  Text("Language")
                    .font(Fonts.cap)
                    .foregroundStyle(Color("TextPrimary"))
                  Text(vm.detail?.country ?? "—")
                    .font(Fonts.body)
                    .foregroundStyle(Color("TextPrimary"))
                }
                VStack(alignment: .leading, spacing: 4) {
                  Text("Rating")
                    .font(Fonts.cap)
                    .foregroundStyle(Color("TextPrimary"))
                  Text(vm.detail?.status ?? "—")
                    .font(Fonts.body)
                    .foregroundStyle(Color("TextPrimary"))
                }
              }

              Text("Description")
                .font(Fonts.h1)
                .foregroundStyle(Color("Brand"))
              Text(vm.detail?.synopsis ?? "—")
                .font(Fonts.body)
                .foregroundStyle(Color("TextPrimary"))
                .lineSpacing(4)

              HStack {
                Text("Cast")
                  .font(Fonts.h1)
                  .foregroundStyle(Color("Brand"))
                Spacer()
                Button("See more", action: {})
                  .font(Fonts.cap)
                  .padding(.horizontal, Spacing.md)
                  .padding(.vertical, 8)
                  .background(.white)
                  .clipShape(Capsule())
                  .overlay(Capsule().stroke(.black.opacity(0.08)))
              }

              ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.md) {
                  ForEach(vm.detail?.cast ?? [], id: \.id) { p in
                    VStack(alignment: .leading, spacing: 6) {
                      AsyncImage(url: p.imageURL) { $0.resizable().scaledToFill() } placeholder: {
                        Rectangle().fill(.gray.opacity(0.15))
                      }
                      .frame(width: 84, height: 84)
                      .clipShape(RoundedRectangle(cornerRadius: 12))
                      .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)

                      Text(p.name)
                        .font(Fonts.sub)
                        .lineLimit(1)
                        .foregroundStyle(Color("TextPrimary"))
                    }
                    .frame(width: 84)
                  }
                }
              }
            }
            .padding(Spacing.lg)
            .background(
              RoundedRectangle(cornerRadius: 24)
                .fill(.white)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: -5)
            )
            .padding(.horizontal, Spacing.lg)
            .offset(y: -40)
            .padding(.bottom, 60)
          }
        }

        if vm.isLoading {
          ProgressView()
            .controlSize(.large)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.black.opacity(0.3))
        }
      }
      .onAppear { if vm.detail == nil { vm.load() } }
      .navigationTitle("Detail Movie")
      .navigationBarTitleDisplayMode(.inline)
      .toolbarBackground(.clear, for: .navigationBar)
      .toolbarColorScheme(.light, for: .navigationBar)
    }

  private func scoreText(_ m: Movie) -> String {
    guard let s = m.score else { return "—/10" }
    return String(format: "%.1f/10", s)
  }
    
  private func durationText(_ d: Int?) -> String {
    guard let d else { return "—" }
    let h = d / 60
    let m = d % 60
    return "\(h)h \(m)m"
  }
}
