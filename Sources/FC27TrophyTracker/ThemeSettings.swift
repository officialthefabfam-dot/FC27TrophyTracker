import SwiftUI
import UIKit

@MainActor
final class ThemeSettings: ObservableObject {
    private enum Keys {
        static let appearance = "fc27-appearance"
        static let accentName = "fc27-accent-name"
        static let customAccent = "fc27-custom-accent"
    }

    private let defaults: UserDefaults

    @Published private(set) var appearance: String
    @Published private(set) var accentName: String
    @Published private(set) var customHex: String

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let savedAppearance = defaults.string(forKey: Keys.appearance) ?? "System"
        appearance = ["System", "Light", "Dark"].contains(savedAppearance) ? savedAppearance : "System"

        let savedAccent = defaults.string(forKey: Keys.accentName) ?? "Blue"
        accentName = ["Blue", "Red", "Green", "Purple", "Gold", "Custom"].contains(savedAccent) ? savedAccent : "Blue"

        let savedHex = defaults.string(forKey: Keys.customAccent) ?? "#3978E8"
        customHex = Self.isValidHex(savedHex) ? savedHex : "#3978E8"
    }

    func setAppearance(_ value: String) {
        guard ["System", "Light", "Dark"].contains(value), appearance != value else { return }
        appearance = value
        defaults.set(value, forKey: Keys.appearance)
    }

    func setAccent(_ value: String) {
        guard ["Blue", "Red", "Green", "Purple", "Gold", "Custom"].contains(value), accentName != value else { return }
        accentName = value
        defaults.set(value, forKey: Keys.accentName)
    }

    func setCustomAccent(_ color: Color) {
        let uiColor = UIColor(color)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        guard uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else { return }

        let hex = String(format: "#%02X%02X%02X",
                         Int((red * 255).rounded()),
                         Int((green * 255).rounded()),
                         Int((blue * 255).rounded()))
        guard Self.isValidHex(hex) else { return }
        customHex = hex
        defaults.set(hex, forKey: Keys.customAccent)
        setAccent("Custom")
    }

    var colorScheme: ColorScheme? {
        switch appearance {
        case "Light": return .light
        case "Dark": return .dark
        default: return nil
        }
    }

    var accent: Color { color(for: accentName) }
    var background: Color { Color(uiColor: .systemGroupedBackground) }
    var surface: Color { Color(uiColor: .secondarySystemGroupedBackground) }
    var primaryText: Color { Color.primary }
    var secondaryText: Color { Color.secondary }
    var border: Color { Color(uiColor: .separator).opacity(0.25) }
    var customColor: Color { Self.color(from: customHex) }

    func color(for name: String) -> Color {
        switch name {
        case "Red": return Color(red: 0.82, green: 0.20, blue: 0.25)
        case "Green": return Color(red: 0.12, green: 0.58, blue: 0.39)
        case "Purple": return Color(red: 0.48, green: 0.34, blue: 0.78)
        case "Gold": return Color(red: 0.78, green: 0.55, blue: 0.16)
        case "Custom": return customColor
        default: return Color(red: 0.20, green: 0.43, blue: 0.86)
        }
    }

    private static func isValidHex(_ hex: String) -> Bool {
        let cleaned = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        return cleaned.count == 6 && UInt32(cleaned, radix: 16) != nil
    }

    private static func color(from hex: String) -> Color {
        let cleaned = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        guard isValidHex(cleaned), let value = UInt32(cleaned, radix: 16) else {
            return Color(red: 0.20, green: 0.43, blue: 0.86)
        }
        return Color(red: Double((value >> 16) & 0xFF) / 255,
                     green: Double((value >> 8) & 0xFF) / 255,
                     blue: Double(value & 0xFF) / 255)
    }
}

struct ThemeSettingsView: View {
    @EnvironmentObject private var theme: ThemeSettings
    @Environment(\.dismiss) private var dismiss
    private let presets = ["Blue", "Red", "Green", "Purple", "Gold"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Appearance") {
                    Picker("Mode", selection: Binding(
                        get: { theme.appearance },
                        set: { theme.setAppearance($0) }
                    )) {
                        Text("System").tag("System")
                        Text("Light").tag("Light")
                        Text("Dark").tag("Dark")
                    }
                    .pickerStyle(.segmented)
                }

                Section("Accent colour") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 72))], spacing: 14) {
                        ForEach(presets, id: \.self) { preset in
                            Button {
                                theme.setAccent(preset)
                            } label: {
                                VStack(spacing: 7) {
                                    Circle()
                                        .fill(theme.color(for: preset))
                                        .frame(width: 34, height: 34)
                                        .overlay {
                                            if theme.accentName == preset {
                                                Image(systemName: "checkmark")
                                                    .font(.caption.bold())
                                                    .foregroundStyle(.white)
                                            }
                                        }
                                        .overlay(Circle().stroke(theme.accentName == preset ? theme.accent : .clear, lineWidth: 2).padding(-4))
                                    Text(preset)
                                        .font(.caption.weight(.medium))
                                        .foregroundStyle(.primary)
                                }
                                .frame(maxWidth: .infinity)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("\(preset) accent colour")
                            .accessibilityAddTraits(theme.accentName == preset ? .isSelected : [])
                        }
                    }
                    .padding(.vertical, 6)

                    ColorPicker("Custom colour", selection: Binding(
                        get: { theme.customColor },
                        set: { theme.setCustomAccent($0) }
                    ))
                    if theme.accentName == "Custom" {
                        Label("Custom colour selected", systemImage: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(theme.accent)
                    }
                }

                Section {
                    Text("Your choice is saved on this device. It changes the app's appearance without affecting your career records or trophies.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Personalise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .tint(theme.accent)
    }
}
