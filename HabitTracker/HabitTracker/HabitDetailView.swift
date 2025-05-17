import SwiftUI
import CoreData

struct HabitDetailView: View {
    @ObservedObject var habit: Habit
    @Environment(\.managedObjectContext) private var ctx
    @FetchRequest private var completions: FetchedResults<Completion>
    @State private var displayMonth = Date()
    
    private var sortedCompletions: [Completion] {
        let set = Array(completions)
        return set.sorted {
            guard let d1 = $0.date, let d2 = $1.date else { return false }
            return d1 < d2
        }
    }

    init(habit: Habit) {
        self.habit = habit
        let req: NSFetchRequest<Completion> = Completion.fetchRequest()
        req.predicate = NSPredicate(format: "habit == %@", habit)
        req.sortDescriptors = [NSSortDescriptor(keyPath: \Completion.date, ascending: false)]
        _completions = FetchRequest(fetchRequest: req)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Title
                Text(habit.name ?? "Untitled")
                    .font(.largeTitle).bold()
                    .padding(.top)

                // Progress
                let days = sortedCompletions.isEmpty ? 0 : calculateDaysElapsed()
                let milestone = ((days - 1) / 30 + 1) * 30
                VStack(spacing: 4) {
                    HStack {
                        Text("Progress").font(.headline)
                        Spacer()
                        Text("\(days)/\(milestone) days")
                            .font(.subheadline).foregroundColor(.secondary)
                    }
                    ProgressView(value: Double(days), total: Double(milestone))
                        .progressViewStyle(.linear)
                }
                .padding(.horizontal)

                // Stats
                HStack {
                    stat("Streak", "\(calculateStreak())")
                    Spacer()
                    stat("Check-Ins", "\(sortedCompletions.count)")
                    Spacer()
                    stat("Score", "\(calculateScore(days: days))%")
                }
                .padding(.horizontal)

                // Calendar
                calendarView

                // Details
                VStack(alignment: .leading, spacing: 8) {
                    Text("Details").font(.headline)
                    detailRow("First Check-In:", firstCheckIn())
                    detailRow("Last Done:", lastDone())
                    detailRow("Duration:", "\(days) days")
                }
                .padding().background(Color(.secondarySystemBackground))
                .cornerRadius(12).padding(.horizontal)

                // Entries
                VStack(alignment: .leading, spacing: 8) {
                    Text("Entries").font(.headline)
                    ForEach(sortedCompletions, id: \.objectID) { c in
                        HStack {
                            Text(c.date!, style: .date)
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                    .onDelete(perform: delete)
                }
                .padding(.horizontal)

                // Toggle
                Button(action: toggle) {
                    Text(isCheckedToday() ? "Undo Check-In" : "+ Check-In")
                        .frame(maxWidth: .infinity)
                        .padding().background(isCheckedToday() ? Color.red : Color.accentColor)
                        .foregroundColor(.white).cornerRadius(10)
                }
                .padding(.horizontal)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: Helpers

    private func stat(_ title: String, _ value: String) -> some View {
        VStack { Text(value).font(.title2).bold(); Text(title).font(.caption) }
    }

    private func detailRow(_ label: String, _ value: String) -> some View {
        HStack { Text(label); Spacer(); Text(value) }
    }

    private func calculateDaysElapsed() -> Int {
        guard let first = sortedCompletions.first?.date else { return 0 }
        let start = Calendar.current.startOfDay(for: first)
        let today = Calendar.current.startOfDay(for: Date())
        let diff = Calendar.current.dateComponents([.day], from: start, to: today).day ?? 0
        return diff + 1    // include the first day
    }

    private func calculateStreak() -> Int {
        var streak = 0
        var current = Calendar.current.startOfDay(for: Date())
        while sortedCompletions.contains(where: {
            guard let d = $0.date else { return false }
            return Calendar.current.isDate(d, inSameDayAs: current)
        }) {
            streak += 1
            current = Calendar.current.date(byAdding: .day, value: -1, to: current)!
        }
        return streak
    }

    private func calculateScore(days: Int) -> Int {
        days > 0 ? Int(Double(sortedCompletions.count) / Double(days) * 100) : 0
    }

    private func firstCheckIn() -> String {
        if let d = sortedCompletions.first?.date {
            return DateFormatter.localizedString(from: d, dateStyle: .medium, timeStyle: .none)
        }
        return "–"
    }

    private func lastDone() -> String {
        if let d = habit.lastDone {
            return DateFormatter.localizedString(from: d, dateStyle: .medium, timeStyle: .none)
        }
        return "–"
    }

    private func isCheckedToday() -> Bool {
        sortedCompletions.contains { Calendar.current.isDateInToday($0.date!) }
    }

    private func toggle() {
        let today = Calendar.current.startOfDay(for: Date())
        if let e = completions.first(where: { Calendar.current.isDate($0.date!, inSameDayAs: today) }) {
            ctx.delete(e)
        } else {
            let c = Completion(context: ctx)
            c.date = Date()
            c.habit = habit
        }
        try? ctx.save()
    }

    private func delete(at o: IndexSet) {
        for i in o { ctx.delete(completions[i]) }
        try? ctx.save()
    }

    private var calendarView: some View {
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month], from: displayMonth)
        let first = cal.date(from: comps)!
        let daysRange = cal.range(of: .day, in: .month, for: first)!
        let firstWeekday = cal.component(.weekday, from: first)

        return VStack {
            HStack {
                Button { displayMonth = cal.date(byAdding: .month, value: -1, to: displayMonth)! } label: { Image(systemName: "chevron.left") }
                Spacer()
                Text(displayMonth, formatter: monthFormatter).font(.headline)
                Spacer()
                Button { displayMonth = cal.date(byAdding: .month, value: +1, to: displayMonth)! } label: { Image(systemName: "chevron.right") }
            }
            .padding(.horizontal)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(cal.shortWeekdaySymbols, id: \.self) { Text($0).font(.caption).foregroundColor(.secondary) }
                ForEach(0..<firstWeekday-1, id: \.self) { _ in Text("") }
                ForEach(Array(daysRange), id: \.self) { d in
                    let date = cal.date(byAdding: .day, value: d-1, to: first)!
                    let checked = sortedCompletions.contains { Calendar.current.isDate($0.date!, inSameDayAs: date) }
                    let today = Calendar.current.isDateInToday(date)
                    ZStack {
                        if checked {
                            Circle().fill(Color.accentColor)
                        } else if today {
                            Circle().stroke(Color.accentColor, lineWidth: 2)
                        }
                        Text("\(d)").foregroundColor(checked ? .white : .primary).bold()
                    }
                    .frame(width: 32, height: 32)
                }
            }
            .padding(.horizontal)
        }
    }

}

private let monthFormatter: DateFormatter = {
    let f = DateFormatter(); f.dateFormat = "LLLL yyyy"; return f
}()
