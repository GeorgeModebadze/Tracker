import XCTest
import SnapshotTesting
import CoreData
@testable import Tracker

final class TrackersViewControllerSnapshotTests: XCTestCase {

    override func setUp() {
        super.setUp()
//         isRecording = true // Раскомментируйте для записи новых снепшотов
    }

    private func makeTrackersVC() -> TrackersViewController {
        guard let modelURL = Bundle.main.url(forResource: "TrackerModel", withExtension: "momd") else {
            let testBundle = Bundle(for: type(of: self))
            guard let testModelURL = testBundle.url(forResource: "TrackerModel", withExtension: "momd") else {
                fatalError("Failed to locate TrackerModel.momd in any bundle")
            }
            return createContainer(with: testModelURL)
        }
        return createContainer(with: modelURL)
    }
    
    private func createContainer(with modelURL: URL) -> TrackersViewController {
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Failed to load model from \(modelURL)")
        }
        
        let container = NSPersistentContainer(name: "TrackerModel", managedObjectModel: model)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        
        var loadError: Error?
        container.loadPersistentStores { _, error in
            loadError = error
        }
        XCTAssertNil(loadError)
        
        let context = container.viewContext
        let recordStore = TrackerRecordStore(context: context)
        let trackerStore = TrackerStore(context: context)
        
        let vc = TrackersViewController(trackerStore: trackerStore, recordStore: recordStore)
        _ = vc.view
        vc.view.layoutIfNeeded()
        
        return vc
    }

    func test_TrackersViewController_Light_Empty() {
        let vc = makeTrackersVC()
        assertSnapshot(
            of: vc,
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .light)),
            named: "light_empty"
        )
    }

    func test_TrackersViewController_Dark_Empty() {
        let vc = makeTrackersVC()
        assertSnapshot(
            of: vc,
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .dark)),
            named: "dark_empty"
        )
    }
}
