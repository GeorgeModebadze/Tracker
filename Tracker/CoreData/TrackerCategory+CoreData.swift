import CoreData

extension TrackerCategory {
    init(from coreDataObject: TrackerCategoryCoreData) {
        let trackers = coreDataObject.trackers?
            .compactMap { Tracker(from: $0 as! TrackerCoreData) } ?? []
        
        self.init(
            title: coreDataObject.title ?? "",
            trackers: trackers
        )
    }
    
    func toCoreData(in context: NSManagedObjectContext) -> TrackerCategoryCoreData {
        let object = TrackerCategoryCoreData(context: context)
        object.title = self.title
        return object
    }
}
