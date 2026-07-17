//
//  ContentView.swift
//  Apple App
//
//  Root: the Willow home in a NavigationStack, with the shared calendar and
//  group stores injected. Requests calendar access on first launch.
//

import SwiftUI
import EventKit

struct ContentView: View {
    @State private var calendar = CalendarStore()
    @State private var groups = GroupStore()

    var body: some View {
        NavigationStack {
            HomeView()
        }
        .environment(calendar)
        .environment(groups)
        .task {
            if calendar.authStatus == .notDetermined {
                await calendar.requestAccess()
            }
            await NotificationManager.reschedule(calendar: calendar, groups: groups)
        }
    }
}

#Preview {
    ContentView()
}
