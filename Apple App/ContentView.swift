//
//  ContentView.swift
//  Apple App
//
//  Calendar screen — built from the Figma "3. App Flow" export.
//

import SwiftUI

// MARK: - Model

struct EventSegment: Identifiable {
    let id = UUID()
    let width: CGFloat
    let color: Color
}

struct FreeSlot: Identifiable {
    let id = UUID()
    let start: String
    let end: String
}

struct DayModel: Identifiable {
    let id = UUID()
    let weekday: String
    let date: String
    let isToday: Bool
    let segments: [EventSegment]
    let freeSlots: [FreeSlot]
}

// MARK: - Palette (from Figma variables)

private extension Color {
    static let segCyan   = Color(red: 0.00, green: 0.753, blue: 0.910) // #00C0E8
    static let segIndigo = Color(red: 0.380, green: 0.333, blue: 0.961) // #6155F5
    static let segOrange = Color(red: 1.00, green: 0.553, blue: 0.157)  // #FF8D28
    static let segGray12 = Color(red: 118/255, green: 118/255, blue: 128/255).opacity(0.12)
    static let segGray16 = Color(red: 120/255, green: 120/255, blue: 128/255).opacity(0.16)
    static let shareBlue = Color(red: 0.00, green: 0.533, blue: 1.00)   // #08F
    static let fillTertiary = Color(red: 118/255, green: 118/255, blue: 128/255).opacity(0.12)
}

// Sample busy-density bars + free windows, cycled across the week.
// ponytail: placeholder data — swap for the user's real calendar/availability source.
private func segmentPatterns() -> [[EventSegment]] {
    [
        [.init(width: 48, color: .segGray12), .init(width: 32, color: .segGray16),
         .init(width: 16, color: .segCyan), .init(width: 32, color: .segGray12),
         .init(width: 16, color: .segCyan)],
        [.init(width: 32, color: .segGray16), .init(width: 16, color: .segOrange),
         .init(width: 32, color: .segGray16), .init(width: 16, color: .segIndigo),
         .init(width: 48, color: .segGray12)],
        [.init(width: 24, color: .segGray12), .init(width: 24, color: .segIndigo),
         .init(width: 40, color: .segGray16), .init(width: 24, color: .segCyan),
         .init(width: 32, color: .segGray12)],
    ]
}

private func freePatterns() -> [[FreeSlot]] {
    [
        [.init(start: "9:30 AM", end: "11:30 AM"), .init(start: "4:00 PM", end: "9:30 PM")],
        [.init(start: "12:30 PM", end: "4:00 PM"), .init(start: "8:00 PM", end: "11:00 PM")],
        [.init(start: "8:00 AM", end: "10:00 AM"), .init(start: "1:00 PM", end: "6:00 PM")],
    ]
}

private func currentWeek() -> [DayModel] {
    let cal = Calendar.current
    guard let week = cal.dateInterval(of: .weekOfYear, for: Date()) else { return [] }
    let fmt = DateFormatter(); fmt.dateFormat = "EEEE"
    let segs = segmentPatterns(), free = freePatterns()
    return (0..<7).compactMap { offset in
        guard let date = cal.date(byAdding: .day, value: offset, to: week.start) else { return nil }
        let day = cal.component(.day, from: date)
        return DayModel(
            weekday: fmt.string(from: date).uppercased(),
            date: "\(day)\(ordinalSuffix(day))",
            isToday: cal.isDateInToday(date),
            segments: segs[offset % segs.count],
            freeSlots: free[offset % free.count])
    }
}

private func ordinalSuffix(_ n: Int) -> String {
    if (11...13).contains(n % 100) { return "th" }
    switch n % 10 { case 1: return "st"; case 2: return "nd"; case 3: return "rd"; default: return "th" }
}

// MARK: - Root

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") { PlaceholderScreen(title: "Home") }
            Tab("Calendar", systemImage: "calendar") { CalendarScreen() }
        }
    }
}

