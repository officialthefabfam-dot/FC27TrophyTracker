import SwiftUI
import UIKit

@MainActor
final class ThemeSettings: ObservableObject {
    @Published var appearance: String {
        didSet { UserDefaults.standard.set(appearance, forKey: "fc27-appearance") }
    }
    @Published var accentName: String {
        didSet { UserDefaults.standard.set(accentName, forKey: "fc27-accent-name") }
    }
    @Published var customHex: String {
        didSet { UserDefaults.standard.set(customHex, forKey: "fc27-custom-accent") }
    }

    init() {
        appearance = UserDefaults.standard.string(forKey: "fc27-appearance") ?? "System"
        accentName = UserDefaults.standard.string(forKey: "fc27-accent-name") ?? "Blue"
        customHex = UserDefaults.standard.string(forKey: "fc27-custom-accent") ?? "#3978E8"
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

    private static func color(from hex: String) -> Color {
        let cleaned = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        guard cleaned.count == 6, let value = UInt32(cleaned, radix: 16) else {
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
                    Picker("Mode", selection: $theme.appearance) {
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
                                theme.accentName = preset
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
                                        .overlay(Circle().stroke(theme.accentName == preset ? Color.primary : .clear, lineWidth: 2).padding(-4))
                                    Text(preset)
                                        .font(.caption.weight(.medium))
                                        .foregroundStyle(.primary)
                                }
                                .frame(maxWidth: .infinity)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 6)

                    ColorPicker("Custom colour", selection: Binding(
                        get: { theme.customColor },
                        set: { newColor in
                            let ui = UIColor(newColor)
                            var red: CGFloat = 0
                            var green: CGFloat = 0
                            var blue: CGFloat = 0
                            var alpha: CGFloat = 0
                            ui.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                            theme.customHex = String(format: "#%02X%02X%02X",
                                                     Int(red * 255), Int(green * 255), Int(blue * 255))
                            theme.accentName = "Custom"
                        }
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
