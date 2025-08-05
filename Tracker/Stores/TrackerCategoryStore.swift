import CoreData

final class TrackerCategoryStore {
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
    }
    
    // TODO: Сделаю позже
    func fetchOrCreateCategory(with title: String) -> TrackerCategoryCoreData? {
        return nil
    }
    
    // TODO: Сделаю позже
    func fetchAllCategories() -> [TrackerCategory] {
        return []
    }
}