private struct PlaceholderScreen: View {
    let title: String
    var body: some View {
        ContentUnavailableView(title, systemImage: "square.dashed")
    }
}

// MARK: - Calendar screen

private struct CalendarScreen: View {
    @State private var period: Period = .weekly
    @State private var days: [DayModel] = currentWeek()
    enum Period { case weekly, monthly }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                periodToggle
                ForEach(days) { DayCard(day: $0) }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .background(Color(.systemBackground))
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Calendar")
                    .font(.system(size: 34, weight: .bold))
                Text("Updated Just Now")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            HStack(spacing: 16) {
                GlassCircleButton(symbol: "gear") {}
            }
        }
        .padding(.top, 8)
    }

    private var periodToggle: some View {
        HStack(spacing: 16) {
            PeriodButton(title: "Weekly", selected: period == .weekly) { period = .weekly }
            PeriodButton(title: "Monthly", selected: period == .monthly) { period = .monthly }
        }
    }
}

// MARK: - Components

private struct PeriodButton: View {
    let title: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .frame(maxWidth: .infinity)
                .frame(height: 33)
                .foregroundStyle(selected ? .white : Color.accentColor)
                .background(selected ? Color.accentColor : Color(.systemGray6),
                            in: .capsule)
        }
        .buttonStyle(.plain)
    }
}

private struct GlassCircleButton: View {
    let symbol: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(.primary)
                .frame(width: 48, height: 48)
        }
        .buttonStyle(.plain)
        .glassEffect(.regular, in: .circle)
    }
}

private struct EventBar: View {
    let segments: [EventSegment]
    var body: some View {
        HStack(spacing: 2) {
            ForEach(segments) { seg in
                Capsule().fill(seg.color).frame(width: seg.width, height: 16)
            }
        }
    }
}

private struct DayCard: View {
    let day: DayModel
    @State private var expanded: Bool

    init(day: DayModel) {
        self.day = day
        _expanded = State(initialValue: day.isToday)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(day.weekday)
                        .font(.system(size: 15))
                        .foregroundStyle(day.isToday ? Color.accentColor : .primary)
                    Text(day.date).font(.system(size: 34, weight: .bold))
                }
                Spacer()
                EventBar(segments: day.segments)
                Button { withAnimation(.snappy) { expanded.toggle() } } label: {
                    Image(systemName: expanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(.primary)
                        .frame(width: 48, height: 48)
                }
                .buttonStyle(.plain)
                .glassEffect(.regular, in: .circle)
            }

            if expanded {
                Text("Free time")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.secondary)
                if day.freeSlots.isEmpty {
                    Text("No free time this day.")
                        .font(.system(size: 17))
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(day.freeSlots) { slot in
                        HStack(alignment: .bottom) {
                            FreeSlotTable(slot: slot).frame(width: 223)
                            Spacer()
                            ShareButton {}
                        }
                    }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular, in: .rect(cornerRadius: 34))
    }
}

private struct FreeSlotTable: View {
    let slot: FreeSlot
    var body: some View {
        VStack(spacing: 0) {
            row(title: "Free from", time: slot.start)
            Divider().padding(.leading, 16)
            row(title: "Until", time: slot.end)
        }
        .background(Color(.systemBackground), in: .rect(cornerRadius: 26))
    }

    private func row(title: String, time: String) -> some View {
        HStack {
            Text(title).font(.system(size: 17))
            Spacer()
            Text(time)
                .font(.system(size: 17))
                .padding(.vertical, 6).padding(.horizontal, 11)
                .background(Color.fillTertiary, in: .capsule)
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
    }
}

private struct ShareButton: View {
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Label("Share", systemImage: "square.and.arrow.up")
                .font(.system(size: 15))
                .foregroundStyle(.white)
                .padding(.vertical, 4).padding(.horizontal, 12)
                .frame(height: 32)
                .background(Color.shareBlue, in: .capsule)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ContentView()
}
