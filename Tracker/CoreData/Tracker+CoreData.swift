import CoreData

extension Tracker {
    init?(from coreData: TrackerCoreData) {
        guard let id = coreData.id,
              let name = coreData.name,
              let color = coreData.color,
              let scheduleData = coreData.schedule as? Data, // Явное приведение типа
              let weekDays = try? JSONDecoder().decode([WeekDay].self, from: scheduleData) else {
            return nil
        }
        
        self.init(
            id: id,
            name: name,
            color: color,
            emoji: coreData.emoji ?? "",
            schedule: weekDays.map { $0.rawValue }
        )
    }
    
    func toCoreData(context: NSManagedObjectContext) -> TrackerCoreData {
        let coreData = TrackerCoreData(context: context)
        coreData.id = self.id
        coreData.name = self.name
        coreData.color = self.color
        coreData.emoji = self.emoji.isEmpty ? nil : self.emoji
        
        // Четкое указание типа для преобразования
        let weekDays = self.schedule.compactMap { WeekDay(rawValue: $0) }
        coreData.schedule = try? JSONEncoder().encode(weekDays) as NSObject // Явное преобразование
        
        return coreData
    }
}
