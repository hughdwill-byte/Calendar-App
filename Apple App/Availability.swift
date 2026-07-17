//
//  Availability.swift
//  Apple App
//
//  Shared free/busy model + the offline invite-code / link codec used to
//  join groups. Free-time computation lives in WillowSchedule.swift.
//

import Foundation

// MARK: - Settings keys shared across the app

enum SettingsKey {
    static let userName = "userName"
    static let includedCalendarIDs = "includedCalendarIDs" // absent = every calendar
    static let freeTimeMinLengthMinutes = "freeTimeMinLengthMinutes"
}

enum Availability {
    /// How many days ahead availability is computed and shared (3 weeks so the
    /// "1 week" / "2 weeks" pills have real group data to combine).
    static let horizonDays = 21
}

// MARK: - Busy intervals

struct BusyInterval: Codable, Hashable {
    var start: Date
    var end: Date
}

// MARK: - Group membership

struct GroupMember: Codable, Identifiable, Hashable {
    var id = UUID()
    var name: String
    var generated: Date
    var busy: [BusyInterval]
}

// What a single invite code / link carries: the sharer, and the group they're in.
struct InvitePayload: Codable {
    var group: String
    var member: GroupMember
}

// MARK: - Offline invite codec (no server — the payload IS the link)

enum InviteCodec {
    static let linkPrefix = "afp://join?d="

    static func encode(_ payload: InvitePayload) -> String {
        let enc = JSONEncoder()
        enc.dateEncodingStrategy = .secondsSince1970
        guard let data = try? enc.encode(payload) else { return "" }
        return data.base64EncodedString()
        // ponytail: plain base64 JSON — fine for share-sheet/paste. Add zlib
        // compression + base64url if codes get too long or need to be tappable URLs.
    }

    static func link(_ payload: InvitePayload) -> String { linkPrefix + encode(payload) }

    /// Tolerant: accepts a raw code, an `afp://join?d=…` link, or pasted text around it.
    static func decode(_ raw: String) -> InvitePayload? {
        var s = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if let r = s.range(of: "d=") { s = String(s[r.upperBound...]) }
        s = s.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let data = Data(base64Encoded: s) else { return nil }
        let dec = JSONDecoder()
        dec.dateDecodingStrategy = .secondsSince1970
        return try? dec.decode(InvitePayload.self, from: data)
    }
}
