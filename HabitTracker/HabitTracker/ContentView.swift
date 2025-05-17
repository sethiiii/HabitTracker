import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Habit.name, ascending: true)],
        animation: .default)
    private var habits: FetchedResults<Habit>

    @AppStorage("appearance") private var appearance = "system"
    @State private var showingAdd = false
    @State private var showingSettings = false

    var body: some View {
        NavigationView {
            List {
                ForEach(habits, id: \.objectID) { habit in
                    NavigationLink {
                        HabitDetailView(habit: habit)
                    } label: {
                        HStack {
                            Text(habit.name ?? "")
                            Spacer()
                            Text("\(habit.completions?.count ?? 0)")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .onDelete(perform: deleteHabits)
            }
            .navigationTitle("Habits")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { showingSettings = true } label: {
                        Image(systemName: "gearshape")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showingAdd = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showingAdd) {
            AddHabitView()
                .environment(\.managedObjectContext, viewContext)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }

    private func deleteHabits(offsets: IndexSet) {
        for index in offsets {
            viewContext.delete(habits[index])
        }
        try? viewContext.save()
    }
}
