import Foundation

/// Spatial directions around the MacBook.
public enum Direction: String, CaseIterable, Codable, Sendable, Identifiable {
    case front = "FRONT"
    case frontRight = "FRONT-RIGHT"
    case right = "RIGHT"
    case rearRight = "REAR-RIGHT"
    case rear = "REAR"
    case rearLeft = "REAR-LEFT"
    case left = "LEFT"
    case frontLeft = "FRONT-LEFT"
    case unknown = "UNKNOWN"

    public var id: String { rawValue }

    /// Center angle in degrees (0° = Front, 90° = Right, 180° = Rear, 270° = Left).
    public var centerAngleDegrees: Double? {
        switch self {
        case .front: return 0
        case .frontRight: return 45
        case .right: return 90
        case .rearRight: return 135
        case .rear: return 180
        case .rearLeft: return 225
        case .left: return 270
        case .frontLeft: return 315
        case .unknown: return nil
        }
    }

    /// Primary 4-zone sectors.
    public static var primaryFourZones: [Direction] {
        [.front, .right, .rear, .left]
    }

    /// Full 8-zone sectors.
    public static var allEightZones: [Direction] {
        [.front, .frontRight, .right, .rearRight, .rear, .rearLeft, .left, .frontLeft]
    }
}
