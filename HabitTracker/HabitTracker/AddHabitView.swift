import SwiftUI

struct AddHabitView: View {
    @Environment(\.managedObjectContext) private var ctx
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""

    var body: some View {
        NavigationView {
            Form {
                Section("Habit Name") {
                    TextField("Enter name", text: $name)
                }
            }
            .navigationTitle("New Habit")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let h = Habit(context: ctx)
                        h.name = name
                        try? ctx.save()
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}
