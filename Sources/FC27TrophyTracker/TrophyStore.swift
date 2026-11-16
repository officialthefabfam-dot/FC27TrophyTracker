import Foundation
import SwiftUI

@MainActor
final class TrophyStore: ObservableObject {
    @Published var trophies: [Trophy] = [] {
        didSet { save() }
    }

    private let key = "fc27-trophy-cabinet-v1"

    init() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let saved = try? JSONDecoder().decode([Trophy].self, from: data) else { return }
        trophies = saved
    }

    func add(_ trophy: Trophy) {
        trophies.insert(trophy, at: 0)
    }

    func delete(at offsets: IndexSet) {
        trophies.remove(atOffsets: offsets)
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(trophies) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}
