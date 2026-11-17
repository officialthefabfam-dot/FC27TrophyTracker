import SwiftUI
import SceneKit

private enum TrophyRoomPalette {
    static let gold = Color(red: 0.96, green: 0.73, blue: 0.30)
    static let paleGold = Color(red: 1.0, green: 0.88, blue: 0.59)
    static let bronze = Color(red: 0.48, green: 0.29, blue: 0.12)
    static let cabinetDark = Color(red: 0.12, green: 0.16, blue: 0.22)
    static let cabinetLight = Color(red: 0.84, green: 0.87, blue: 0.91)
}

struct TrophyRoomHeaderView: View {
    @EnvironmentObject private var theme: ThemeSettings
    @Environment(\.colorScheme) private var colorScheme

    private var panel: [Color] {
        colorScheme == .dark
            ? [Color(red: 0.15, green: 0.19, blue: 0.26), Color(red: 0.07, green: 0.09, blue: 0.13)]
            : [Color.white, Color(red: 0.88, green: 0.91, blue: 0.95)]
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(colors: panel, startPoint: .topLeading, endPoint: .bottomTrailing))
            Circle()
                .fill(theme.accent.opacity(0.10))
                .frame(width: 190, height: 190)
                .offset(x: 145, y: -75)
            Circle()
                .stroke(theme.accent.opacity(0.16), lineWidth: 1)
                .frame(width: 225, height: 225)
                .offset(x: 145, y: -75)
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(theme.accent.opacity(0.13))
                        .frame(width: 76, height: 88)
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 38, weight: .medium))
                        .foregroundStyle(LinearGradient(colors: [TrophyRoomPalette.paleGold, TrophyRoomPalette.gold, TrophyRoomPalette.bronze],
                                                        startPoint: .top, endPoint: .bottom))
                }
                VStack(alignment: .leading, spacing: 7) {
                    Text("FC 27 CAREER TRACKER")
                        .font(.system(size: 9, weight: .heavy))
                        .tracking(2)
                        .foregroundStyle(theme.accent)
                    Text("CAREER TROPHY ROOM")
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .tracking(0.2)
                        .minimumScaleFactor(0.72)
                        .lineLimit(2)
                        .foregroundStyle(theme.primaryText)
                    Text("YOUR CAREER • YOUR LEGACY")
                        .font(.system(size: 9, weight: .bold))
                        .tracking(1.3)
                        .foregroundStyle(theme.secondaryText)
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 18)
        }
        .frame(height: 142)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(theme.accent.opacity(0.25), lineWidth: 1))
        .shadow(color: .black.opacity(colorScheme == .dark ? 0.22 : 0.06), radius: 12, y: 6)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

struct TrophyRoomCabinetView: View {
    @EnvironmentObject private var theme: ThemeSettings
    let trophies: [Trophy]
    let onSelect: (Trophy) -> Void

    private var displayedTrophies: [Trophy] {
        Array(trophies.sorted { $0.dateWon > $1.dateWon }.prefix(12))
    }

