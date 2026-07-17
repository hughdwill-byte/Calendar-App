//
//  GroupStore.swift
//  Apple App
//
//  Offline groups: you join by pasting an invite code/link that carries a
//  person's shared free/busy. Members are persisted locally (UserDefaults);
//  combined free time is computed on the fly from your live calendar + members.
//

import SwiftUI

struct Group: Codable, Identifiable, Hashable {
    var id = UUID()
    var name: String
    var members: [GroupMember] = []   // other people (you are added at compute time)
}

@MainActor @Observable
final class GroupStore {
    var groups: [Group] = []
    private let key = "groups.v1"
    private let activeKey = "activeGroupID"

    // Which group the Home screen shows combined free time for (nil = just you).
    var activeGroupID: UUID? {
        didSet {
            if let id = activeGroupID { UserDefaults.standard.set(id.uuidString, forKey: activeKey) }
            else { UserDefaults.standard.removeObject(forKey: activeKey) }
        }
    }
    var activeGroup: Group? {
        guard let id = activeGroupID else { return nil }
        return groups.first { $0.id == id }
    }

    init() {
        loadGroups()
        if let s = UserDefaults.standard.string(forKey: activeKey), let id = UUID(uuidString: s),
           groups.contains(where: { $0.id == id }) {
            activeGroupID = id
        }
    }

    private func loadGroups() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let g = try? JSONDecoder().decode([Group].self, from: data) else { return }
        groups = g
    }

    private func save() {
        if let data = try? JSONEncoder().encode(groups) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func group(id: UUID) -> Group? { groups.first { $0.id == id } }

    @discardableResult
    func createGroup(named name: String) -> Group {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let g = Group(name: trimmed.isEmpty ? "New Group" : trimmed)
        groups.append(g); save(); return g
    }

    func delete(_ group: Group) {
        groups.removeAll { $0.id == group.id }
        if activeGroupID == group.id { activeGroupID = nil }
        save()
    }

    /// Join from a pasted code/link. Merges the sharer into a group named in
    /// the payload (created if new). Returns the joined group, or nil if invalid.
    @discardableResult
    func join(code: String) -> Group? {
        guard let payload = InviteCodec.decode(code) else { return nil }
        let idx = groups.firstIndex { $0.name.caseInsensitiveCompare(payload.group) == .orderedSame }
        if let idx {
            addOrReplace(payload.member, at: idx)
        } else {
            var g = Group(name: payload.group)
            g.members.append(payload.member)
            groups.append(g)
        }
        save()
        return groups.first { $0.name.caseInsensitiveCompare(payload.group) == .orderedSame }
    }

    /// Add a person to a specific existing group from a pasted code.
    @discardableResult
    func addMember(code: String, to group: Group) -> Bool {
        guard let payload = InviteCodec.decode(code),
              let idx = groups.firstIndex(where: { $0.id == group.id }) else { return false }
        addOrReplace(payload.member, at: idx)
        save(); return true
    }

    func removeMember(_ member: GroupMember, from group: Group) {
        guard let idx = groups.firstIndex(where: { $0.id == group.id }) else { return }
        groups[idx].members.removeAll { $0.name.caseInsensitiveCompare(member.name) == .orderedSame }
        save()
    }

    // Dedupe people by name so re-pasting an updated code refreshes their times.
    private func addOrReplace(_ member: GroupMember, at idx: Int) {
        groups[idx].members.removeAll { $0.name.caseInsensitiveCompare(member.name) == .orderedSame }
        groups[idx].members.append(member)
    }
}
