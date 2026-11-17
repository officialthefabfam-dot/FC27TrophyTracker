import Foundation

struct Trophy: Identifiable, Codable {
    var id: UUID
    var name: String
    var competition: String
    var season: String
    var club: String
    var category: String
    var dateWon: Date
    var notes: String

    init(id: UUID = UUID(), name: String, competition: String, season: String,
         club: String, category: String, dateWon: Date = Date(), notes: String = "") {
        self.id = id
        self.name = name
        self.competition = competition
        self.season = season
        self.club = club
        self.category = category
        self.dateWon = dateWon
        self.notes = notes
    }

    private enum CodingKeys: String, CodingKey {
        case id, name, competition, season, club, category, dateWon, notes
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name = try values.decode(String.self, forKey: .name)
        competition = try values.decode(String.self, forKey: .competition)
        season = try values.decode(String.self, forKey: .season)
        club = try values.decode(String.self, forKey: .club)
        category = try values.decodeIfPresent(String.self, forKey: .category) ?? "Other"
        dateWon = try values.decodeIfPresent(Date.self, forKey: .dateWon) ?? Date()
        notes = try values.decodeIfPresent(String.self, forKey: .notes) ?? ""
    }
}

struct SeasonRecord: Identifiable, Codable {
    var id: UUID
    var season: String
    var league: String
    var club: String
    var topScorerName: String
    var topScorerClub: String
    var topScorerGoals: Int
    var playerOfSeasonName: String
    var playerOfSeasonClub: String

    init(id: UUID = UUID(), season: String, league: String, club: String,
         topScorerName: String, topScorerClub: String, topScorerGoals: Int,
         playerOfSeasonName: String = "", playerOfSeasonClub: String = "") {
        self.id = id
        self.season = season
        self.league = league
        self.club = club
        self.topScorerName = topScorerName
        self.topScorerClub = topScorerClub
        self.topScorerGoals = topScorerGoals
        self.playerOfSeasonName = playerOfSeasonName
        self.playerOfSeasonClub = playerOfSeasonClub
    }

    private enum CodingKeys: String, CodingKey {
        case id, season, league, club, topScorerName, topScorerClub, topScorerGoals
        case playerOfSeasonName, playerOfSeasonClub
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        season = try values.decode(String.self, forKey: .season)
        league = try values.decodeIfPresent(String.self, forKey: .league) ?? ""
        club = try values.decodeIfPresent(String.self, forKey: .club) ?? ""
        topScorerName = try values.decodeIfPresent(String.self, forKey: .topScorerName) ?? ""
        topScorerClub = try values.decodeIfPresent(String.self, forKey: .topScorerClub) ?? ""
        topScorerGoals = try values.decodeIfPresent(Int.self, forKey: .topScorerGoals) ?? 0
        playerOfSeasonName = try values.decodeIfPresent(String.self, forKey: .playerOfSeasonName) ?? ""
        playerOfSeasonClub = try values.decodeIfPresent(String.self, forKey: .playerOfSeasonClub) ?? ""
    }
}

struct TrophyBackup: Codable {
    var trophies: [Trophy]
    var seasons: [SeasonRecord]
}
