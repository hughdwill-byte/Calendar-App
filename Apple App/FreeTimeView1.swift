//
//  FreeTimeView1.swift
//  Calendar App
//
//  Created by Minh Thu Nguyen on 14/7/2026.
//

import SwiftUI

struct FreeTimeView1: View {
    var dayEntries: [DayPlan]

    @State private var expandedDayID: UUID? = nil
        
        var body: some View {
            VStack(spacing: 8) {
                ForEach(dayEntries, id: \.id) { dayPlan in
                    ExpandableView(dayPlan: dayPlan, expandedDayID: $expandedDayID)
                }
            }
            .padding(.vertical, 8)
        }
}

#Preview {
    FreeTimeView1(dayEntries: sampleDays)
}
