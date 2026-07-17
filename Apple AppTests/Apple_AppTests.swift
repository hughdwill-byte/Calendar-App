//
//  Apple_AppTests.swift
//  Apple AppTests
//
//  Money path: free-time gap computation (incl. multi-person union) + invite codec.
//

import XCTest
@testable import Apple_App

final class Apple_AppTests: XCTestCase {

    private let cal = Calendar.current
    private var dayStart: Date { cal.startOfDay(for: cal.date(from: DateComponents(year: 2026, month: 7, day: 13))!) }

    private func busy(_ fromHour: Double, _ toHour: Double) -> BusyInterval {
        BusyInterval(start: dayStart.addingTimeInterval(fromHour * 3600),
                     end: dayStart.addingTimeInterval(toHour * 3600))
    }

    private func free(_ busy: [BusyInterval], min: Int = 30) -> [TimeBlock] {
        FreeTime.freeBlocks(busy: busy, dayStart: dayStart, minMinutes: min, calendar: cal)
    }

    // MARK: Free-time gaps

    func testGapsAroundOneEvent() {
        XCTAssertEqual(free([busy(9, 11)]),
                       [TimeBlock(startHour: 7, endHour: 9), TimeBlock(startHour: 11, endHour: 23)])
    }

    func testOverlappingBusyMerges() {
        // Two people busy 9–12 and 11–14 → single busy block 9–14.
        XCTAssertEqual(free([busy(9, 12), busy(11, 14)]),
                       [TimeBlock(startHour: 7, endHour: 9), TimeBlock(startHour: 14, endHour: 23)])
    }

    func testPartialHoursRoundedConservatively() {
        // Busy 9:30–10:30 → never claims the partial 9–9:30 or 10:30–11 as free.
        XCTAssertEqual(free([busy(9.5, 10.5)]),
                       [TimeBlock(startHour: 7, endHour: 9), TimeBlock(startHour: 11, endHour: 23)])
    }

    func testMinimumLengthFilterDropsShortGaps() {
        // Only a 1-hour gap (9–10) remains; a 90-minute floor removes it.
        XCTAssertEqual(free([busy(7, 9), busy(10, 23)], min: 90), [])
        XCTAssertEqual(free([busy(7, 9), busy(10, 23)], min: 30), [TimeBlock(startHour: 9, endHour: 10)])
    }

    func testFullyBookedGivesNoFreeTime() {
        XCTAssertEqual(free([busy(7, 23)]), [])
    }

    // MARK: Invite codec

    func testInviteCodecRoundTrips() {
        let payload = InvitePayload(
            group: "Weekend Crew",
            member: GroupMember(name: "Sam", generated: Date(timeIntervalSince1970: 1_700_000_000),
                                busy: [BusyInterval(start: Date(timeIntervalSince1970: 1_700_003_600),
                                                    end: Date(timeIntervalSince1970: 1_700_007_200))]))
        let decoded = InviteCodec.decode(InviteCodec.encode(payload))
        XCTAssertEqual(decoded?.group, "Weekend Crew")
        XCTAssertEqual(decoded?.member.name, "Sam")
        XCTAssertEqual(decoded?.member.busy.count, 1)
    }

    func testInviteCodecToleratesLinkAndWhitespace() {
        let payload = InvitePayload(group: "G", member: GroupMember(name: "A", generated: Date(), busy: []))
        let link = InviteCodec.link(payload)
        XCTAssertTrue(link.hasPrefix("afp://join?d="))
        XCTAssertEqual(InviteCodec.decode("  \n\(link)\n ")?.member.name, "A")
    }

    func testInviteCodecRejectsGarbage() {
        XCTAssertNil(InviteCodec.decode("not a real code"))
    }
}
