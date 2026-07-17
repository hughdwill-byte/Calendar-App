//
//  ExpandableView.swift
//  Calendar App
//
//  Created by Minh Thu Nguyen on 14/7/2026.
//

import SwiftUI

struct ExpandableView: View {
//    @State private var isExpanded: Bool = true
//    
//    var dayPlan: DayPlan
//    
//    var body: some View {
//        VStack {
//            if isExpanded {
//                FreeTimeCardDetails(
//                    timeBlock: TimeBlock(
//                        startHour: dayPlan.events.first?.startHour ?? 12,
//                        endHour: dayPlan.events.first?.endHour ?? 13
//                    ),
//                    date: dayPlan.date
//                )
//            } else {
//                DayPlanHorizontalView(dayPlan: dayPlan)
//                    .padding(.horizontal, 30)
//            }
//        }
//        .onTapGesture {
//            isExpanded.toggle()
//        }
////        .border(.green)
//    }
    var dayPlan: DayPlan
        @Binding var expandedDayID: UUID?
        
        var isExpanded: Bool {
            expandedDayID == dayPlan.id
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                // Header - always visible
                DayPlanHorizontalView(
                    dayPlan: dayPlan,
                    chevronButton: isExpanded ? "chevron.up" : "chevron.down",
                    today: Calendar.current.isDateInToday(dayPlan.date) ? .color1 : .black
                )
                    .padding(.horizontal, isExpanded ? 30 : 30)
                    .padding(.vertical, 12)
                    .contentShape(Rectangle())
                    .onTapGesture {
                         withAnimation(.easeInOut(duration: 0.3)) {
                            if expandedDayID == dayPlan.id {
                                expandedDayID = nil
                            } else {
                                expandedDayID = dayPlan.id
                            }
                        }
                    }
                
                // Expanded content - slides down when expanded
                if isExpanded {
                    HStack(alignment: .top, spacing: 0) {
                        // Spacer to align with the date column (60pt width + spacing)
                        Spacer()
                            .frame(width: 15)
                        
                        VStack(alignment: .leading, spacing: 15) {
                            Text(dayPlan.dynamicCardMessage)
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            // Show all time blocks for this day
                            ForEach(dayPlan.events, id: \.self) { block in
                                if block.startHour != block.endHour {
                                    FTCapsule(
                                        timeBlock: block,
                                        dayPlan: dayPlan,
                                        dynamicCardMessage: dayPlan.dynamicCardMessage
                                    )
                                }
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 15)
                    .transition(.scale(scale: 0.95, anchor: .top).combined(with: .opacity))
                }
            }
            .background(isExpanded ? Color(.systemGray6) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: isExpanded ? 16 : 0))
            .padding(.horizontal, 15)
        }
}

#Preview {
//    VStack {
//        ExpandableView(dayPlan: sampleDays[0])
//        ExpandableView(dayPlan: sampleDays[1])
//        ExpandableView(dayPlan: sampleDays[2])
//    }
    PreviewWrapper()
    }

    struct PreviewWrapper: View {
        @State private var expandedDayID: UUID? = nil
        
        var body: some View {
            VStack {
                ExpandableView(dayPlan: sampleDays[0], expandedDayID: $expandedDayID)
                ExpandableView(dayPlan: sampleDays[1], expandedDayID: $expandedDayID)
                ExpandableView(dayPlan: sampleDays[2], expandedDayID: $expandedDayID)
            }
        }
    }
