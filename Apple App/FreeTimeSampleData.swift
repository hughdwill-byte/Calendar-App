//
//  FreeTimeData.swift
//  Calendar App
//
//  Created by Minh Thu Nguyen on 13/7/2026.
//

import Foundation

let sampleDays: [DayPlan] = [
    // Monday (13 Jul)
    DayPlan(
        date: makeDate(year: 2026, month: 7, day: 13, hour: 0),
        events: [],
        dynamicCardMessage: "Looks like you're both fully booked today."
    ),

    // Tuesday (14 Jul)
    DayPlan(
        date: makeDate(year: 2026, month: 7, day: 14, hour: 0),
        events: [
            TimeBlock(startHour: 7, endHour: 9)
        ],
        dynamicCardMessage: "You have a shared morning free—perfect for breakfast or a coffee before work."
    ),

    // Wednesday (15 Jul)
    DayPlan(
        date: makeDate(year: 2026, month: 7, day: 15, hour: 0),
        events: [],
        dynamicCardMessage: "No shared free time today. Maybe check in with each other when you can."
    ),

    // Thursday (16 Jul)
    DayPlan(
        date: makeDate(year: 2026, month: 7, day: 16, hour: 0),
        events: [
            TimeBlock(startHour: 18, endHour: 23)
        ],
        dynamicCardMessage: "You have the evening free together. A great opportunity for a date night."
    ),

    // Friday (17 Jul)
    DayPlan(
        date: makeDate(year: 2026, month: 7, day: 17, hour: 0),
        events: [
            TimeBlock(startHour: 9, endHour: 10),
            TimeBlock(startHour: 17, endHour: 22)
        ],
        dynamicCardMessage: "You have two shared windows today. A quick coffee this morning or dinner tonight could be nice."
    ),

    // Saturday (18 Jul)
    DayPlan(
        date: makeDate(year: 2026, month: 7, day: 18, hour: 0),
        events: [
            TimeBlock(startHour: 8, endHour: 22)
        ],
        dynamicCardMessage: "You have the whole day to yourselves today."
    ),

    // Sunday (19 Jul)
    DayPlan(
        date: makeDate(year: 2026, month: 7, day: 19, hour: 0),
        events: [
            TimeBlock(startHour: 8, endHour: 17)
        ],
        dynamicCardMessage: "You have most of the day free before the week begins again."
    )
]

let sampleDaysPlusOne: [DayPlan] = [
    // Monday (20 Jul)
    DayPlan(
        date: makeDate(year: 2026, month: 7, day: 20, hour: 0),
        events: [],
        dynamicCardMessage: "A busy start to the week with no shared free time today."
    ),

    // Tuesday (21 Jul)
    DayPlan(
        date: makeDate(year: 2026, month: 7, day: 21, hour: 0),
        events: [
            TimeBlock(startHour: 7, endHour: 9)
        ],
        dynamicCardMessage: "You have some free time together this morning before work."
    ),

    // Wednesday (22 Jul)
    DayPlan(
        date: makeDate(year: 2026, month: 7, day: 22, hour: 0),
        events: [
            TimeBlock(startHour: 18, endHour: 21)
        ],
        dynamicCardMessage: "You have a shared evening today. Maybe enjoy dinner together."
    ),

    // Thursday (23 Jul)
    DayPlan(
        date: makeDate(year: 2026, month: 7, day: 23, hour: 0),
        events: [
            TimeBlock(startHour: 12, endHour: 13),
            TimeBlock(startHour: 18, endHour: 22)
        ],
        dynamicCardMessage: "You have a lunch break and your evening free. Plenty of time to reconnect."
    ),

    // Friday (24 Jul)
    DayPlan(
        date: makeDate(year: 2026, month: 7, day: 24, hour: 0),
        events: [
            TimeBlock(startHour: 17, endHour: 23)
        ],
        dynamicCardMessage: "Your Friday evening is free together. A nice way to end the work week."
    ),

    // Saturday (25 Jul)
    DayPlan(
        date: makeDate(year: 2026, month: 7, day: 25, hour: 0),
        events: [
            TimeBlock(startHour: 8, endHour: 22)
        ],
        dynamicCardMessage: "You have the whole day free. It's the perfect time to plan something together."
    ),

    // Sunday (26 Jul)
    DayPlan(
        date: makeDate(year: 2026, month: 7, day: 26, hour: 0),
        events: [
            TimeBlock(startHour: 8, endHour: 18)
        ],
        dynamicCardMessage: "You have most of Sunday free. Make the most of it before Monday."
    )
]

