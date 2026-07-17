//
//  WillowSchedule.swift
//  Apple App
//
//  Turns real EventKit + group busy data into the [DayPlan] the Willow UI
//  renders. Free time = the gaps between everyone's busy events within waking
//  hours, hour-rounded to fit the timeline's integer-hour model.
//

import Foundation

enum FreeTime {
    static let wakeStart = 7   // don't surface free time before 07:00
    static let wakeEnd = 23    // …or after 23:00

    /// Free TimeBlocks for one day given busy intervals, within waking hours,
    /// conservatively hour-rounded and filtered by a minimum length.
    static func freeBlocks(busy: [BusyInterval], dayStart: Date, minMinutes: Int,
                           calendar: Calendar = .current) -> [TimeBlock] {
        guard let wStart = calendar.date(bySettingHour: wakeStart, minute: 0, second: 0, of: dayStart),
              let wEnd = calendar.date(bySettingHour: wakeEnd, minute: 0, second: 0, of: dayStart)
        else { return [] }

        // Clamp busy to the waking window and merge overlaps.
        let clamped = busy.compactMap { b -> BusyInterval? in
            let s = max(b.start, wStart), e = min(b.end, wEnd)
            return s < e ? BusyInterval(start: s, end: e) : nil
        }.sorted { $0.start < $1.start }

        var merged: [BusyInterval] = []
        for b in clamped {
            if let last = merged.last, b.start <= last.end {
                merged[merged.count - 1].end = max(last.end, b.end)
            } else { merged.append(b) }
        }

        var blocks: [TimeBlock] = []
        func addGap(_ gs: Date, _ ge: Date) {
            // Conservative: never claim a partial hour as free.
            let sh = Int(ceil(gs.timeIntervalSince(dayStart) / 3600))
            let eh = Int(floor(ge.timeIntervalSince(dayStart) / 3600))
            if eh > sh, (eh - sh) * 60 >= minMinutes {
                blocks.append(TimeBlock(startHour: sh, endHour: eh))
            }
        }
        var cursor = wStart
        for b in merged {
            if cursor < b.start { addGap(cursor, b.start) }
            cursor = max(cursor, b.end)
        }
        if cursor < wEnd { addGap(cursor, wEnd) }
        // ponytail: hour granularity to match the timeline model; move to minute
        // precision (and TimeBlock minutes) if half-hour windows start to matter.
        return blocks
    }
}

struct WillowWeek {
    var plans: [DayPlan]
    var title: String
    var subtitle: String
    var heroImage: String
    var heroDescription: String

    static let empty = WillowWeek(plans: [], title: "", subtitle: "",
                                  heroImage: "homeScreenImage", heroDescription: "")
}

enum ScheduleBuilder {
    /// Build a week of shared free time. `offset` 0/1/2 = this / +1 / +2 weeks.
    /// `group` nil (or empty) means "just you".
    static func week(offset: Int, group: Group?, calendar: CalendarStore, minMinutes: Int) -> WillowWeek {
        var cal = Calendar.current
        cal.firstWeekday = 2 // Monday
        let today = cal.startOfDay(for: Date())
        let base = cal.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        let weekStart = cal.date(byAdding: .weekOfYear, value: offset, to: base) ?? base

        let plans = self.plans(from: weekStart, count: 7, group: group,
                               calendar: calendar, minMinutes: minMinutes, using: cal)
        let (img, desc) = hero(weekStart: weekStart, calendar: cal)
        return WillowWeek(plans: plans,
                          title: titleRange(weekStart: weekStart, calendar: cal),
                          subtitle: subtitle(offset: offset),
                          heroImage: img, heroDescription: desc)
    }

    /// `count` days of DayPlans starting at `startDay` — reused for the Home week
    /// and for scheduling notifications from today forward.
    static func plans(from startDay: Date, count: Int, group: Group?,
                      calendar store: CalendarStore, minMinutes: Int,
                      using cal: Calendar = .current) -> [DayPlan] {
        let isGroup = (group?.members.isEmpty == false)
        return (0..<count).compactMap { i in
            guard let day = cal.date(byAdding: .day, value: i, to: startDay) else { return nil }
            let dayStart = cal.startOfDay(for: day)
            guard let dayEnd = cal.date(byAdding: .day, value: 1, to: dayStart) else { return nil }

            var busy = store.busy(from: dayStart, to: dayEnd)
            if let group {
                for m in group.members {
                    busy += m.busy.filter { $0.start < dayEnd && $0.end > dayStart }
                }
            }
            let blocks = FreeTime.freeBlocks(busy: busy, dayStart: dayStart,
                                             minMinutes: minMinutes, calendar: cal)
            return DayPlan(date: dayStart, events: blocks,
                           dynamicCardMessage: message(blocks: blocks, isGroup: isGroup))
        }
    }

    private static func titleRange(weekStart: Date, calendar: Calendar) -> String {
        let fmt = DateFormatter(); fmt.dateFormat = "d MMM"
        let end = calendar.date(byAdding: .day, value: 6, to: weekStart) ?? weekStart
        return "\(fmt.string(from: weekStart)) - \(fmt.string(from: end))"
    }

    private static func subtitle(offset: Int) -> String {
        switch offset {
        case 1: return "What's happening next week"
        case 2: return "What's happening in 2 weeks"
        default: return "What's happening this week"
        }
    }

    private static func message(blocks: [TimeBlock], isGroup: Bool) -> String {
        let who = isGroup ? "You both have" : "You have"
        if blocks.isEmpty {
            return isGroup ? "No shared free time today." : "No free time today — looks fully booked."
        }
        if blocks.count >= 2 {
            return "\(who) \(blocks.count) free windows today — plenty of time to make plans."
        }
        let h = blocks[0].startHour
        let part = h < 12 ? "a free morning" : (h < 17 ? "a free afternoon" : "a free evening")
        return "\(who) \(part) together today."
    }

    // Auto seasonal hero when the week contains a special date.
    private static func hero(weekStart: Date, calendar: Calendar) -> (String, String) {
        for i in 0..<7 {
            guard let d = calendar.date(byAdding: .day, value: i, to: weekStart) else { continue }
            let m = calendar.component(.month, from: d), day = calendar.component(.day, from: d)
            if m == 12 && day == 25 { return ("Xmas", "Christmas lands this week! Find time to celebrate together.") }
            if m == 1 && day == 1 { return ("newYears", "Happy New Year!\nSpend it with loved ones.") }
            if m == 2 && day == 14 { return ("Valentine", "Valentine's Day is yours to celebrate.\nMake it memorable.") }
        }
        return ("homeScreenImage", "Life gets busy.\nTime together doesn't have to.")
    }
}
