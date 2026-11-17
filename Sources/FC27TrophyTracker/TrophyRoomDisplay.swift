import SwiftUI
import SceneKit

private enum TrophyRoomPalette {
    static let red = Color(red: 0.16, green: 0.19, blue: 0.25)
    static let deepRed = Color(red: 0.045, green: 0.055, blue: 0.075)
    static let gold = Color(red: 0.82, green: 0.72, blue: 0.52)
    static let paleGold = Color(red: 0.94, green: 0.88, blue: 0.72)
    static let bronze = Color(red: 0.42, green: 0.36, blue: 0.25)
    static let wood = Color(red: 0.10, green: 0.12, blue: 0.16)
}

struct TrophyRoomHeaderView: View {
    var body: some View {
        VStack(spacing: 7) {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(LinearGradient(colors: [TrophyRoomPalette.deepRed, TrophyRoomPalette.red, .black],
                                         startPoint: .top, endPoint: .bottom))
                StadiumRoofShape()
                    .stroke(TrophyRoomPalette.gold.opacity(0.3), lineWidth: 2)
                    .padding(.horizontal, 3)
                    .padding(.top, 8)
                HStack {
                    ForEach(0..<7, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(TrophyRoomPalette.paleGold.opacity(0.8))
                            .frame(width: 3, height: 12)
                            .shadow(color: TrophyRoomPalette.gold, radius: 6)
                    }
                    Spacer()
                    ForEach(0..<7, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(TrophyRoomPalette.paleGold.opacity(0.8))
                            .frame(width: 3, height: 12)
                            .shadow(color: TrophyRoomPalette.gold, radius: 6)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)
                VStack(spacing: 4) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 37))
                        .foregroundStyle(LinearGradient(colors: [TrophyRoomPalette.paleGold, TrophyRoomPalette.gold, TrophyRoomPalette.bronze],
                                                        startPoint: .top, endPoint: .bottom))
                        .shadow(color: TrophyRoomPalette.gold.opacity(0.6), radius: 10)
                    Text("CAREER LEGACY")
                        .font(.system(size: 17, weight: .black, design: .serif))
                        .tracking(4)
                        .foregroundStyle(TrophyRoomPalette.paleGold)
                    Text("TROPHY ROOM")
                        .font(.system(size: 31, weight: .black, design: .serif))
                        .tracking(1.2)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                        .foregroundStyle(LinearGradient(colors: [.white, TrophyRoomPalette.paleGold, TrophyRoomPalette.gold],
                                                        startPoint: .top, endPoint: .bottom))
                        .shadow(color: .black.opacity(0.8), radius: 5, y: 3)
                    Rectangle().fill(TrophyRoomPalette.gold.opacity(0.75)).frame(height: 1)
                        .padding(.horizontal, 26)
                    Text("EVERY TROPHY TELLS A STORY")
                        .font(.system(size: 9, weight: .heavy))
                        .tracking(1.7)
                        .minimumScaleFactor(0.65)
                        .lineLimit(1)
                        .foregroundStyle(TrophyRoomPalette.paleGold)
                }
                .padding(.top, 14)
                .padding(.bottom, 15)
            }
            .frame(height: 190)
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(TrophyRoomPalette.gold.opacity(0.65), lineWidth: 1.5))
            .shadow(color: .black.opacity(0.45), radius: 12, y: 7)
        }
    }
}

private struct StadiumRoofShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.height * 0.62))
        path.addQuadCurve(to: CGPoint(x: rect.width * 0.5, y: rect.height * 0.08),
                          control: CGPoint(x: rect.width * 0.2, y: rect.height * 0.02))
        path.addQuadCurve(to: CGPoint(x: rect.width, y: rect.height * 0.62),
                          control: CGPoint(x: rect.width * 0.8, y: rect.height * 0.02))
        path.move(to: CGPoint(x: 0, y: rect.height * 0.7))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height * 0.7))
        return path
    }
}

struct TrophyRoomCabinetView: View {
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
        VStack(alignment: .leading, spacing: 9) {
            HStack {
                Text("THE TROPHY CABINET")
                    .font(.system(size: 15, weight: .black, design: .serif))
                    .foregroundStyle(TrophyRoomPalette.paleGold)
                Spacer()
                Text("\(trophies.count) TROPHIES")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(TrophyRoomPalette.paleGold)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .background(LinearGradient(colors: [TrophyRoomPalette.red, TrophyRoomPalette.deepRed],
                                       startPoint: .leading, endPoint: .trailing),
                        in: RoundedRectangle(cornerRadius: 9))
            .overlay(RoundedRectangle(cornerRadius: 9).stroke(TrophyRoomPalette.gold, lineWidth: 1))

            ZStack {
                RoundedRectangle(cornerRadius: 13)
                    .fill(LinearGradient(colors: [Color(red: 0.15, green: 0.17, blue: 0.21),
                                                  TrophyRoomPalette.wood, Color(red: 0.045, green: 0.055, blue: 0.075)],
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
                HStack(spacing: 0) {
                    ForEach(0..<14, id: \.self) { index in
                        Rectangle()
                            .fill((index.isMultiple(of: 2) ? Color.black : TrophyRoomPalette.gold.opacity(0.08)))
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
                                .foregroundStyle(TrophyRoomPalette.gold.opacity(0.7))
                            Text("YOUR FIRST TROPHY AWAITS")
                                .font(.system(size: 10, weight: .heavy))
                                .tracking(1.3)
                                .foregroundStyle(.white.opacity(0.85))
                            Text("Win silverware and it will take pride of place here")
                                .font(.caption2)
                                .foregroundStyle(.white.opacity(0.6))
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
                                                .shadow(color: TrophyRoomPalette.gold.opacity(0.4), radius: 8, y: 1)
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
                                .shadow(color: TrophyRoomPalette.gold.opacity(0.55), radius: 8, y: 3)
                                .padding(.horizontal, 3)
                        }
                    }
                    Spacer(minLength: 0)
                    Text("YOUR CAREER • YOUR LEGACY")
                        .font(.system(size: 8, weight: .black))
                        .tracking(2.2)
                        .foregroundStyle(TrophyRoomPalette.paleGold)
                        .padding(.vertical, 10)
                }
            }
            .frame(minHeight: displayedTrophies.isEmpty ? 275 : CGFloat(42 + rows.count * 102 + 25))
            .overlay(RoundedRectangle(cornerRadius: 13).stroke(TrophyRoomPalette.gold, lineWidth: 2))
            .overlay(RoundedRectangle(cornerRadius: 13).stroke(TrophyRoomPalette.paleGold.opacity(0.25), lineWidth: 5).padding(4))
            .overlay(alignment: .leading) { cabinetPost }
            .overlay(alignment: .trailing) { cabinetPost }
            .shadow(color: .black.opacity(0.55), radius: 10, y: 8)

            HStack {
                Image(systemName: "cube.transparent")
                    .foregroundStyle(TrophyRoomPalette.gold)
                Text("Tap any trophy to inspect it in 3D")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(TrophyRoomPalette.paleGold)
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
            .fill(LinearGradient(colors: [TrophyRoomPalette.paleGold, TrophyRoomPalette.bronze,
                                          TrophyRoomPalette.gold, TrophyRoomPalette.bronze],
                                 startPoint: .leading, endPoint: .trailing))
            .frame(width: 7)
            .padding(.vertical, 2)
            .shadow(color: TrophyRoomPalette.gold.opacity(0.5), radius: 5)
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
