//
//  Fonts.swift
//  Movie Browser
//
//  Created by Alice Surdu on 18.10.2025.
//

import SwiftUI
enum Fonts {
    static let h1 = Font.custom("Merriweather-Bold", size: Spacing.lg)
    static let h2 = Font.system(size: Spacing.xl, weight: .semibold)
    static let body = Font.system(size: Spacing.lg, weight: .regular)
    static let sub  = Font.system(size: Spacing.mdPlus, weight: .regular)
    static let cap  = Font.system(size: Spacing.md, weight: .medium)
}
