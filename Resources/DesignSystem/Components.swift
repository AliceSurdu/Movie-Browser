//
//  Components.swift
//  Movie Browser
//
//  Created by Alice Surdu on 18.10.2025.
//

import SwiftUI

public struct Chip: View {
  let text: String
  public init(text: String) { self.text = text }
  public var body: some View {
    Text(text.uppercased())
      .font(Fonts.cap)
      .foregroundStyle(Color("TextPrimary"))
      .padding(.horizontal, 12)
      .padding(.vertical, 6)
      .background(Color("ChipBG").opacity(0.3))
      .clipShape(Capsule())
      .overlay(
        Capsule()
          .stroke(Color("ChipBG").opacity(0.2), lineWidth: 0.5)
      )
  }
}

public struct SectionHeader: View {
  let title: String
  let onMore: (() -> Void)?
    public init(_ t: String, onMore: (() -> Void)? = nil) { title = t; self.onMore = onMore }
    
  public var body: some View {
    HStack {
      Text(title).font(Fonts.h1).foregroundStyle(Color("Brand"))
      Spacer()
      if let onMore {
        Button("See more", action: onMore)
          .font(Fonts.cap)
          .padding(.horizontal, 12).padding(.vertical, 8)
          .background(.white)
          .clipShape(Capsule())
          .overlay(Capsule().stroke(.black.opacity(0.08)))
      }
    }
  }
}

