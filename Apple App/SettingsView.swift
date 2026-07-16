//
//  SettingsView.swift
//  Apple App
//
//  Created by Hugh Williams on 13/7/2026.
//

import SwiftUI

struct SettingsView: View {
    @State private var setting1Value: Bool = false
    @State private var setting2Value: Bool = false
    @AppStorage(SettingsKey.windowStartHour) private var windowStartHour: Int = 8
    @AppStorage(SettingsKey.blockCount) private var blockCount: Int = 6
    @AppStorage(SettingsKey.blockHours) private var blockHours: Int = 2

    var body: some View {
        VStack(alignment: .leading) {
            settingsHeader
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .font(.largeTitle)
        .padding()
    }
    
    private var settingsHeader: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Text("Settings")
                    .fontWeight(.bold)
            }
            HStack {
                Text("Setting 1")
                    .padding()
                    .font(.body)
                Spacer()
                Toggle("", isOn: $setting1Value)
                    .labelsHidden()
                    .toggleStyle(SwitchToggleStyle())
            }
            HStack {
                Text("Setting 2")
                    .padding()
                    .font(.body)
                Spacer()
                Toggle("", isOn: $setting2Value)
                    .labelsHidden()
                    .toggleStyle(SwitchToggleStyle())
            }
            HStack {
                Text("Start Time")
                    .padding()
                    .font(.body)
                Spacer()
                Picker("", selection: $windowStartHour) {
                    ForEach(0..<24, id: \.self) { hour in
                        Text(String(format: "%02d:00", hour)).tag(hour)
                    }
                }
                .labelsHidden()
            }
            HStack {
                Text("Number of Periods")
                    .padding()
                    .font(.body)
                Spacer()
                Picker("", selection: $blockCount) {
                    ForEach(0..<9, id: \.self) { count in
                        Text("\(count)").tag(count)
                    }
                }
                .labelsHidden()
            }
            HStack {
                Text("Period Length (h)")
                    .padding()
                    .font(.body)
                Spacer()
                Picker("", selection: $blockHours) {
                    ForEach(0..<4, id: \.self) { count in
                        Text("\(count)").tag(count)
                    }
                }
                .labelsHidden()
            }
        }
    }
}

#Preview {
    SettingsView()
}
