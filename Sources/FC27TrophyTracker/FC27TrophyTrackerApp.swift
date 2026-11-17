import SwiftUI

@main
struct FC27TrophyTrackerApp: App {
    @StateObject private var store = TrophyStore()
    @StateObject private var theme = ThemeSettings()

    var body: some Scene {
        WindowGroup {
            TrophyCabinetView()
                .environmentObject(store)
                .environmentObject(theme)
                .preferredColorScheme(theme.colorScheme)
                .tint(theme.accent)
        }
    }
}
