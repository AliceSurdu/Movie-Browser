//
//  Components.swift
//  Movie Browser
//
//  Created by Alice Surdu on 18.10.2025.
//

import SwiftUI

struct GenreTag: View {
    let text: String
    
    var body: some View {
        Text(text.uppercased())
            .font(.custom("Mulish-Regular", size: Spacing.sm))
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.xs)
            .background(Color.chipBG)
            .foregroundColor(Color.chipText)
            .cornerRadius(100)
    }
}

struct SectionHeader: View {
    let title: String
    var isButtonVisible: Bool
    
    init(_ title: String, isButtonVisible: Bool = true) {
        self.title = title
        self.isButtonVisible = isButtonVisible
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(.custom("Merriweather UltraBold", size: Spacing.lg))
                .foregroundColor(Color.brand)
            
            Spacer()
            if isButtonVisible {
                Button("See more") {}
                    .font(.custom("Mulish-Regular", size: 10))
                    .foregroundColor(Color.textSecondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, Spacing.sm)
                    .background(
                        Capsule()
                            .fill(Color.white)
                    )
                    .overlay(
                        Capsule()
                            .stroke(Color("TextSecondary"), lineWidth: 1)
                    )
                    .buttonStyle(.plain)
            }
        }
    }
}
