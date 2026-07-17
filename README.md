# Calendar App (AFP) — Willow

A SwiftUI iOS app for finding shared free time. It reads your real calendars,
shows your free windows on a weekly timeline, and lets you combine calendars
with friends or a partner to see when everyone is free — all on-device, no
backend, no paid APIs.

> **Original (pre-AI) version:** https://github.com/hughdwill-byte/AFP-App
>
> This repository is the AI-assisted, finished build. The original,
> un-AI-modified project lives in the repo linked above.

## Features

- **All calendar types via EventKit.** Reads every account you've added in iOS
  Settings — iCloud, Google, Outlook, Exchange, subscribed — with no OAuth keys
  or paid services. Choose which calendars count in **Connect**.
- **Weekly free-time timeline.** Each day shows your free windows on a 0–24h bar
  (waking hours 07:00–23:00); tap a day to expand it, read a suggestion, and
  share a window. Week pills switch between this week / +1 / +2 weeks.
- **Groups (offline, no server).** Share an invite code/link; a friend pastes it
  (or you paste theirs) and the app combines everyone's free/busy locally to show
  shared free time. Codes carry the data — nothing leaves the device except the
  code you choose to share. Join flow mirrors a paste-a-code "deal-board" style.
- **Auto seasonal home art** (Christmas, Valentine's, New Year) when the viewed
  week contains that date; the default "willow" art otherwise.
- **Settings** for minimum free-time length and notification preferences.

## Design

The UI is the **Willow** design. In-app art and colours are bundled in the asset
catalog.

## Build & run

- Xcode 26+, iOS 26 simulator or device.
- Open `Apple App.xcodeproj`, select the **Apple App** scheme, and run.
- On first launch the app asks for Calendar access (required for your own free
  time). Group members' availability comes from pasted invite codes.

## Tests

`Apple AppTests` covers the core logic — free-time gap computation (including the
multi-person union used for groups) and the invite-code round-trip. Run with
**⌘U** or:

```sh
xcodebuild test -scheme "Apple App" -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

## How it works

- `CalendarStore` — EventKit access, calendar sources/selection, busy extraction.
- `WillowSchedule.swift` — turns busy intervals into free `TimeBlock`s and builds
  each week's `DayPlan`s (your calendar ∪ the active group's members).
- `GroupStore` + `InviteCodec` — local groups, join-by-code, and the
  `afp://join?d=<base64>` code/link format.
- Views — `HomeView`, `ConnectView`, `SettingsView`, and the Willow components
  (`ExpandableView`, `DayPlanHorizontalView`, `FTCapsule`, `PillText`, …).

## Notes / limitations

- For 3+ people, everyone pastes everyone's code (no live sync) — fine for
  couples and small groups.
- Notification settings persist but don't schedule notifications yet.
