//
//  ContentView.swift
//  Apple App
//
//  Calendar screen — built from the Figma "3. App Flow" export.
//

import SwiftUI
import EventKit

// MARK: - Model

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
    let slots: [Bool]          // 6 time blocks across the day; true = free
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
    static let freeGreen = Color(red: 0.204, green: 0.780, blue: 0.349) // systemGreen — free time
}

// Shared UserDefaults keys for settings that CalendarStore and SettingsView both read.
enum SettingsKey {
    static let windowStartHour = "windowStartHour"
    static let blockCount = "blockCount"
    static let blockHours = "blockHours"
}

// Reads the user's real calendar and derives the weekly schedule,
// 6-slot availability bar, and free-time windows from it.
@MainActor @Observable
final class CalendarStore {
    var days: [DayModel] = []
    var status: Status = .loading
    enum Status { case loading, ready, denied }

    // Waking window split into blocks — read live from UserDefaults so
    // SettingsView edits take effect on the next load.
    private var windowStartHour: Int {
        UserDefaults.standard.object(forKey: SettingsKey.windowStartHour) as? Int ?? 8
    }
    private var blockCount: Int {
        UserDefaults.standard.object(forKey: SettingsKey.blockCount) as? Int ?? 6
    }
    private var blockHours: Int {
        UserDefaults.standard.object(forKey: SettingsKey.blockHours) as? Int ?? 2
    }

    private let store = EKEventStore()

    func load() async {
        do {
            let granted = try await store.requestFullAccessToEvents()
            guard granted else { status = .denied; return }
            days = buildWeek()
            status = .ready
        } catch {
            status = .denied
        }
    }

    private func buildWeek() -> [DayModel] {
        let cal = Calendar.current
        guard let week = cal.dateInterval(of: .weekOfYear, for: Date()) else { return [] }
        let weekdayFmt = DateFormatter(); weekdayFmt.dateFormat = "EEEE"
        let timeFmt = DateFormatter(); timeFmt.dateFormat = "h:mm a"
        let blockLength = Double(blockHours) * 3600

        return (0..<7).compactMap { offset in
            guard let date = cal.date(byAdding: .day, value: offset, to: week.start) else { return nil }
            let midnight = cal.startOfDay(for: date)
            guard let windowStart = cal.date(bySettingHour: windowStartHour, minute: 0, second: 0, of: midnight),
                  let dayEnd = cal.date(byAdding: .day, value: 1, to: midnight) else { return nil }

            let predicate = store.predicateForEvents(withStart: midnight, end: dayEnd, calendars: nil)
            let events = store.events(matching: predicate).filter { !$0.isAllDay }

            // A block is free unless an event overlaps it.
            let slots: [Bool] = (0..<blockCount).map { i in
                let bStart = windowStart.addingTimeInterval(Double(i) * blockLength)
                let bEnd = bStart.addingTimeInterval(blockLength)
                return !events.contains { $0.startDate < bEnd && $0.endDate > bStart }
            }

            return DayModel(
                weekday: weekdayFmt.string(from: date).uppercased(),
                date: "\(cal.component(.day, from: date))\(ordinalSuffix(cal.component(.day, from: date)))",
                isToday: cal.isDateInToday(date),
                slots: slots,
                freeSlots: freeWindows(from: slots, windowStart: windowStart,
                                       blockLength: blockLength, fmt: timeFmt))
        }
    }

    // Merge consecutive free blocks into labelled start/end windows.
    private func freeWindows(from slots: [Bool], windowStart: Date,
                             blockLength: Double, fmt: DateFormatter) -> [FreeSlot] {
        var out: [FreeSlot] = []
        var i = 0
        while i < slots.count {
            guard slots[i] else { i += 1; continue }
            var j = i
            while j < slots.count && slots[j] { j += 1 }
            let start = windowStart.addingTimeInterval(Double(i) * blockLength)
            let end = windowStart.addingTimeInterval(Double(j) * blockLength)
            out.append(FreeSlot(start: fmt.string(from: start), end: fmt.string(from: end)))
            i = j
        }
        return out
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
            Tab("Home", systemImage: "house") { HomeView() }
            Tab("Calendar", systemImage: "calendar") { CalendarScreen() }
        }
    }
}

// MARK: - Calendar screen

private struct CalendarScreen: View {
    @State private var period: Period = .weekly
    @State private var store = CalendarStore()
    @AppStorage(SettingsKey.windowStartHour) private var windowStartHour: Int = 8
    @AppStorage(SettingsKey.blockCount) private var blockCount: Int = 6
    @AppStorage(SettingsKey.blockHours) private var blockHours: Int = 2
    enum Period { case weekly, monthly }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header
                    periodToggle
                    switch store.status {
                    case .loading:
                        ProgressView().frame(maxWidth: .infinity).padding(.top, 40)
                    case .denied:
                        deniedNotice
                    case .ready:
                        ForEach(store.days) { DayCard(day: $0) }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .background(Color(.systemBackground))
        }
        .task { await store.load() }
        .onChange(of: windowStartHour) { Task { await store.load() } }
        .onChange(of: blockCount) { Task { await store.load() } }
        .onChange(of: blockHours) { Task { await store.load() } }
    }

    private var deniedNotice: some View {
        VStack(spacing: 12) {
            Text("Calendar access is off")
                .font(.system(size: 17, weight: .semibold))
            Text("Enable it in Settings › Privacy › Calendars to see your schedule and free time.")
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            if let url = URL(string: UIApplication.openSettingsURLString) {
                Link("Open Settings", destination: url)
                    .font(.system(size: 17, weight: .semibold))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
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
                NavigationLink {
                    SettingsView()
                } label: {
                    Image(systemName: "gear")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(.primary)
                        .frame(width: 48, height: 48)
                }
                .buttonStyle(.plain)
                .glassEffect(.regular, in: .circle)
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

// 6 slots in a row. Free = green, busy = grey. Consecutive same-state
// slots merge into a single capsule; a lone slot renders as a circle.
private struct AvailabilityBar: View {
    let slots: [Bool]
    private let cell: CGFloat = 16
    private let gap: CGFloat = 4

    // Collapse the slots into runs of (isFree, count).
    private var runs: [(free: Bool, count: Int)] {
        slots.reduce(into: []) { runs, free in
            if runs.last?.free == free { runs[runs.count - 1].count += 1 }
            else { runs.append((free, 1)) }
        }
    }

    var body: some View {
        HStack(spacing: gap) {
            ForEach(Array(runs.enumerated()), id: \.offset) { _, run in
                Capsule()
                    .fill(run.free ? Color.freeGreen : Color.segGray16)
                    .frame(width: CGFloat(run.count) * cell + CGFloat(run.count - 1) * gap,
                           height: cell)
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
                AvailabilityBar(slots: day.slots)
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
            row(title: "From", time: slot.start)
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
