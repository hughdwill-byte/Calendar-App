//
//  OverviewTitleView.swift
//  Calendar App
//
//  Created by Minh Thu Nguyen on 14/7/2026.
//


import SwiftUI

struct OverviewTitleView: View {
    var title: String
    var subtitle: String
    var body: some View {
        VStack {
            Text(title)
                .font(.system(size: 36, weight: .bold))
                                
            Text(subtitle)
                .multilineTextAlignment(.center)
        }

    }
}

#Preview {
    OverviewTitleView(title: "Overview", subtitle: "This is a description")
}
