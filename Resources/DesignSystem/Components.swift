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
            .font(.custom("Mulish-Regular", size: 8))
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(Color.chipBG) // Fundal gri deschis
            .foregroundColor(Color.chipText)
            .cornerRadius(100)
    }
}

struct SectionHeader: View {
    let title: String // Am schimbat în let title: String
    var isButtonVisible: Bool
    
    init(_ title: String, isButtonVisible: Bool = true) { // Constructor pentru ușurință
        self.title = title
        self.isButtonVisible = isButtonVisible
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(.custom("Merriweather UltraBold", size: 16))
                .foregroundColor(Color.brand)
            
            Spacer()
            if isButtonVisible {
                Button("See more") {}
                .font(.custom("Mulish-Regular", size: 10)) // <--- Setează fontul PRIMUL
                .foregroundColor(Color.textSecondary)
                
                // APLICĂ padding-ul, background-ul și overlay-ul de contur ca o singură unitate
                .padding(.horizontal, 10)  // Am crescut puțin padding-ul pentru un aspect mai bun
                .padding(.vertical, 8)
                .background(
                    Capsule() // <-- 1. Folosim forma Capsule
                        .fill(Color.white) // <-- Fundalul (poți folosi și .clear sau culoarea dorită)
                )
                // 2. Aplicăm conturul (bordura) folosind .overlay cu o altă formă Capsule
                .overlay(
                    Capsule()
                        .stroke(Color("TextSecondary"), lineWidth: 1) // <-- Conturul subțire
                )
                .buttonStyle(.plain) // Păstrează .buttonStyle(.plain)
            }
        }
    }
    
    struct CustomTabIcon: View {
        let systemName: String // Numele iconiței SF Symbol (pentru formă)
        let isSelected: Bool
        let size: CGFloat = 30
        
        var body: some View {
            // Iconița Rulou Film (Iconița de Home) este cea mai complexă ca design (contur + cerculețe)
            // Folosim o iconiță simplă de sistem pentru a demonstra logica de culoare
            Image(systemName: systemName)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .foregroundColor(isSelected ? .brand : .gray) // Conturul (culoarea primară)
                .padding(5) // Spațiu în interiorul fundalului
                .background(
                    Group {
                        if isSelected {
                            // Fundalul vizibil doar în starea 'selected'
                            Circle() // Am folosit Circle ca forma generică pentru a demonstra logica
                                .fill(Color.chipBG)
                        } else {
                            // Niciun fundal în starea 'not selected'
                            Color.clear
                        }
                    }
                )
        }
    }
}