    private var rows: [[Trophy]] {
        stride(from: 0, to: displayedTrophies.count, by: 4).map {
            Array(displayedTrophies[$0..<min($0 + 4, displayedTrophies.count)])
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("YOUR TROPHY CABINET")
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .tracking(1.1)
                    .foregroundStyle(theme.primaryText)
                Spacer()
                Text("\(trophies.count) TROPHIES")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(theme.accent)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(theme.surface, in: RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(theme.border, lineWidth: 1))

            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(LinearGradient(colors: [TrophyRoomPalette.cabinetDark,
                                                  Color(red: 0.07, green: 0.10, blue: 0.15)],
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
                HStack(spacing: 0) {
                    ForEach(0..<14, id: \.self) { index in
                        Rectangle()
                            .fill(index.isMultiple(of: 2) ? Color.white.opacity(0.025) : theme.accent.opacity(0.045))
                            .frame(width: 1)
                        Spacer(minLength: 0)
                    }
                }
                .padding(.horizontal, 7)
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        spotlight
                        Spacer()
                        spotlight
                        Spacer()
                        spotlight
                        Spacer()
                        spotlight
                    }
                    .padding(.horizontal, 28)
                    .padding(.top, 4)

                    if displayedTrophies.isEmpty {
                        VStack(spacing: 9) {
                            Image(systemName: "trophy.fill")
                                .font(.system(size: 43))
                                .foregroundStyle(TrophyRoomPalette.gold.opacity(0.8))
                            Text("YOUR FIRST TROPHY AWAITS")
                                .font(.system(size: 10, weight: .heavy))
                                .tracking(1.3)
                                .foregroundStyle(.white.opacity(0.9))
                            Text("Add your career achievements and watch your cabinet grow")
                                .font(.caption2)
                                .foregroundStyle(.white.opacity(0.62))
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 230)
                    } else {
                        ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                            HStack(alignment: .bottom, spacing: 3) {
                                ForEach(row) { trophy in
                                    Button { onSelect(trophy) } label: {
                                        VStack(spacing: 3) {
                                            TrophyCabinetOrnament(category: trophy.category, competition: trophy.competition)
                                                .frame(height: 65)
                                                .shadow(color: TrophyRoomPalette.gold.opacity(0.35), radius: 8, y: 1)
                                            Text(trophy.name)
                                                .font(.system(size: 8, weight: .heavy))
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.6)
                                                .foregroundStyle(.white)
                                            Text(trophy.season)
                                                .font(.system(size: 7, weight: .semibold))
                                                .foregroundStyle(TrophyRoomPalette.paleGold)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.horizontal, 2)
                                        .padding(.top, 8)
                                        .contentShape(Rectangle())
                                    }
                                    .buttonStyle(.plain)
                                }
                                if row.count < 4 {
                                    ForEach(0..<(4 - row.count), id: \.self) { _ in
                                        Color.clear.frame(maxWidth: .infinity)
                                    }
                                }
                            }
                            .padding(.horizontal, 9)
                            .frame(height: 94, alignment: .bottom)
                            Rectangle()
                                .fill(LinearGradient(colors: [TrophyRoomPalette.paleGold, TrophyRoomPalette.bronze,
                                                              TrophyRoomPalette.gold, TrophyRoomPalette.bronze],
                                                     startPoint: .top, endPoint: .bottom))
                                .frame(height: 8)
                                .overlay(alignment: .top) {
                                    Rectangle().fill(.white.opacity(0.35)).frame(height: 1)
                                }
                                .shadow(color: theme.accent.opacity(0.3), radius: 8, y: 3)
                                .padding(.horizontal, 3)
                        }
                    }
                    Spacer(minLength: 0)
                    Text("EVERY SEASON. EVERY VICTORY.")
                        .font(.system(size: 8, weight: .black))
                        .tracking(2)
                        .foregroundStyle(.white.opacity(0.72))
                        .padding(.vertical, 10)
                }
            }
            .frame(minHeight: displayedTrophies.isEmpty ? 275 : CGFloat(42 + rows.count * 102 + 25))
            .overlay(RoundedRectangle(cornerRadius: 15).stroke(theme.accent.opacity(0.75), lineWidth: 2))
            .overlay(RoundedRectangle(cornerRadius: 15).stroke(.white.opacity(0.12), lineWidth: 5).padding(4))
            .overlay(alignment: .leading) { cabinetPost }
            .overlay(alignment: .trailing) { cabinetPost }
            .shadow(color: .black.opacity(0.25), radius: 10, y: 8)

            HStack {
                Image(systemName: "cube.transparent")
                    .foregroundStyle(theme.accent)
                Text("Tap any trophy to inspect its 3D design")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(theme.secondaryText)
                Spacer()
            }
            .padding(.horizontal, 4)
        }
    }

    private var spotlight: some View {
        VStack(spacing: 0) {
            Circle().fill(TrophyRoomPalette.paleGold)
                .frame(width: 7, height: 7)
                .shadow(color: TrophyRoomPalette.gold, radius: 8)
            Triangle()
                .fill(LinearGradient(colors: [TrophyRoomPalette.gold.opacity(0.24), .clear],
                                     startPoint: .top, endPoint: .bottom))
                .frame(width: 43, height: 48)
        }
    }

    private var cabinetPost: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(LinearGradient(colors: [theme.accent.opacity(0.9), theme.accent, theme.accent.opacity(0.7)],
                                 startPoint: .leading, endPoint: .trailing))
            .frame(width: 7)
            .padding(.vertical, 2)
            .shadow(color: theme.accent.opacity(0.45), radius: 5)
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.closeSubpath()
        }
    }
}

