import SwiftUI

@main
struct SonicFieldApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)
    }
}
