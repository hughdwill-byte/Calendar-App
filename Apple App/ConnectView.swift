//
//  ConnectView.swift
//  Apple App
//
//  The link-button destination: connect calendars, choose whose free time the
//  Home screen combines (just you or a group), and join/create/share groups by
//  code — the offline "deal-board"-style join flow.
//

import SwiftUI

struct ConnectView: View {
    @Environment(CalendarStore.self) private var calendar
    @Environment(GroupStore.self) private var groups

    @State private var joinCode = ""
    @State private var newName = ""
    @State private var joinError: String?

    @State private var showAdd = false
    @State private var addCode = ""
    @State private var addTarget: Group?

    var body: some View {
        List {
            calendarsSection
            contextSection
            joinSection
            Section {
                Text("Everyone's free/busy stays on-device. Share your code and have a friend paste it — or paste theirs — to combine calendars. Add Google/Outlook/Exchange accounts in the iOS Settings app; they appear here automatically.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Connect")
        .tint(.color1)
        .alert("Add person", isPresented: $showAdd) {
            TextField("Paste their code", text: $addCode)
            Button("Add") { addPerson() }
            Button("Cancel", role: .cancel) { addCode = "" }
        } message: {
            Text("Paste an invite code a friend shared with you.")
        }
    }

    // MARK: Calendars

    @ViewBuilder private var calendarsSection: some View {
        Section("Calendars") {
            if !calendar.hasAccess {
                Button("Connect calendars") { Task { await calendar.requestAccess() } }
            } else if calendar.calendars.isEmpty {
                Text("No calendars found.").foregroundStyle(.secondary)
            } else {
                ForEach(accounts, id: \.self) { account in
                    DisclosureGroup(account) {
                        ForEach(calendar.calendars.filter { $0.accountTitle == account }) { cal in
                            Toggle(isOn: includedBinding(cal.id)) {
                                HStack(spacing: 10) {
                                    Circle().fill(cal.color).frame(width: 12, height: 12)
                                    Text(cal.title)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: Active context

    private var contextSection: some View {
        Section("Show free time for") {
            Button {
                groups.activeGroupID = nil
            } label: {
                HStack {
                    Text("Just me").foregroundStyle(.primary)
                    Spacer()
                    if groups.activeGroupID == nil { Image(systemName: "checkmark").foregroundStyle(.color1) }
                }
            }
            ForEach(groups.groups) { group in
                HStack {
                    Button {
                        groups.activeGroupID = group.id
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(group.name).foregroundStyle(.primary)
                                Text("\(group.members.count + 1) people")
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            if groups.activeGroupID == group.id {
                                Image(systemName: "checkmark").foregroundStyle(.color1)
                            }
                        }
                    }
                    Menu {
                        ShareLink(item: InviteCodec.link(calendar.invitePayload(groupName: group.name))) {
                            Label("Share my code", systemImage: "square.and.arrow.up")
                        }
                        Button { addTarget = group; showAdd = true } label: {
                            Label("Add person by code", systemImage: "person.badge.plus")
                        }
                        Button(role: .destructive) { groups.delete(group) } label: {
                            Label("Delete group", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle").foregroundStyle(.color1)
                    }
                }
            }
        }
    }

    // MARK: Join / create

    private var joinSection: some View {
        Section("Join or create a group") {
            TextField("Paste invite code or link", text: $joinCode, axis: .vertical)
                .lineLimit(1...4)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            Button("Join group") { join() }
                .disabled(joinCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            if let joinError {
                Text(joinError).font(.footnote).foregroundStyle(.red)
            }
            TextField("New group name", text: $newName)
            Button("Create group") {
                let g = groups.createGroup(named: newName)
                groups.activeGroupID = g.id
                newName = ""
            }
            .disabled(newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }

    private var accounts: [String] {
        Array(Set(calendar.calendars.map(\.accountTitle))).sorted()
    }

    private func includedBinding(_ id: String) -> Binding<Bool> {
        Binding(get: { calendar.isIncluded(id) }, set: { calendar.setIncluded(id, $0) })
    }

    private func join() {
        if let g = groups.join(code: joinCode) {
            groups.activeGroupID = g.id
            joinCode = ""; joinError = nil
        } else {
            joinError = "That code didn't look valid. Paste the whole code or link."
        }
    }

    private func addPerson() {
        guard let addTarget else { return }
        _ = groups.addMember(code: addCode, to: addTarget)
        addCode = ""
    }
}

#Preview {
    NavigationStack { ConnectView() }
        .environment(CalendarStore())
        .environment(GroupStore())
}