private struct TrophyCabinetOrnament: View {
    let category: String
    let competition: String

    private var competitionStyle: Int {
        let name = competition.lowercased()
        if name.contains("champions") || name.contains("europe") || category == "Continental" { return 1 }
        if name.contains("cup") || category == "Domestic Cup" { return 2 }
        if category == "League" { return 3 }
        return 0
    }

    private var goldGradient: LinearGradient {
        LinearGradient(colors: [Color.white.opacity(0.95), TrophyRoomPalette.paleGold,
                                TrophyRoomPalette.gold, TrophyRoomPalette.bronze,
                                TrophyRoomPalette.paleGold],
                       startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    var body: some View {
        ZStack {
            Ellipse().stroke(TrophyRoomPalette.gold.opacity(0.9), lineWidth: 3)
                .frame(width: 19, height: 34).offset(x: -22, y: -7)
            Ellipse().stroke(TrophyRoomPalette.gold.opacity(0.9), lineWidth: 3)
                .frame(width: 19, height: 34).offset(x: 22, y: -7)
            CupBowl().fill(goldGradient)
                .frame(width: 44, height: 38).offset(y: -10)
            Ellipse().fill(goldGradient)
                .frame(width: 43, height: 7).offset(y: -28)
            Rectangle().fill(goldGradient)
                .frame(width: 11, height: 17).offset(y: 13)
            RoundedRectangle(cornerRadius: 2).fill(goldGradient)
                .frame(width: 34, height: 8).offset(y: 25)
            RoundedRectangle(cornerRadius: 2).fill(TrophyRoomPalette.bronze)
                .frame(width: 42, height: 7).offset(y: 32)
            switch competitionStyle {
            case 1:
                Image(systemName: "star.circle.fill").font(.system(size: 17))
                    .foregroundStyle(TrophyRoomPalette.paleGold).offset(y: -9)
            case 2:
                RoundedRectangle(cornerRadius: 3).stroke(TrophyRoomPalette.paleGold, lineWidth: 2)
                    .frame(width: 18, height: 23).offset(y: -9)
            case 3:
                Image(systemName: "laurel.leading").font(.system(size: 18))
                    .foregroundStyle(TrophyRoomPalette.paleGold).offset(x: -17, y: -8)
                Image(systemName: "laurel.trailing").font(.system(size: 18))
                    .foregroundStyle(TrophyRoomPalette.paleGold).offset(x: 17, y: -8)
            default:
                EmptyView()
            }
        }
        .frame(maxWidth: .infinity)
    }
}

private struct CupBowl: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.width * 0.08, y: rect.height * 0.08))
        path.addQuadCurve(to: CGPoint(x: rect.width * 0.92, y: rect.height * 0.08),
                          control: CGPoint(x: rect.midX, y: rect.height * 0.2))
        path.addLine(to: CGPoint(x: rect.width * 0.76, y: rect.height * 0.82))
        path.addQuadCurve(to: CGPoint(x: rect.width * 0.24, y: rect.height * 0.82),
                          control: CGPoint(x: rect.midX, y: rect.height))
        path.closeSubpath()
        return path
    }
}

struct Trophy3DView: View {
    let competition: String
    let category: String

    var body: some View {
        SceneView(scene: DetailedTrophyScene.makeScene(competition: competition, category: category),
                  options: [.allowsCameraControl, .autoenablesDefaultLighting])
            .background(Color.clear)
            .accessibilityLabel("Interactive competition-specific 3D football trophy. Drag to rotate.")
    }
}
