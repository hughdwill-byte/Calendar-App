//
//  SettingsView.swift
//  Apple App
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("notificationsPerDay") private var notificationsPerDay: Int = 1
    @AppStorage("notificationSpacingHours") private var notificationSpacingHours: Int = 3
    @AppStorage("freeTimeMinLengthMinutes") private var freeTimeMinLengthMinutes: Int = 30
    @AppStorage("weeklySummaryEnabled") private var weeklySummaryEnabled: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                settingsHeader
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.largeTitle)
            .padding()
        }
    }

    private var settingsHeader: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Text("Settings")
                    .fontWeight(.bold)
            }
            HStack {
                Text("Notifications Per Day")
                    .padding()
                    .font(.body)
                    .fontWeight(.bold)
                Spacer()
                Picker("", selection: $notificationsPerDay) {
                    ForEach(1..<6, id: \.self) { count in
                        Text("\(count)").tag(count)
                    }
                }
                .labelsHidden()
            }
            HStack {
                Text("Hours Between Notifications")
                    .padding()
                    .font(.body)
                    .fontWeight(.bold)
                Spacer()
                Picker("", selection: $notificationSpacingHours) {
                    ForEach(1..<13, id: \.self) { hour in
                        Text("\(hour)").tag(hour)
                    }
                }
                .labelsHidden()
            }
            HStack {
                Text("Free Time Length (min)")
                    .padding()
                    .font(.body)
                    .fontWeight(.bold)
                Spacer()
                Picker("", selection: $freeTimeMinLengthMinutes) {
                    ForEach([15, 30, 45, 60, 90, 120, 180], id: \.self) { minutes in
                        Text("\(minutes)").tag(minutes)
                    }
                }
                .labelsHidden()
            }
            HStack {
                Text("Weekly Summary")
                    .padding()
                    .font(.body)
                    .fontWeight(.bold)
                Spacer()
                Toggle("", isOn: $weeklySummaryEnabled)
                    .labelsHidden()
                    .toggleStyle(SwitchToggleStyle())
            }
        }
    }
}

#Preview {
    SettingsView()
}
