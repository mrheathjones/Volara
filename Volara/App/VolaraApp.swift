import SwiftUI

@main
struct VolaraApp: App {
    @State private var environment = AppEnvironment()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(environment)
        }
        .defaultSize(width: 1100, height: 720)
    }
}
