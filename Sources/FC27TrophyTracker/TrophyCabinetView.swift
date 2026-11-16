import SwiftUI

struct TrophyCabinetView: View {
    @EnvironmentObject private var store: TrophyStore
    @State private var showingAdd = false
    @State private var search = ""
    @State private var selectedCategory = "All"

    private let categories = ["All", "League", "Domestic Cup", "Continental", "Other"]
    private var filtered: [Trophy] {
        store.trophies.filter {
            (selectedCategory == "All" || $0.category == selectedCategory) &&
            (search.isEmpty || [$0.name, $0.competition, $0.club, $0.season]
                .joined(separator: " ").localizedCaseInsensitiveContains(search))
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [Color(red: 0.07, green: 0.08, blue: 0.10), .black],
                               startPoint: .top, endPoint: .bottom).ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 22) {
                        header
                        HStack(spacing: 12) {
                            statCard("TROPHIES", value: "\(store.trophies.count)", symbol: "trophy.fill")
                            statCard("SEASONS", value: "\(Set(store.trophies.map(\.season)).count)", symbol: "calendar")
                            statCard("CUPS", value: "\(store.trophies.filter { $0.category != "League" }.count)", symbol: "medal.fill")
                        }
                        Picker("Category", selection: $selectedCategory) {
                            ForEach(categories, id: \.self) { Text($0) }
                        }.pickerStyle(.segmented)
                        if filtered.isEmpty {
                            ContentUnavailableView("No trophies yet", systemImage: "trophy",
                                description: Text("Add your first career achievement to start filling the cabinet."))
                                .padding(.top, 25)
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(filtered) { trophy in trophyRow(trophy) }
                                    .onDelete(perform: store.delete)
                            }
                        }
                    }.padding()
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAdd) { AddTrophyView().environmentObject(store) }
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "trophy.fill").font(.system(size: 25)).foregroundStyle(Color.yellow)
                Text("FC 27").font(.system(size: 14, weight: .black, design: .rounded)).tracking(3).foregroundStyle(.white.opacity(0.7))
                Spacer()
                Button { showingAdd = true } label: {
                    Label("Add trophy", systemImage: "plus").font(.subheadline.bold())
                        .padding(.horizontal, 14).padding(.vertical, 10)
                        .background(Color.yellow, in: Capsule()).foregroundStyle(.black)
                }
            }
            Text("TROPHY CABINET").font(.system(size: 28, weight: .black, design: .rounded))
                .tracking(2).foregroundStyle(.white)
            Text("MANAGER CAREER • YOUR LEGACY").font(.caption2.bold()).tracking(2)
                .foregroundStyle(Color.yellow.opacity(0.8))
            Image(systemName: "trophy.fill").font(.system(size: 76)).foregroundStyle(
                LinearGradient(colors: [.yellow, Color(red: 0.65, green: 0.38, blue: 0.08)], startPoint: .top, endPoint: .bottom))
                .shadow(color: .yellow.opacity(0.22), radius: 18)
                .padding(.top, 8)
        }.padding(.vertical, 12)
    }

    private func statCard(_ title: String, value: String, symbol: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: symbol).foregroundStyle(.yellow)
            Text(value).font(.title2.bold()).foregroundStyle(.white)
            Text(title).font(.system(size: 9, weight: .bold)).tracking(1).foregroundStyle(.white.opacity(0.55))
        }.frame(maxWidth: .infinity).padding(.vertical, 15)
            .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(.yellow.opacity(0.2), lineWidth: 1))
    }

    private func trophyRow(_ trophy: Trophy) -> some View {
        HStack(spacing: 14) {
            Image(systemName: "trophy.fill").font(.title2).foregroundStyle(.yellow)
                .frame(width: 48, height: 58).background(.yellow.opacity(0.10), in: RoundedRectangle(cornerRadius: 10))
            VStack(alignment: .leading, spacing: 4) {
                Text(trophy.name).font(.headline).foregroundStyle(.white)
                Text("\(trophy.competition) • \(trophy.season)").font(.subheadline).foregroundStyle(.white.opacity(0.65))
                Text(trophy.club).font(.caption).foregroundStyle(.yellow.opacity(0.85))
            }
            Spacer()
            Text(trophy.category.uppercased()).font(.system(size: 8, weight: .bold))
                .foregroundStyle(.white.opacity(0.6)).multilineTextAlignment(.trailing)
        }.padding(12).background(.white.opacity(0.055), in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(.white.opacity(0.08), lineWidth: 1))
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
                            competition: competition, season: season, club: club,
                            category: category, dateWon: dateWon, notes: notes))
                        dismiss()
                    }.disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || competition.isEmpty)
                }
            }
        }
    }
}
