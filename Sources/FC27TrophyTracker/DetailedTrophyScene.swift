import SceneKit
import UIKit

/// Builds the detailed, metallic cup used by the trophy inspection view.
enum DetailedTrophyScene {
    static func makeScene() -> SCNScene {
        let scene = SCNScene()
        scene.background.contents = UIColor.clear

        let gold = metal(UIColor(red: 0.96, green: 0.70, blue: 0.24, alpha: 1), roughness: 0.16)
        let brightGold = metal(UIColor(red: 1.0, green: 0.86, blue: 0.48, alpha: 1), roughness: 0.12)
        let shadowGold = metal(UIColor(red: 0.43, green: 0.22, blue: 0.055, alpha: 1), roughness: 0.24)
        let red = fabric(UIColor(red: 0.62, green: 0.012, blue: 0.045, alpha: 1))
        let darkRed = fabric(UIColor(red: 0.30, green: 0.004, blue: 0.022, alpha: 1))
        let model = SCNNode()

        // A hollow, flared cup rather than the previous solid cone.
        let bowlProfile: [(Float, Float)] = [
            (0.43, 0.13), (0.47, 0.19), (0.53, 0.23), (0.62, 0.27),
            (0.78, 0.32), (0.96, 0.38), (1.12, 0.44), (1.19, 0.48),
            (1.23, 0.49), (1.25, 0.46)
        ]
        let bowl = lathe(profile: bowlProfile, material: gold)
        model.addChildNode(bowl)

        addTorus(to: model, radius: 0.475, pipe: 0.025, y: 1.215, material: brightGold)
        addTorus(to: model, radius: 0.445, pipe: 0.009, y: 1.17, material: brightGold)
        addTorus(to: model, radius: 0.225, pipe: 0.018, y: 0.53, material: brightGold)

        // Sculpted handles with collars and red hanging ribbons.
        for side: Float in [-1, 1] {
            let handle = SCNTorus(ringRadius: 0.205, pipeRadius: 0.038)
            handle.firstMaterial = brightGold
            let handleNode = SCNNode(geometry: handle)
            handleNode.position = SCNVector3(side * 0.435, 0.91, 0)
            handleNode.scale = SCNVector3(0.78, 1.38, 0.72)
            model.addChildNode(handleNode)

            let collar = SCNTorus(ringRadius: 0.065, pipeRadius: 0.018)
            collar.firstMaterial = shadowGold
            let collarNode = SCNNode(geometry: collar)
            collarNode.position = SCNVector3(side * 0.405, 1.035, 0)
            collarNode.scale = SCNVector3(1, 1, 0.8)
            model.addChildNode(collarNode)

            let ribbon = SCNBox(width: 0.105, height: 0.48, length: 0.018, chamferRadius: 0.012)
            ribbon.firstMaterial = red
            let ribbonNode = SCNNode(geometry: ribbon)
            ribbonNode.position = SCNVector3(side * 0.47, 0.61, 0.105)
            ribbonNode.eulerAngles.z = side * 0.10
            model.addChildNode(ribbonNode)

            let ribbonTail = SCNBox(width: 0.105, height: 0.10, length: 0.019, chamferRadius: 0.006)
            ribbonTail.firstMaterial = darkRed
            let tailNode = SCNNode(geometry: ribbonTail)
            tailNode.position = SCNVector3(side * 0.47, 0.345, 0.105)
            tailNode.eulerAngles.z = side * 0.10
            model.addChildNode(tailNode)
        }

        // Turned stem, ornamental collars and a stepped engraved plinth.
        addCylinder(to: model, radius: 0.115, height: 0.30, y: 0.30, material: shadowGold)
        addCylinder(to: model, radius: 0.145, height: 0.075, y: 0.43, material: brightGold)
        addCylinder(to: model, radius: 0.105, height: 0.055, y: 0.13, material: brightGold)
        addTorus(to: model, radius: 0.135, pipe: 0.012, y: 0.405, material: gold)

        let upperPlinth = SCNBox(width: 0.62, height: 0.14, length: 0.48, chamferRadius: 0.045)
        upperPlinth.firstMaterial = shadowGold
        let upperNode = SCNNode(geometry: upperPlinth)
        upperNode.position = SCNVector3(0, -0.005, 0)
        model.addChildNode(upperNode)

        let lowerPlinth = SCNBox(width: 0.72, height: 0.15, length: 0.56, chamferRadius: 0.035)
        lowerPlinth.firstMaterial = metal(UIColor(red: 0.22, green: 0.105, blue: 0.035, alpha: 1), roughness: 0.3)
        let lowerNode = SCNNode(geometry: lowerPlinth)
        lowerNode.position = SCNVector3(0, -0.145, 0)
        model.addChildNode(lowerNode)

        // Fine gold trim and a front-facing championship plaque.
        addBox(to: model, width: 0.625, height: 0.012, length: 0.49, position: SCNVector3(0, 0.073, 0), material: brightGold)
        addBox(to: model, width: 0.47, height: 0.075, length: 0.018, position: SCNVector3(0, -0.01, 0.252), material: brightGold)
        let plaqueText = SCNText(string: "CHAMPIONS", extrusionDepth: 0.002)
        plaqueText.font = UIFont.boldSystemFont(ofSize: 0.055)
        plaqueText.flatness = 0.15
        plaqueText.firstMaterial = shadowGold
        let textNode = SCNNode(geometry: plaqueText)
        let (minBound, maxBound) = plaqueText.boundingBox
        textNode.position = SCNVector3(-(maxBound.x - minBound.x) / 2, -0.03, 0.264)
        model.addChildNode(textNode)

        // Small embossed studs on the plaque.
        for x: Float in [-0.205, 0.205] {
            let stud = SCNSphere(radius: 0.012)
            stud.firstMaterial = gold
            let node = SCNNode(geometry: stud)
            node.position = SCNVector3(x, -0.01, 0.268)
            model.addChildNode(node)
        }

        let turntable = SCNNode()
        for child in model.childNodes {
            child.removeFromParentNode()
            turntable.addChildNode(child)
        }
        scene.rootNode.addChildNode(turntable)
        turntable.runAction(.repeatForever(.rotateBy(x: 0, y: CGFloat.pi * 2, z: 0, duration: 16)))

        let cameraNode = SCNNode()
        let camera = SCNCamera()
        camera.fieldOfView = 38
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, 0.62, 4.4)
        cameraNode.look(at: SCNVector3(0, 0.52, 0))
        scene.rootNode.addChildNode(cameraNode)

