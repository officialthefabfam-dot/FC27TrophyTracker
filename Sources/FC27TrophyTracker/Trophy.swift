import Foundation

struct Trophy: Identifiable, Codable {
    var id = UUID()
    var name: String
    var competition: String
    var season: String
    var club: String
    var category: String
    var dateWon: Date
    var notes: String
}
