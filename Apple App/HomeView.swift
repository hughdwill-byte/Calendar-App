//
//  HomeView.swift
//  Apple App
//
//  Willow home: hero, week pills, and the expandable free-time timeline —
//  now backed by real calendars and the active group's combined availability.
//

import SwiftUI

struct HomeView: View {
    @Environment(CalendarStore.self) private var calendar
    @Environment(GroupStore.self) private var groups
    @AppStorage(SettingsKey.freeTimeMinLengthMinutes) private var minMinutes: Int = 30

    @State private var selectedWeek = 0
    @State private var week = WillowWeek.empty

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 15) {
                OverviewTitleView(title: week.title, subtitle: subtitle)
                    .padding(.bottom, 15)

                HStack {
                    weekPill("This week", 0)
                    weekPill("1 week", 1)
                    weekPill("2 weeks", 2)
                }

                ScrollView {
                    Image(week.heroImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250, height: 240)
                        .padding(.top, 10)

                    Text(week.heroDescription)
                        .bold()
                        .multilineTextAlignment(.center)
                        .frame(width: 300, height: 50)

                    if calendar.hasAccess {
                        FreeTimeView1(dayEntries: week.plans)
                            .animation(.easeInOut(duration: 0.3), value: week.plans.count)
                    } else {
                        connectPrompt
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: ConnectView()) {
                        Image(systemName: "link")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "ellipsis")
                    }
                }
            }
            .toolbarTitleDisplayMode(.inline)
        }
        .task { rebuild() }
        .onAppear { rebuild() }
        .onChange(of: calendar.accessGranted) { rebuild() }
        .onChange(of: groups.activeGroupID) { rebuild() }
        .onChange(of: minMinutes) { rebuild() }
    }

    private var subtitle: String {
        if let g = groups.activeGroup, !g.members.isEmpty {
            return "\(week.subtitle) · \(g.name)"
        }
        return week.subtitle
    }

    private func weekPill(_ text: String, _ index: Int) -> some View {
        PillText(
            text: text,
            background: selectedWeek == index ? .color1 : .gray.opacity(0.2),
            textColor: selectedWeek == index ? .white : .gray
        ) {
            selectedWeek = index
            rebuild()
        }
    }

    private func rebuild() {
        week = ScheduleBuilder.week(offset: selectedWeek, group: groups.activeGroup,
                                    calendar: calendar, minMinutes: minMinutes)
    }

    private var connectPrompt: some View {
        VStack(spacing: 15) {
            Text("Connect your calendar to see your free time.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            PillText(text: "Connect calendars", background: .color1, textColor: .white) {
                Task { await calendar.requestAccess(); rebuild() }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 30)
        .padding(.top, 20)
    }
}

#Preview {
    NavigationStack { HomeView() }
        .environment(CalendarStore())
        .environment(GroupStore())
}