        addLight(to: scene, position: SCNVector3(-2.5, 3.2, 3.2), intensity: 1150, color: .white)
        addLight(to: scene, position: SCNVector3(2.4, 1.8, -2.2), intensity: 850,
                 color: UIColor(red: 1, green: 0.78, blue: 0.42, alpha: 1))
        addLight(to: scene, position: SCNVector3(0, 2.8, 1.0), intensity: 500,
                 color: UIColor(red: 1, green: 0.92, blue: 0.72, alpha: 1))
        let ambient = SCNLight()
        ambient.type = .ambient
        ambient.intensity = 220
        let ambientNode = SCNNode()
        ambientNode.light = ambient
        scene.rootNode.addChildNode(ambientNode)
        return scene
    }

    private static func metal(_ color: UIColor, roughness: CGFloat) -> SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = color
        material.metalness.contents = 0.96
        material.roughness.contents = roughness
        material.lightingModel = .physicallyBased
        material.isDoubleSided = true
        return material
    }

    private static func fabric(_ color: UIColor) -> SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = color
        material.roughness.contents = 0.82
        material.metalness.contents = 0.02
        material.lightingModel = .physicallyBased
        return material
    }

    /// Revolves a radius/height profile around the vertical axis to form a detailed cup shell.
    private static func lathe(profile: [(Float, Float)], material: SCNMaterial) -> SCNNode {
        let segments = 96
        var vertices: [SCNVector3] = []
        var normals: [SCNVector3] = []
        var indices: [UInt32] = []

        for (ring, point) in profile.enumerated() {
            let previous = profile[max(0, ring - 1)]
            let next = profile[min(profile.count - 1, ring + 1)]
            let dy = next.0 - previous.0
            let dr = next.1 - previous.1
            let length = max(0.0001, sqrt(dy * dy + dr * dr))
            for segment in 0..<segments {
                let angle = Float(segment) / Float(segments) * Float.pi * 2
                let c = cos(angle)
                let s = sin(angle)
                vertices.append(SCNVector3(point.1 * c, point.0, point.1 * s))
                normals.append(SCNVector3(dy * c / length, -dr / length, dy * s / length))
            }
        }

        for ring in 0..<(profile.count - 1) {
            for segment in 0..<segments {
                let next = (segment + 1) % segments
                let a = UInt32(ring * segments + segment)
                let b = UInt32(ring * segments + next)
                let c = UInt32((ring + 1) * segments + segment)
                let d = UInt32((ring + 1) * segments + next)
                indices.append(contentsOf: [a, c, b, b, c, d])
            }
        }

        let vertexSource = SCNGeometrySource(vertices: vertices)
        let normalSource = SCNGeometrySource(normals: normals)
        let data = Data(bytes: indices, count: indices.count * MemoryLayout<UInt32>.size)
        let element = SCNGeometryElement(data: data, primitiveType: .triangles,
                                         primitiveCount: indices.count / 3, bytesPerIndex: MemoryLayout<UInt32>.size)
        let geometry = SCNGeometry(sources: [vertexSource, normalSource], elements: [element])
        geometry.firstMaterial = material
        return SCNNode(geometry: geometry)
    }

    private static func addTorus(to parent: SCNNode, radius: CGFloat, pipe: CGFloat, y: Float, material: SCNMaterial) {
        let geometry = SCNTorus(ringRadius: radius, pipeRadius: pipe)
        geometry.firstMaterial = material
        let node = SCNNode(geometry: geometry)
        node.position.y = y
        parent.addChildNode(node)
    }

    private static func addCylinder(to parent: SCNNode, radius: CGFloat, height: CGFloat, y: Float, material: SCNMaterial) {
        let geometry = SCNCylinder(radius: radius, height: height)
        geometry.radialSegmentCount = 64
        geometry.firstMaterial = material
        let node = SCNNode(geometry: geometry)
        node.position.y = y
        parent.addChildNode(node)
    }

    private static func addBox(to parent: SCNNode, width: CGFloat, height: CGFloat, length: CGFloat,
                               position: SCNVector3, material: SCNMaterial) {
        let geometry = SCNBox(width: width, height: height, length: length, chamferRadius: 0.004)
        geometry.firstMaterial = material
        let node = SCNNode(geometry: geometry)
        node.position = position
        parent.addChildNode(node)
    }

    private static func addLight(to scene: SCNScene, position: SCNVector3, intensity: CGFloat, color: UIColor) {
        let light = SCNLight()
        light.type = .omni
        light.intensity = intensity
        light.color = color
        let node = SCNNode()
        node.light = light
        node.position = position
        scene.rootNode.addChildNode(node)
    }
}
