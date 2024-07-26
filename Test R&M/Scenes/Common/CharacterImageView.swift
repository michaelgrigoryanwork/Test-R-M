//
//  CharacterImageView.swift
//  Test R&M
//
//  Created by Michael Grigoryan on 24.07.24.
//

import SwiftUI

struct CharacterImageView: View {
    private let url: URL?
    private let size: CGFloat
    private let cornerRadius: CGFloat
    private let lineWidth: CGFloat
    
    init(url: URL?, size: CGFloat, cornerRadius: CGFloat = 16, lineWidth: CGFloat = 2) {
        self.url = url
        self.size = size
        self.cornerRadius = cornerRadius
        self.lineWidth = lineWidth
    }
    
    var body: some View {
        CachedAsyncImage(url: url) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size, height: size)
                .clipped()
        } placeholder: {
            Text("🛸")
                .font(.largeTitle)
        }
        .frame(width: size, height: size)
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(.primary, lineWidth: lineWidth)
        )
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

#Preview {
    CharacterImageView(url: .init(string: "https://m.media-amazon.com/images/M/MV5BZjRjOTFkOTktZWUzMi00YzMyLThkMmYtMjEwNmQyNzliYTNmXkEyXkFqcGdeQXVyNzQ1ODk3MTQ@._V1_FMjpg_UX1000_.jpg"), size: 96)
}
