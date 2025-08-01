import CoreData

extension TrackerRecord {
    init?(from coreData: TrackerRecordCoreData) {
        guard let tracker = coreData.tracker,
              let trackerId = tracker.id,
              let date = coreData.date else {
            return nil
        }
        
        self.init(
            trackerId: trackerId,
            date: date
        )
    }
    
    // Убрали 'in' для единообразия
    func toCoreData(context: NSManagedObjectContext, tracker: TrackerCoreData) -> TrackerRecordCoreData {
        let coreData = TrackerRecordCoreData(context: context)
        coreData.date = self.date
        coreData.tracker = tracker
        return coreData
    }
}
