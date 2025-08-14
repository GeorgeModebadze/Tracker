import Foundation

final class StatisticsService {
    private let recordStore: TrackerRecordStore
    
    init(recordStore: TrackerRecordStore) {
        self.recordStore = recordStore
    }
    
    func getCompletedTrackersCount() -> Int {
        return recordStore.fetchAllRecords().count
    }
}
