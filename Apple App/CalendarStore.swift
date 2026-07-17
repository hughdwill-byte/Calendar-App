//
//  CalendarStore.swift
//  Apple App
//
//  Reads the user's real calendars via EventKit. EventKit aggregates EVERY
//  account added in iOS Settings — iCloud, Google, Outlook, Exchange — so this
//  is the "all calendar types" integration without any paid API keys.
//

import SwiftUI
import EventKit

// One calendar the user can include/exclude, tagged with its account.
struct CalendarInfo: Identifiable, Hashable {
    let id: String
    let title: String
    let accountTitle: String
    let accountType: String
    let color: Color
}

@MainActor @Observable
final class CalendarStore {
    var calendars: [CalendarInfo] = []
    private(set) var accessGranted = false

    private let store = EKEventStore()
    private var includedIDs: Set<String>? {   // nil = every calendar
        didSet { persistIncluded() }
    }

    init() {
        if let arr = UserDefaults.standard.array(forKey: SettingsKey.includedCalendarIDs) as? [String] {
            includedIDs = Set(arr)
        }
        accessGranted = hasAccess
        if accessGranted { loadCalendars() }
    }

    var authStatus: EKAuthorizationStatus { EKEventStore.authorizationStatus(for: .event) }
    var hasAccess: Bool { authStatus == .fullAccess }

    var userName: String {
        let n = UserDefaults.standard.string(forKey: SettingsKey.userName) ?? ""
        return n.isEmpty ? "Me" : n
    }

    @discardableResult
    func requestAccess() async -> Bool {
        let granted = (try? await store.requestFullAccessToEvents()) ?? false
        accessGranted = granted
        if granted { loadCalendars() }
        return granted
    }

    // MARK: Calendar sources / selection

    private func loadCalendars() {
        calendars = store.calendars(for: .event)
            .map {
                CalendarInfo(id: $0.calendarIdentifier,
                             title: $0.title,
                             accountTitle: $0.source.title,
                             accountType: Self.label(for: $0.source.sourceType),
                             color: Color(cgColor: $0.cgColor ?? UIColor.systemBlue.cgColor))
            }
            .sorted { ($0.accountTitle, $0.title) < ($1.accountTitle, $1.title) }
    }

    private static func label(for type: EKSourceType) -> String {
        switch type {
        case .local: return "On My iPhone"
        case .exchange: return "Exchange / Outlook"
        case .calDAV: return "iCloud / Google"
        case .mobileMe: return "iCloud"
        case .subscribed: return "Subscribed"
        case .birthdays: return "Birthdays"
        @unknown default: return "Calendar"
        }
    }

    func isIncluded(_ id: String) -> Bool { includedIDs?.contains(id) ?? true }

    func setIncluded(_ id: String, _ on: Bool) {
        let all = Set(calendars.map(\.id))
        var set = includedIDs ?? all
        if on { set.insert(id) } else { set.remove(id) }
        includedIDs = (set == all) ? nil : set
    }

    private func persistIncluded() {
        let d = UserDefaults.standard
        if let ids = includedIDs { d.set(Array(ids), forKey: SettingsKey.includedCalendarIDs) }
        else { d.removeObject(forKey: SettingsKey.includedCalendarIDs) }
    }

    private func includedCalendars() -> [EKCalendar]? {
        guard let ids = includedIDs else { return nil }   // nil = all
        return store.calendars(for: .event).filter { ids.contains($0.calendarIdentifier) }
    }

    // MARK: Busy extraction

    /// The viewer's busy intervals in a date range, from included calendars.
    func busy(from start: Date, to end: Date) -> [BusyInterval] {
        guard hasAccess else { return [] }
        let pred = store.predicateForEvents(withStart: start, end: end, calendars: includedCalendars())
        return store.events(matching: pred)
            .filter { !$0.isAllDay }
            .map { BusyInterval(start: $0.startDate, end: $0.endDate) }
    }

    /// The viewer's busy over the next `days` days (for sharing).
    func myBusy(days: Int) -> [BusyInterval] {
        let cal = Calendar.current
        let start = cal.startOfDay(for: Date())
        guard let end = cal.date(byAdding: .day, value: days, to: start) else { return [] }
        return busy(from: start, to: end)
    }

    /// The shareable invite payload for a given group.
    func invitePayload(groupName: String) -> InvitePayload {
        InvitePayload(group: groupName,
                      member: GroupMember(name: userName,
                                          generated: Date(),
                                          busy: myBusy(days: Availability.horizonDays)))
    }
}
