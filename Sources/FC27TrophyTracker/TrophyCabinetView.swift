import SwiftUI
import UniformTypeIdentifiers

private extension Color {
    static let lfcRed = Color(red: 0.78, green: 0.015, blue: 0.075)
    static let lfcGold = Color(red: 0.96, green: 0.72, blue: 0.24)
}

struct TrophyCabinetView: View {
    private enum ActiveSheet: Identifiable {
        case addTrophy, addSeason, settings, trophy(Trophy)
        var id: String {
            switch self {
            case .addTrophy: return "addTrophy"
            case .addSeason: return "addSeason"
            case .settings: return "settings"
            case .trophy(let trophy): return "trophy-" + String(describing: trophy.id)
            }
        }
    }
    @EnvironmentObject private var store: TrophyStore
    @EnvironmentObject private var theme: ThemeSettings
    @State private var activeSheet: ActiveSheet?
    @State private var showingQuickActions = false
    @State private var search = ""
    @State private var selectedCategory = "All"
    @State private var showingImporter = false
    @State private var showingRestoreError = false
    @State private var restoreError = ""

    private let categories = ["All", "League", "Domestic Cup", "Continental", "Other"]
    private var filtered: [Trophy] {
        store.trophies.filter {
            (selectedCategory == "All" || $0.category == selectedCategory) &&
            (search.isEmpty || [$0.name, $0.competition, $0.club, $0.season]
                .joined(separator: " ").localizedCaseInsensitiveContains(search))
        }
    }
    private var topSeason: SeasonRecord? {
        store.seasons.max { $0.topScorerGoals < $1.topScorerGoals }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                theme.background.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 22) {
                        header
                        stats
                        visualCabinet
                        careerRecords
                        seasonHistory
                        trophyCollection
                    }.padding()
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(item: $activeSheet) { destination in
                switch destination {
                case .addTrophy: AddTrophyView().environmentObject(store)
                case .addSeason: AddSeasonRecordView().environmentObject(store)
                case .settings: ThemeSettingsView().environmentObject(theme)
                case .trophy(let trophy): TrophyDetailView(trophy: trophy).environmentObject(theme)
                }
            }
            .confirmationDialog("Add to your career", isPresented: $showingQuickActions, titleVisibility: .visible) {
                Button("Add trophy") { activeSheet = .addTrophy }
                Button("Add season record") { activeSheet = .addSeason }
                ShareLink(item: store.backupData(), preview: SharePreview("FC 27 Trophy Tracker backup")) {
                    Label("Export backup", systemImage: "square.and.arrow.up")
                }
                Button("Restore backup") { showingImporter = true }
                Button("Cancel", role: .cancel) {}
            }
            .fileImporter(isPresented: $showingImporter, allowedContentTypes: [.json]) { result in
                do {
                    let url = try result.get()
                    let access = url.startAccessingSecurityScopedResource()
                    defer { if access { url.stopAccessingSecurityScopedResource() } }
                    try store.restore(from: Data(contentsOf: url))
                } catch {
                    restoreError = error.localizedDescription
                    showingRestoreError = true
                }
            }
            .alert("Couldn't restore backup", isPresented: $showingRestoreError) {
                Button("OK", role: .cancel) {}
            } message: { Text(restoreError) }
        }
    }

    private var header: some View {
        VStack(spacing: 10) {
            HStack {
                Label("FC 27", systemImage: "trophy.fill")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .tracking(3).foregroundStyle(theme.accent)
                Spacer()
                Button { activeSheet = .settings } label: {
                    Image(systemName: "slider.horizontal.3")
                        .font(.title3).foregroundStyle(theme.accent)
                        .frame(width: 44, height: 44).contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Personalise appearance")
                Button { showingQuickActions = true } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2).foregroundStyle(theme.accent)
                        .frame(width: 44, height: 44).contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Add to career")
            }
            TrophyRoomHeaderView()
        }.padding(.vertical, 8)
    }

    private var visualCabinet: some View {
        TrophyRoomCabinetView(trophies: store.trophies) { trophy in
            activeSheet = .trophy(trophy)
        }
    }

    private var stats: some View {
        HStack(spacing: 10) {
            statCard("TROPHIES", value: "\(store.trophies.count)", symbol: "trophy.fill")
            statCard("SEASONS", value: "\(Set(store.trophies.map(\.season).filter { !$0.isEmpty }).union(store.seasons.map(\.season)).count)", symbol: "calendar")
            statCard("LEAGUE TITLES", value: "\(store.trophies.filter { $0.category == "League" }.count)", symbol: "medal.fill")
        }
    }

    private var careerRecords: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeading("CAREER RECORDS", symbol: "chart.bar.fill")
            HStack(spacing: 10) {
                recordTile("Top scorer", value: topSeason?.topScorerName ?? "Not added",
                           detail: topSeason.map { "\($0.topScorerGoals) goals • \($0.season)" } ?? "Add a season record",
                           symbol: "crown.fill")
                recordTile("Most decorated season",
                           value: mostDecoratedSeason?.season ?? "—",
                           detail: mostDecoratedSeason.map { "\($0.value) trophies won" } ?? "Add trophies",
                           symbol: "star.fill")
            }
        }
    }

    private var mostDecoratedSeason: (season: String, value: Int)? {
        let counts = Dictionary(grouping: store.trophies, by: \.season).mapValues(\.count)
        return counts.max(by: { $0.value < $1.value }).map { (season: $0.key, value: $0.value) }
    }

    private var seasonHistory: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                sectionHeading("SEASON HISTORY", symbol: "clock.arrow.circlepath")
                Spacer()
                Button { activeSheet = .addSeason } label: {
                    Image(systemName: "plus").font(.caption.bold()).foregroundStyle(theme.primaryText)
                        .padding(8).background(theme.accent, in: Circle())
                }
            }
            if store.seasons.isEmpty {
                emptyHint("Record each season's league, Golden Boot winner and Player of the Season here.")
            } else {
                ForEach(store.seasons.sorted { $0.season > $1.season }) { record in
                    HStack(spacing: 12) {
                        Image(systemName: "calendar").foregroundStyle(theme.accent)
                            .frame(width: 38, height: 42).background(theme.accent.opacity(0.10), in: RoundedRectangle(cornerRadius: 9))
                        VStack(alignment: .leading, spacing: 3) {
                            Text(record.season).font(.headline).foregroundStyle(theme.primaryText)
                            Text(record.league).font(.caption).foregroundStyle(theme.secondaryText)
                            Text("Champions: \(record.club.isEmpty ? "Not recorded" : record.club)")
                                .font(.caption2).foregroundStyle(theme.accent.opacity(0.85))
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 3) {
                            Text("GOLDEN BOOT").font(.system(size: 8, weight: .heavy)).tracking(1).foregroundStyle(theme.accent)
                            Text(record.topScorerName).font(.subheadline.bold()).foregroundStyle(theme.primaryText)
                            Text("\(record.topScorerGoals) goals • \(record.topScorerClub)")
                                .font(.caption2).foregroundStyle(theme.secondaryText)
                            if !record.playerOfSeasonName.isEmpty {
                                Text("PLAYER OF THE SEASON").font(.system(size: 8, weight: .heavy))
                                    .tracking(0.8).foregroundStyle(theme.accent)
                                    .padding(.top, 5)
                                Text(record.playerOfSeasonName).font(.subheadline.bold()).foregroundStyle(theme.primaryText)
                                if !record.playerOfSeasonClub.isEmpty {
                                    Text(record.playerOfSeasonClub).font(.caption2).foregroundStyle(theme.secondaryText)
                                }
                            }
                        }
                    }.padding(12).background(theme.surface, in: RoundedRectangle(cornerRadius: 13))
                        .contextMenu {
                            Button(role: .destructive) { store.deleteSeason(record) } label: {
                                Label("Delete season", systemImage: "trash")
                            }
                        }
                }
            }
        }
    }

    private var trophyCollection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeading("SILVERWARE COLLECTION", symbol: "trophy.fill")
            TextField("Search trophies", text: $search)
                .textFieldStyle(.roundedBorder)
            Picker("Category", selection: $selectedCategory) {
                ForEach(categories, id: \.self) { Text($0) }
            }.pickerStyle(.segmented)
            if filtered.isEmpty {
                emptyHint("Add your first career achievement to start filling the cabinet.")
            } else {
                LazyVStack(spacing: 10) {
                    ForEach(filtered) { trophy in
                        Button { activeSheet = .trophy(trophy) } label: { trophyRow(trophy) }
                            .buttonStyle(.plain)
                            .contextMenu {
                                Button(role: .destructive) { store.deleteTrophy(trophy) } label: {
                                    Label("Delete trophy", systemImage: "trash")
                                }
                            }
                    }
                }
            }
        }
    }

    private func sectionHeading(_ title: String, symbol: String) -> some View {
        Label(title, systemImage: symbol).font(.system(size: 12, weight: .heavy))
            .tracking(1.4).foregroundStyle(theme.accent)
    }

    private func statCard(_ title: String, value: String, symbol: String) -> some View {
        VStack(spacing: 7) {
            Image(systemName: symbol).foregroundStyle(theme.accent)
            Text(value).font(.title2.bold()).foregroundStyle(theme.primaryText)
            Text(title).font(.system(size: 8, weight: .bold)).tracking(0.6)
                .foregroundStyle(theme.secondaryText).lineLimit(1).minimumScaleFactor(0.7)
        }.frame(maxWidth: .infinity).padding(.vertical, 14)
            .background(theme.surface, in: RoundedRectangle(cornerRadius: 13))
            .overlay(RoundedRectangle(cornerRadius: 13).stroke(theme.accent.opacity(0.22), lineWidth: 1))
    }

    private func recordTile(_ title: String, value: String, detail: String, symbol: String) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Image(systemName: symbol).foregroundStyle(theme.accent)
            Text(title.uppercased()).font(.system(size: 8, weight: .heavy)).tracking(0.7)
                .foregroundStyle(theme.secondaryText)
            Text(value).font(.headline).foregroundStyle(theme.primaryText).lineLimit(1).minimumScaleFactor(0.7)
            Text(detail).font(.caption2).foregroundStyle(theme.accent.opacity(0.8)).lineLimit(2)
        }.frame(maxWidth: .infinity, alignment: .leading).padding(12)
            .background(theme.surface, in: RoundedRectangle(cornerRadius: 13))
    }

    private func emptyHint(_ message: String) -> some View {
        Text(message).font(.subheadline).foregroundStyle(theme.secondaryText)
            .frame(maxWidth: .infinity).padding(20)
            .background(theme.surface, in: RoundedRectangle(cornerRadius: 13))
    }

    private func trophyRow(_ trophy: Trophy) -> some View {
        HStack(spacing: 13) {
            Image(systemName: "trophy.fill").font(.title2).foregroundStyle(theme.accent)
                .frame(width: 46, height: 54).background(theme.accent.opacity(0.10), in: RoundedRectangle(cornerRadius: 10))
            VStack(alignment: .leading, spacing: 4) {
                Text(trophy.name).font(.headline).foregroundStyle(theme.primaryText)
                Text("\(trophy.competition) • \(trophy.season)").font(.subheadline).foregroundStyle(theme.secondaryText)
                Text(trophy.club).font(.caption).foregroundStyle(theme.accent.opacity(0.85))
            }
            Spacer()
            Image(systemName: "chevron.right").font(.caption.bold()).foregroundStyle(theme.secondaryText)
        }.padding(11).background(theme.surface, in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(theme.border, lineWidth: 1))
    }
}

