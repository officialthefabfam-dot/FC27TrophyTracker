import SwiftUI

@main
struct FC27TrophyTrackerApp: App {
    @StateObject private var store = TrophyStore()
    var body: some Scene {
        WindowGroup {
            TrophyCabinetView()
                .environmentObject(store)
                .preferredColorScheme(.dark)
        }
    }
}
