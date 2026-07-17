//
//  NotificationManager.swift
//  Apple App
//
//  Makes the Settings notification options real. Schedules local reminders about
//  upcoming free time (respecting "Notifications Per Day" and the spacing), plus
//  an optional weekly summary. Rescheduled on launch and when settings change —
//  local notifications can't refresh in the background, so the rolling 7-day
//  window is topped up each time the app runs.
//

import Foundation
import UserNotifications

enum NotificationManager {
    private static let dailyPrefix = "free-daily-"
    private static let weeklyID = "weekly-summary"
    private static let firstHour = 9   // first daily reminder at 09:00
    private static let lastHour = 21   // don't fire reminders after 21:00

    @MainActor
    static func reschedule(calendar: CalendarStore, groups: GroupStore) async {
        let d = UserDefaults.standard
        let perDay = max(1, d.object(forKey: "notificationsPerDay") as? Int ?? 1)
        let spacing = max(1, d.object(forKey: "notificationSpacingHours") as? Int ?? 3)
        let minMinutes = d.object(forKey: SettingsKey.freeTimeMinLengthMinutes) as? Int ?? 30
        let weekly = d.bool(forKey: "weeklySummaryEnabled")

        let center = UNUserNotificationCenter.current()
        guard (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) == true,
              calendar.hasAccess else { return }

        // Only clear the notifications we own, then rebuild them.
        let pending = await center.pendingNotificationRequests()
        center.removePendingNotificationRequests(withIdentifiers:
            pending.map(\.identifier).filter { $0.hasPrefix(dailyPrefix) || $0 == weeklyID })

        let cal = Calendar.current
        let group = groups.activeGroup
        let isGroup = (group?.members.isEmpty == false)
        let plans = ScheduleBuilder.plans(from: cal.startOfDay(for: Date()), count: 7,
                                          group: group, calendar: calendar, minMinutes: minMinutes)

        for plan in plans where !plan.events.isEmpty {
            let dayStart = cal.startOfDay(for: plan.date)
            for i in 0..<perDay {
                let hour = firstHour + i * spacing
                guard hour <= lastHour,
                      let fire = cal.date(bySettingHour: hour, minute: 0, second: 0, of: dayStart),
                      fire > Date() else { continue }

                let content = UNMutableNotificationContent()
                content.title = isGroup ? "Shared free time" : "You have free time"
                content.body = body(for: plan, isGroup: isGroup, calendar: cal)
                content.sound = .default

                let comps = cal.dateComponents([.year, .month, .day, .hour, .minute], from: fire)
                let request = UNNotificationRequest(
                    identifier: "\(dailyPrefix)\(Int(fire.timeIntervalSince1970))",
                    content: content,
                    trigger: UNCalendarNotificationTrigger(dateMatching: comps, repeats: false))
                try? await center.add(request)
            }
        }

        if weekly { await scheduleWeekly(center: center, cal: cal) }
    }

    private static func scheduleWeekly(center: UNUserNotificationCenter, cal: Calendar) async {
        let content = UNMutableNotificationContent()
        content.title = "Your week ahead"
        content.body = "Open Willow to see when you're free together this week."
        content.sound = .default
        var comps = DateComponents()
        comps.weekday = 2   // Monday
        comps.hour = firstHour
        let request = UNNotificationRequest(
            identifier: weeklyID, content: content,
            trigger: UNCalendarNotificationTrigger(dateMatching: comps, repeats: true))
        try? await center.add(request)
    }

    private static func body(for plan: DayPlan, isGroup: Bool, calendar cal: Calendar) -> String {
        guard let first = plan.events.first else { return "Find a moment together today." }
        let who = isGroup ? "You're both free" : "You're free"
        let extra = plan.events.count > 1 ? " and \(plan.events.count - 1) more window\(plan.events.count > 2 ? "s" : "")" : ""
        return "\(who) \(clock(first.startHour))–\(clock(first.endHour)) today\(extra)."
    }

    private static func clock(_ hour: Int) -> String {
        let h = hour % 12 == 0 ? 12 : hour % 12
        return "\(h) \(hour < 12 ? "AM" : "PM")"
    }
}
