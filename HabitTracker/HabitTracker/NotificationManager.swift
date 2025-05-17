import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    /// Ask the user for permission to send alerts & sounds.
    func requestPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error:", error)
            }
        }
    }

    /// Schedule a repeating daily notification at a given time.
    func scheduleDailyReminder(id: String, title: String, time: Date) {
        let center = UNUserNotificationCenter.current()
        // Cancel any existing request with this identifier
        center.removePendingNotificationRequests(withIdentifiers: [id])

        var components = Calendar.current.dateComponents([.hour, .minute], from: time)
        components.second = 0

        let content = UNMutableNotificationContent()
        content.title = "Habit Reminder"
        content.body = "Time to: \(title)"
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        center.add(request) { error in
            if let error = error {
                print("Failed to schedule notification:", error)
            }
        }
    }

    /// Cancel the daily reminder for a specific habit.
    func cancelReminder(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }
}
