//
//  DayPlanHorizontalView.swift
//  Calendar App
//
//  Created by Minh Thu Nguyen on 14/7/2026.
//
import SwiftUI

struct DayPlanHorizontalView: View {
    
    var dayPlan: DayPlan
    var chevronButton: String = "chevron.down"
    var today: Color = .black
    @AppStorage("freeTimeMinLengthMinutes") private var freeTimeMinLengthMinutes: Int = 30
    
    var body: some View {
        
        HStack {
            VStack(spacing: 2) {
                Text(dayPlan.date.formatted(.dateTime.day()))
                    .font(.system(size: 30))
                    .bold()
                    .foregroundStyle(today)
                Text(dayPlan.date.formatted(.dateTime.weekday(.abbreviated)))
                    .font(.system(size: 16))
                    .foregroundStyle(today)
            }
            .frame(width: 60)
            // timeline visualization :)
            GeometryReader { geometry in
                
                ZStack(alignment: .leading) {
                    // background bar ~~
                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: geometry.size.width, height: 20)
                    
                    // free segments !!!
                    ForEach(visibleEvents, id: \.self) { event in
                        let duration = Double(event.endHour - event.startHour) / 24
                        let startOffset = Double(event.startHour) / 24
                        let segmentWidth = geometry.size.width * duration
                        let xOffset = geometry.size.width * startOffset
                        
                        Capsule()
                            .fill(Color.color1)
                            .frame(width: segmentWidth, height: 20)
                        //change the divisor if needed
                            .offset(x: xOffset)
                        //remember to subtract if needed
                    }
                }
            }
            .frame(height: 20)
            Image(systemName: chevronButton)

        }
    }

    private var visibleEvents: [TimeBlock] {
        dayPlan.events.filter { event in
            (event.endHour - event.startHour) * 60 >= freeTimeMinLengthMinutes
        }
    }
}

#Preview {
    VStack {
        DayPlanHorizontalView(dayPlan: sampleDays[0])
        DayPlanHorizontalView(dayPlan: sampleDays[1])
        DayPlanHorizontalView(dayPlan: sampleDays[2])
    }
}
