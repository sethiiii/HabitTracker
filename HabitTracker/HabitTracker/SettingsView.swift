import SwiftUI

struct SettingsView: View {
    @AppStorage("appearance") private var appearance = "system"
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section("Appearance") {
                    Picker("App Theme", selection: $appearance) {
                        Text("System").tag("system")
                        Text("Light").tag("light")
                        Text("Dark").tag("dark")
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .preferredColorScheme(
            appearance == "light" ? .light :
            appearance == "dark"  ? .dark  : nil
        )
    }
}
