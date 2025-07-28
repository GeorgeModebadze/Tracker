import Foundation

struct TrackerRecord: Hashable {
    let trackerId: UUID
    let date: Date
    
    static func == (lhs: TrackerRecord, rhs: TrackerRecord) -> Bool {
        let calendar = Calendar.current
        return lhs.trackerId == rhs.trackerId &&
        calendar.isDate(lhs.date, inSameDayAs: rhs.date)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(trackerId)
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        hasher.combine(components.year)
        hasher.combine(components.month)
        hasher.combine(components.day)
    }
}
