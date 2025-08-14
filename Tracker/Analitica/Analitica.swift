import AppMetricaCore

enum Analytica {
    enum Event: String {
        case open = "open"
        case close = "close"
        case click = "click"
    }
    
    enum Screen: String {
        case main = "Main"
    }
    
    enum Item: String {
        case addTrack = "add_track"
        case track = "track"
        case filter = "filter"
        case edit = "edit"
        case delete = "delete"
    }
    
    static func setup(apiKey: String) {
        let configuration = AppMetricaConfiguration(apiKey: apiKey)
        configuration?.areLogsEnabled = false
        if let configuration = configuration {
            AppMetrica.activate(with: configuration)
        }
        print("Analytics setup complete")
    }
    
    static func report(event: Event, screen: Screen, item: Item? = nil) {
        var params: [String: Any] = ["screen": screen.rawValue]
        
        if let item = item {
            params["item"] = item.rawValue
        }
        
        AppMetrica.reportEvent(
            name: event.rawValue,
            parameters: params,
            onFailure: { error in
                if let error = error as? Error {
                    print("Analytics error:", error.localizedDescription)
                }
            }
        )
        
        print("[Analytics] Event: \(event.rawValue), Params: \(params)")
    }
}
