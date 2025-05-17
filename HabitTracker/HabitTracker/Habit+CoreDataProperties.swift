//
//  Habit+CoreDataProperties.swift
//  HabitTracker
//

import Foundation
import CoreData
import SwiftUI
import UIKit

extension Habit {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Habit> {
        return NSFetchRequest<Habit>(entityName: "Habit")
    }

    @NSManaged public var name: String?
    @NSManaged public var lastDone: Date?
    @NSManaged public var notificationTime: Date?
    @NSManaged public var categoryColorHex: String?
    @NSManaged public var completions: NSSet?
}

// MARK: Generated accessors for completions
extension Habit {

    @objc(addCompletionsObject:)
    @NSManaged public func addToCompletions(_ value: Completion)

    @objc(removeCompletionsObject:)
    @NSManaged public func removeFromCompletions(_ value: Completion)

    @objc(addCompletions:)
    @NSManaged public func addToCompletions(_ values: NSSet)

    @objc(removeCompletions:)
    @NSManaged public func removeFromCompletions(_ values: NSSet)
}

// MARK: Convenience helper for category color
extension Habit {
    public var categoryColor: Color {
        if let hex = categoryColorHex,
           let uiColor = UIColor(named: hex) {
            return Color(uiColor: uiColor)
        }
        return Color.accentColor
    }
}