struct AddTrophyView: View {
    @EnvironmentObject private var store: TrophyStore
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var competition = ""
    @State private var season = "2026/27"
    @State private var club = ""
    @State private var category = "League"
    @State private var dateWon = Date()
    @State private var notes = ""
    private let categories = ["League", "Domestic Cup", "Continental", "Other"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Achievement") {
                    TextField("Trophy name", text: $name)
                    TextField("Competition", text: $competition)
                    TextField("Season (e.g. 2026/27)", text: $season)
                    TextField("Club", text: $club)
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { Text($0) }
                    }
                    DatePicker("Date won", selection: $dateWon, displayedComponents: .date)
                }
                Section("Notes") { TextField("Optional notes", text: $notes, axis: .vertical) }
            }
            .navigationTitle("Add Trophy")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.add(Trophy(name: name.trimmingCharacters(in: .whitespaces),
                            competition: competition.trimmingCharacters(in: .whitespaces),
                            season: season, club: club, category: category, dateWon: dateWon, notes: notes))
                        dismiss()
                    }.disabled(name.trimmingCharacters(in: .whitespaces).isEmpty ||
                               competition.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

struct AddSeasonRecordView: View {
    @EnvironmentObject private var store: TrophyStore
    @Environment(\.dismiss) private var dismiss
    @State private var season = "2026/27"
    @State private var league = ""
    @State private var champions = ""
    @State private var scorer = ""
    @State private var scorerClub = ""
    @State private var goals = ""
    @State private var playerOfSeason = ""
    @State private var playerOfSeasonClub = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Season") {
                    TextField("Season (e.g. 2026/27)", text: $season)
                    TextField("League", text: $league)
                    TextField("League champions (optional)", text: $champions)
                }
                Section("League top scorer / Golden Boot") {
                    TextField("Player name", text: $scorer)
                    TextField("Player's club", text: $scorerClub)
                    TextField("Goals scored", text: $goals).keyboardType(.numberPad)
                }
                Section("Player of the Season") {
                    TextField("Award winner", text: $playerOfSeason)
                    TextField("Player's club", text: $playerOfSeasonClub)
                }
            }
            .navigationTitle("Season Record")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.add(SeasonRecord(season: season, league: league, club: champions,
                            topScorerName: scorer, topScorerClub: scorerClub,
                            topScorerGoals: Int(goals) ?? 0,
                            playerOfSeasonName: playerOfSeason,
                            playerOfSeasonClub: playerOfSeasonClub))
                        dismiss()
                    }.disabled(season.trimmingCharacters(in: .whitespaces).isEmpty ||
                               league.trimmingCharacters(in: .whitespaces).isEmpty ||
                               scorer.trimmingCharacters(in: .whitespaces).isEmpty ||
                               Int(goals) == nil)
                }
            }
        }
    }
}

