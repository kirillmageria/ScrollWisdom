import Foundation

struct WisdomCard: Codable, Identifiable, Hashable {
    let id: String
    let quote: String
    let author: String
    let source: String
    let story: String
    let action: String
    let topic: Topic
    
    enum Topic: String, Codable, CaseIterable, Hashable {
        case stoicism = "stoicism"
        case money = "money"
        case relationships = "relationships"
        case leadership = "leadership"
        case discipline = "discipline"
        case health = "health"
        case psychology = "psychology"
        
        var displayName: String {
            NSLocalizedString("topic.\(rawValue)", comment: "")
        }

        var emoji: String {
            switch self {
            case .stoicism: return "🏛"
            case .money: return "💰"
            case .relationships: return "❤️"
            case .leadership: return "👑"
            case .discipline: return "⚡"
            case .health: return "💪"
            case .psychology: return "🧠"
            }
        }
        
        var gradient: [String] {
            switch self {
            case .stoicism: return ["#1a1a2e", "#16213e"]
            case .money: return ["#1a1a0e", "#2d2b0e"]
            case .relationships: return ["#2e1a1a", "#3e1621"]
            case .leadership: return ["#1a2e1a", "#0e2d1a"]
            case .discipline: return ["#2e2a1a", "#3e2916"]
            case .health: return ["#0e2a1a", "#0a2012"]
            case .psychology: return ["#1a1a2e", "#2a1a3e"]
            }
        }
    }
}
