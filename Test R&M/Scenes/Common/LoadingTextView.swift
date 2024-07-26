//
//  LoadingTextView.swift
//  Test R&M
//
//  Created by Michael Grigoryan on 24.07.24.
//

import SwiftUI

struct LoadingTextView: View {
    private let title: String
    
    init(title: String) {
        self.title = title
    }
    
    var body: some View {
        HStack(alignment: .center) {
            Spacer()
            
            Text(title)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(16)
            
            Spacer()
        }
    }
}

#Preview {
    LoadingTextView(title: "")
}
