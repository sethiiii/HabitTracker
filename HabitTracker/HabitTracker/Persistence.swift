import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "HabitTracker")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { desc, error in
            if let error = error as NSError? {
                fatalError("Unresolved Core Data error \(error), \(error.userInfo)")
            }
        }
    }

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let ctx = result.container.viewContext
        for i in 1...5 {
            let h = Habit(context: ctx)
            h.name = "Sample \(i)"
            h.lastDone = Date()
        }
        try! ctx.save()
        return result
    }()
}
