import Foundation
import SwiftUI

@MainActor
final class TrophyStore: ObservableObject {
    @Published var trophies: [Trophy] = [] {
        didSet { save() }
    }
    @Published var seasons: [SeasonRecord] = [] {
        didSet { save() }
    }

    private let trophiesKey = "fc27-trophy-cabinet-v1"
    private let seasonsKey = "fc27-season-records-v1"

    init() {
        if let data = UserDefaults.standard.data(forKey: trophiesKey),
           let saved = try? JSONDecoder().decode([Trophy].self, from: data) {
            trophies = saved
        }
        if let data = UserDefaults.standard.data(forKey: seasonsKey),
           let saved = try? JSONDecoder().decode([SeasonRecord].self, from: data) {
            seasons = saved
        }
    }

    func add(_ trophy: Trophy) {
        trophies.insert(trophy, at: 0)
    }

    func add(_ season: SeasonRecord) {
        seasons.removeAll { $0.season.caseInsensitiveCompare(season.season) == .orderedSame &&
            $0.league.caseInsensitiveCompare(season.league) == .orderedSame }
        seasons.insert(season, at: 0)
    }

    func deleteTrophy(_ trophy: Trophy) {
        trophies.removeAll { $0.id == trophy.id }
    }

    func deleteSeason(_ season: SeasonRecord) {
        seasons.removeAll { $0.id == season.id }
    }

    func backupData() -> Data {
        let backup = TrophyBackup(trophies: trophies, seasons: seasons)
        return (try? JSONEncoder().encode(backup)) ?? Data()
    }

    func restore(from data: Data) throws {
        let decoder = JSONDecoder()
        if let backup = try? decoder.decode(TrophyBackup.self, from: data) {
            trophies = backup.trophies
            seasons = backup.seasons
        } else {
            // Also accept older backups containing only a trophy array.
            trophies = try decoder.decode([Trophy].self, from: data)
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(trophies) {
            UserDefaults.standard.set(data, forKey: trophiesKey)
        }
        if let data = try? JSONEncoder().encode(seasons) {
            UserDefaults.standard.set(data, forKey: seasonsKey)
        }
    }
}