struct TrophyDetailView: View {
    let trophy: Trophy
    @EnvironmentObject private var theme: ThemeSettings
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                theme.background.ignoresSafeArea()
                VStack(spacing: 18) {
                    Trophy3DView(competition: trophy.competition, category: trophy.category)
                        .frame(height: 245)
                        .padding(.horizontal, -8)
                    Text("DRAG TO ROTATE")
                        .font(.system(size: 9, weight: .heavy))
                        .tracking(2)
                        .foregroundStyle(theme.accent.opacity(0.7))
                    Text(trophy.name.uppercased()).font(.title2.weight(.black)).multilineTextAlignment(.center)
                        .foregroundStyle(theme.primaryText)
                    detailLine("Competition", trophy.competition)
                    detailLine("Season", trophy.season)
                    detailLine("Club", trophy.club)
                    detailLine("Category", trophy.category)
                    detailLine("Date won", trophy.dateWon.formatted(date: .long, time: .omitted))
                    if !trophy.notes.isEmpty { detailLine("Notes", trophy.notes) }
                    Spacer()
                }.padding(24)
            }
            .navigationTitle("Trophy details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } }
        }
    }

    private func detailLine(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title).foregroundStyle(theme.secondaryText)
            Spacer()
            Text(value).bold().foregroundStyle(theme.primaryText).multilineTextAlignment(.trailing)
        }.padding(.vertical, 5)
    }
}
