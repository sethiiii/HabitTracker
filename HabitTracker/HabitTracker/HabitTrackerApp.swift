import SwiftUI
import UserNotifications
@main
struct HabitTrackerApp: App {
    let persistence = PersistenceController.shared
    @AppStorage("appearance") private var appearance = "system"

    init() {
        NotificationManager.shared.requestPermission()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext,
                              persistence.container.viewContext)
                // Apply theme here, on the root view
                .preferredColorScheme(
                    appearance == "light" ? .light :
                    appearance == "dark"  ? .dark  : nil
                )
        }
    }
}
