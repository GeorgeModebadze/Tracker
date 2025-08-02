import CoreData

final class CoreDataStack {
    static let shared = CoreDataStack()
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TrackerModel")
        container.loadPersistentStores { [weak self] storeDescription, error in
            if let error = error as NSError? {
                assertionFailure("Unresolved error \(error), \(error.userInfo)")
            }
            
            if let url = storeDescription.url {
                print("CoreData storage path: \(url.absoluteString)")
                
                if FileManager.default.fileExists(atPath: url.path) {
                    print("Файл хранилища существует")
                } else {
                    print("Файл хранилища не существует!")
                }
            } else {
                print("CoreData storage path: nil")
            }
            
            print("Store type: \(storeDescription.type)")
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
                print("Контекст успешно сохранен")
            } catch {
                context.rollback()
                let nsError = error as NSError
                print("Failed to save context: \(nsError), \(nsError.userInfo)")
            }
        }
    }
    func getStorageURL() -> URL? {
        return persistentContainer.persistentStoreDescriptions.first?.url
    }
}
