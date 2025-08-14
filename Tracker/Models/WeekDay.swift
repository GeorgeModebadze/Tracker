import Foundation

enum WeekDay: String, CaseIterable, Hashable, Encodable, Decodable {
    case monday = "Понедельник"
    case tuesday = "Вторник"
    case wednesday = "Среда"
    case thursday = "Четверг"
    case friday = "Пятница"
    case saturday = "Суббота"
    case sunday = "Воскресенье"
    
    var localizedName: String {
        switch self {
        case .monday: return NSLocalizedString("monday", comment: "")
        case .tuesday: return NSLocalizedString("tuesday", comment: "")
        case .wednesday: return NSLocalizedString("wednesday", comment: "")
        case .thursday: return NSLocalizedString("thursday", comment: "")
        case .friday: return NSLocalizedString("friday", comment: "")
        case .saturday: return NSLocalizedString("saturday", comment: "")
        case .sunday: return NSLocalizedString("sunday", comment: "")
        }
    }
    
    var shortName: String {
        switch self {
        case .monday: return NSLocalizedString("mon_short", comment: "")
        case .tuesday: return NSLocalizedString("tue_short", comment: "")
        case .wednesday: return NSLocalizedString("wed_short", comment: "")
        case .thursday: return NSLocalizedString("thu_short", comment: "")
        case .friday: return NSLocalizedString("fri_short", comment: "")
        case .saturday: return NSLocalizedString("sat_short", comment: "")
        case .sunday: return NSLocalizedString("sun_short", comment: "")
        }
    }
    
    var order: Int {
        switch self {
        case .monday: return 1
        case .tuesday: return 2
        case .wednesday: return 3
        case .thursday: return 4
        case .friday: return 5
        case .saturday: return 6
        case .sunday: return 7
        }
    }
    
    static func encode(_ days: [WeekDay]) -> String {
        return days.map { $0.rawValue }.joined(separator: ",")
    }
    
    static func decode(_ string: String?) -> [WeekDay] {
        guard let string = string else { return [] }
        return string.components(separatedBy: ",")
            .compactMap { WeekDay(rawValue: $0) }
    }
}