let sampleDaysPlusTwo: [DayPlan] = [
    // Monday (27 Jul)
    DayPlan(
        date: makeDate(year: 2026, month: 8, day: 27, hour: 0),
        events: [],
        dynamicCardMessage: "Today is fully booked for both of you."
    ),

    // Tuesday (28 Jul)
    DayPlan(
        date: makeDate(year: 2026, month: 7, day: 28, hour: 0),
        events: [
            TimeBlock(startHour: 7, endHour: 10)
        ],
        dynamicCardMessage: "You have a relaxed morning together before the day gets busy."
    ),

    // Wednesday (29 Jul)
    DayPlan(
        date: makeDate(year: 2026, month: 7, day: 29, hour: 0),
        events: [],
        dynamicCardMessage: "No shared free time today."
    ),

    // Thursday (30 Jul)
    DayPlan(
        date: makeDate(year: 2026, month: 7, day: 30, hour: 0),
        events: [
            TimeBlock(startHour: 9, endHour: 10),
            TimeBlock(startHour: 17, endHour: 22)
        ],
        dynamicCardMessage: "You have time together this morning and again after work."
    ),

    // Friday (31 Jul)
    DayPlan(
        date: makeDate(year: 2026, month: 7, day: 31, hour: 0),
        events: [
            TimeBlock(startHour: 18, endHour: 23)
        ],
        dynamicCardMessage: "Your evening is free together. A perfect excuse to unwind together."
    ),

    // Saturday (1 Aug)
    DayPlan(
        date: makeDate(year: 2026, month: 8, day: 1, hour: 0),
        events: [
            TimeBlock(startHour: 9, endHour: 23)
        ],
        dynamicCardMessage: "Most of your Saturday is free. Why not plan something you've both been looking forward to?"
    ),

    // Sunday (2 Aug)
    DayPlan(
        date: makeDate(year: 2026, month: 8, day: 2, hour: 0),
        events: [
            TimeBlock(startHour: 9, endHour: 17)
        ],
        dynamicCardMessage: "You have a relaxed Sunday before the new week begins."
    )
]

let sampleDaysValentines: [DayPlan] = [
    // Monday (9 Feb)
    DayPlan(
        date: makeDate(year: 2026, month: 2, day: 9, hour: 0),
        events: [],
        dynamicCardMessage: "A busy start to the week. Even a few shared minutes can make a difference."
    ),

    // Tuesday (10 Feb)
    DayPlan(
        date: makeDate(year: 2026, month: 2, day: 10, hour: 0),
        events: [
            TimeBlock(startHour: 7, endHour: 9)
        ],
        dynamicCardMessage: "A shared morning is perfect for breakfast before the day begins."
    ),

    // Wednesday (11 Feb)
    DayPlan(
        date: makeDate(year: 2026, month: 2, day: 11, hour: 0),
        events: [],
        dynamicCardMessage: "No shared free time today. A thoughtful message can still go a long way."
    ),

    // Thursday (12 Feb)
    DayPlan(
        date: makeDate(year: 2026, month: 2, day: 12, hour: 0),
        events: [
            TimeBlock(startHour: 18, endHour: 21)
        ],
        dynamicCardMessage: "A free evening together. An early Valentine's date could be just the thing."
    ),

    // Friday (13 Feb)
    DayPlan(
        date: makeDate(year: 2026, month: 2, day: 13, hour: 0),
        events: [
            TimeBlock(startHour: 17, endHour: 23)
        ],
        dynamicCardMessage: "The weekend starts tonight. A perfect chance to celebrate a little early."
    ),

    // Saturday (14 Feb) - Valentine's Day
    DayPlan(
        date: makeDate(year: 2026, month: 2, day: 14, hour: 0),
        events: [
            TimeBlock(startHour: 10, endHour: 22)
        ],
        dynamicCardMessage: "Valentine's Day is yours to celebrate. Make it memorable."
    ),

    // Sunday (15 Feb)
    DayPlan(
        date: makeDate(year: 2026, month: 2, day: 15, hour: 0),
        events: [
            TimeBlock(startHour: 9, endHour: 17)
        ],
        dynamicCardMessage: "Keep the Valentine's spirit going with a relaxed day together."
    )
]

let sampleDaysNewYears: [DayPlan] = [
    // Monday (28 Dec)
    DayPlan(
        date: makeDate(year: 2026, month: 12, day: 28, hour: 0),
        events: [],
        dynamicCardMessage: "The year's almost over. There's still time to make a few more memories together."
    ),

    // Tuesday (29 Dec)
    DayPlan(
        date: makeDate(year: 2026, month: 12, day: 29, hour: 0),
        events: [
            TimeBlock(startHour: 18, endHour: 21)
        ],
        dynamicCardMessage: "You have the evening free together. A great time to reflect on the year."
    ),

    // Wednesday (30 Dec)
    DayPlan(
        date: makeDate(year: 2026, month: 12, day: 30, hour: 0),
        events: [
            TimeBlock(startHour: 7, endHour: 9)
        ],
        dynamicCardMessage: "A shared morning is perfect for coffee and planning the year ahead."
    ),

    // Thursday (31 Dec) - New Year's Eve
    DayPlan(
        date: makeDate(year: 2026, month: 12, day: 31, hour: 0),
        events: [
            TimeBlock(startHour: 18, endHour: 23)
        ],
        dynamicCardMessage: "A new year is just around the corner. Celebrate the final moments together."
    ),

    // Friday (1 Jan) - New Year's Day
    DayPlan(
        date: makeDate(year: 2027, month: 1, day: 1, hour: 0),
        events: [
            TimeBlock(startHour: 10, endHour: 22)
        ],
        dynamicCardMessage: "New year, new memories. Start it together."
    ),

    // Saturday (2 Jan)
    DayPlan(
        date: makeDate(year: 2027, month: 1, day: 2, hour: 0),
        events: [
            TimeBlock(startHour: 9, endHour: 21)
        ],
        dynamicCardMessage: "The first weekend of the year is yours to enjoy. Make the most of it together."
    ),

    // Sunday (3 Jan)
    DayPlan(
        date: makeDate(year: 2027, month: 1, day: 3, hour: 0),
        events: [
            TimeBlock(startHour: 9, endHour: 17)
        ],
        dynamicCardMessage: "A relaxed Sunday is the perfect way to begin the year together."
    )
]
