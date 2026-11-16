import SwiftUI
import SceneKit

private enum TrophyRoomPalette {
    static let red = Color(red: 0.42, green: 0.012, blue: 0.045)
    static let darkRed = Color(red: 0.12, green: 0.008, blue: 0.025)
    static let gold = Color(red: 0.96, green: 0.72, blue: 0.24)
    static let bronze = Color(red: 0.62, green: 0.34, blue: 0.10)
}

struct TrophyRoomCabinetView: View {
    let trophies: [Trophy]
    let onSelect: (Trophy) -> Void

    private var displayedTrophies: [Trophy] {
        Array(trophies.sorted { $0.dateWon > $1.dateWon }.prefix(12))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("THE TROPHY CABINET", systemImage: "trophy.fill")
                    .font(.system(size: 12, weight: .heavy))
                    .tracking(1.3)
                    .foregroundStyle(TrophyRoomPalette.gold)
                Spacer()
                Text("\(trophies.count) ON DISPLAY")
                    .font(.system(size: 9, weight: .bold))
                    .tracking(0.8)
                    .foregroundStyle(.white.opacity(0.55))
            }

            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(LinearGradient(colors: [TrophyRoomPalette.red, TrophyRoomPalette.darkRed, .black],
                                         startPoint: .top, endPoint: .bottom))
                RoundedRectangle(cornerRadius: 20)
                    .stroke(TrophyRoomPalette.gold.opacity(0.55), lineWidth: 2)

                VStack(spacing: 0) {
                    HStack {
                        Text("ANFIELD")
                        Spacer()
                        Image(systemName: "crown.fill")
                        Spacer()
                        Text("HONOURS")
                    }
                    .font(.system(size: 9, weight: .black))
                    .tracking(2)
                    .foregroundStyle(TrophyRoomPalette.gold.opacity(0.85))
                    .padding(.horizontal, 16)
                    .padding(.top, 14)
                    .padding(.bottom, 7)

                    if displayedTrophies.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "trophy")
                                .font(.system(size: 42))
                                .foregroundStyle(TrophyRoomPalette.gold.opacity(0.65))
                            Text("YOUR FIRST TROPHY AWAITS")
                                .font(.system(size: 10, weight: .heavy))
                                .tracking(1.4)
                                .foregroundStyle(.white.opacity(0.7))
                            Text("Win silverware and it will appear here")
                                .font(.caption2)
                                .foregroundStyle(.white.opacity(0.5))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 145)
                    } else {
                        let rows = stride(from: 0, to: displayedTrophies.count, by: 3).map {
                            Array(displayedTrophies[$0..<min($0 + 3, displayedTrophies.count)])
                        }
                        ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                            HStack(alignment: .bottom, spacing: 7) {
                                ForEach(row) { trophy in
                                    Button { onSelect(trophy) } label: {
                                        VStack(spacing: 4) {
                                            Image(systemName: symbol(for: trophy))
                                                .font(.system(size: trophy.category == "Continental" ? 37 : 32,
                                                              weight: .medium))
                                                .symbolRenderingMode(.palette)
                                                .foregroundStyle(TrophyRoomPalette.gold, TrophyRoomPalette.bronze)
                                                .shadow(color: TrophyRoomPalette.gold.opacity(0.45), radius: 8)
                                                .frame(height: 54, alignment: .bottom)
                                            Text(trophy.name.uppercased())
                                                .font(.system(size: 8, weight: .heavy))
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.65)
                                                .foregroundStyle(.white)
                                            Text(trophy.season)
                                                .font(.system(size: 7, weight: .medium))
                                                .foregroundStyle(TrophyRoomPalette.gold.opacity(0.8))
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.top, 7)
                                        .contentShape(Rectangle())
                                    }
                                    .buttonStyle(.plain)
                                }
                                if row.count < 3 {
                                    ForEach(0..<(3 - row.count), id: \.self) { _ in
                                        Color.clear.frame(maxWidth: .infinity)
                                    }
                                }
                            }
                            .padding(.horizontal, 12)
                            .frame(height: 91, alignment: .bottom)
                            Rectangle()
                                .fill(LinearGradient(colors: [TrophyRoomPalette.gold.opacity(0.95),
                                                              TrophyRoomPalette.bronze, TrophyRoomPalette.gold.opacity(0.7)],
                                                     startPoint: .top, endPoint: .bottom))
                                .frame(height: 7)
                                .shadow(color: TrophyRoomPalette.gold.opacity(0.3), radius: 6, y: 3)
                                .padding(.horizontal, 7)
                        }
                    }
                    Spacer(minLength: 0)
                    Text("YOU’LL NEVER WALK ALONE")
                        .font(.system(size: 8, weight: .black))
                        .tracking(2)
                        .foregroundStyle(TrophyRoomPalette.gold.opacity(0.8))
                        .padding(.vertical, 11)
                }
                .padding(.horizontal, 5)
            }
            .frame(minHeight: displayedTrophies.isEmpty ? 205 : CGFloat(66 + ((displayedTrophies.count + 2) / 3) * 98))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(alignment: .top) {
                HStack(spacing: 24) {
                    Circle().fill(TrophyRoomPalette.gold).frame(width: 4, height: 4)
                        .shadow(color: TrophyRoomPalette.gold, radius: 7)
                    Circle().fill(TrophyRoomPalette.gold).frame(width: 4, height: 4)
                        .shadow(color: TrophyRoomPalette.gold, radius: 7)
                }
                .padding(.top, 5)
            }

            Text("Tap any trophy to inspect it in 3D")
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.5))
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }

    private func symbol(for trophy: Trophy) -> String {
        switch trophy.category {
        case "League": return "trophy.fill"
        case "Domestic Cup": return "cup.and.saucer.fill"
        case "Continental": return "globe.europe.africa.fill"
        default: return "medal.fill"
        }
    }
}

