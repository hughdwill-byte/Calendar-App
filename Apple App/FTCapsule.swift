//
//  FTCapsule.swift
//  Calendar App
//
//  Created by Minh Thu Nguyen on 15/7/2026.
//

import SwiftUI

struct FTCapsule: View {
    
    let timeBlock: TimeBlock
    let dayPlan: DayPlan
    let dynamicCardMessage: String
    
    
    private var startHour: Int { timeBlock.startHour }
    private var endHour: Int { timeBlock.endHour }

    private var dayDescriptor: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(dayPlan.date) {
            return "today"
        } else if calendar.isDateInTomorrow(dayPlan.date) {
            return "tomorrow"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE d MMMM"
            return "on \(formatter.string(from: dayPlan.date))"
        }
    }

    var body: some View {
        HStack {
            HStack {
                Text("\(startHour):00 – \(endHour):00")
                Spacer()
                Text("\(endHour - startHour)h")
                    .padding(.horizontal, 15)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray6))
                    .clipShape(Capsule())
            }
            .padding()
            .background(Color.white)
            .clipShape(Capsule())
            
            ShareLink(
                item: "Hey! We are free \(dayDescriptor) from \(startHour):00 - \(endHour):00. Let's do something!"
            ) {
                Label("share", systemImage: "square.and.arrow.up")
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.glassProminent)
            .frame(height: 48)
            
        }
    }
}

#Preview {
    FTCapsule(
        timeBlock: TimeBlock(startHour: 11, endHour: 12),
        dayPlan: DayPlan(
            date: Date(),
            events: [TimeBlock(startHour: 11, endHour: 12)],
            dynamicCardMessage: "Sample message from DayPlan"
        ),
        dynamicCardMessage: "Sample message for preview"
    )
}
