import CoreData

final class TrackerStore {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
    }
    
    func addTracker(_ tracker: Tracker) -> Bool {
        let cdTracker = TrackerCoreData(context: context)
        cdTracker.id = tracker.id
        cdTracker.name = tracker.name
        cdTracker.color = tracker.color
        cdTracker.emoji = tracker.emoji.isEmpty ? nil : tracker.emoji
        
        let weekDays: [WeekDay] = tracker.schedule.compactMap { WeekDay(rawValue: $0) }
        cdTracker.schedule = try? JSONEncoder().encode(weekDays) as NSData
        
        // Временное решение без категорий
        cdTracker.category = nil
        
        do {
            try context.save()
            return true
        } catch {
            context.rollback()
            print("Failed to save tracker: \(error)")
            return false
        }
    }
    
    func fetchTrackers() -> [Tracker] {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        
        do {
            return try context.fetch(request).compactMap { coreData in
                guard let id = coreData.id,
                      let name = coreData.name,
                      let color = coreData.color,
                      let scheduleData = coreData.schedule as? Data,
                      let weekDays = try? JSONDecoder().decode([WeekDay].self, from: scheduleData) else {
                    return nil
                }
                
                return Tracker(
                    id: id,
                    name: name,
                    color: color,
                    emoji: coreData.emoji ?? "",
                    schedule: weekDays.map { $0.rawValue }
                )
            }
        } catch {
            print("Failed to fetch trackers: \(error)")
            return []
        }
    }
    
    // Временный метод для привязки к категории (когда CategoryStore будет готов)
    func setCategory(_ categoryTitle: String?, for trackerId: UUID) -> Bool {
        // Реализуется позже, когда появится CategoryStore
        return false
    }
}