struct Trophy3DView: View {
    var body: some View {
        SceneView(scene: makeScene(), options: [.allowsCameraControl, .autoenablesDefaultLighting])
            .background(Color.clear)
            .accessibilityLabel("Interactive 3D gold football trophy. Drag to rotate.")
    }

    private func makeScene() -> SCNScene {
        let scene = SCNScene()
        let gold = SCNMaterial()
        gold.diffuse.contents = UIColor(red: 0.96, green: 0.68, blue: 0.18, alpha: 1)
        gold.metalness.contents = 0.92
        gold.roughness.contents = 0.2
        gold.lightingModel = .physicallyBased

        let darkGold = SCNMaterial()
        darkGold.diffuse.contents = UIColor(red: 0.48, green: 0.25, blue: 0.055, alpha: 1)
        darkGold.metalness.contents = 0.8
        darkGold.roughness.contents = 0.27

        let cup = SCNCylinder(radius: 0.48, height: 0.72)
        cup.radialSegmentCount = 64
        cup.firstMaterial = gold
        let cupNode = SCNNode(geometry: cup)
        cupNode.position = SCNVector3(0, 0.75, 0)
        cupNode.scale = SCNVector3(1, 0.72, 1)
        scene.rootNode.addChildNode(cupNode)

        let rim = SCNTorus(ringRadius: 0.43, pipeRadius: 0.055)
        rim.firstMaterial = gold
        let rimNode = SCNNode(geometry: rim)
        rimNode.position = SCNVector3(0, 1.02, 0)
        scene.rootNode.addChildNode(rimNode)

        for side in [-1.0, 1.0] {
            let handle = SCNTorus(ringRadius: 0.22, pipeRadius: 0.055)
            handle.firstMaterial = darkGold
            let node = SCNNode(geometry: handle)
            node.position = SCNVector3(Float(side * 0.48), 0.77, 0)
            node.scale = SCNVector3(0.78, 1.25, 0.78)
            scene.rootNode.addChildNode(node)
        }

        let stem = SCNCylinder(radius: 0.12, height: 0.48)
        stem.firstMaterial = darkGold
        let stemNode = SCNNode(geometry: stem)
        stemNode.position = SCNVector3(0, 0.22, 0)
        scene.rootNode.addChildNode(stemNode)

        let base = SCNBox(width: 0.72, height: 0.18, length: 0.55, chamferRadius: 0.06)
        base.firstMaterial = darkGold
        let baseNode = SCNNode(geometry: base)
        baseNode.position = SCNVector3(0, -0.1, 0)
        scene.rootNode.addChildNode(baseNode)

        let plaque = SCNBox(width: 0.42, height: 0.09, length: 0.025, chamferRadius: 0.015)
        plaque.firstMaterial = gold
        let plaqueNode = SCNNode(geometry: plaque)
        plaqueNode.position = SCNVector3(0, -0.1, 0.29)
        scene.rootNode.addChildNode(plaqueNode)

        let turntable = SCNNode()
        let trophyNodes = scene.rootNode.childNodes
        trophyNodes.forEach { $0.removeFromParentNode(); turntable.addChildNode($0) }
        scene.rootNode.addChildNode(turntable)
        turntable.runAction(.repeatForever(.rotateBy(x: 0, y: CGFloat.pi * 2, z: 0, duration: 12)))

        let camera = SCNCamera()
        camera.fieldOfView = 42
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, 0.65, 4.6)
        cameraNode.look(at: SCNVector3(0, 0.45, 0))
        scene.rootNode.addChildNode(cameraNode)

        let keyLight = SCNLight()
        keyLight.type = .omni
        keyLight.intensity = 850
        let keyNode = SCNNode()
        keyNode.light = keyLight
        keyNode.position = SCNVector3(-2, 3, 3)
        scene.rootNode.addChildNode(keyNode)

        let rimLight = SCNLight()
        rimLight.type = .omni
        rimLight.color = UIColor(red: 1, green: 0.62, blue: 0.2, alpha: 1)
        rimLight.intensity = 500
        let rimNodeLight = SCNNode()
        rimNodeLight.light = rimLight
        rimNodeLight.position = SCNVector3(2, 1, -2)
        scene.rootNode.addChildNode(rimNodeLight)

        let ambient = SCNLight()
        ambient.type = .ambient
        ambient.intensity = 280
        let ambientNode = SCNNode()
        ambientNode.light = ambient
        scene.rootNode.addChildNode(ambientNode)

        scene.background.contents = UIColor.clear
        return scene
    }
}
