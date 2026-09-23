// MARK: - Private Methods - Logging
import UIKit

enum LogLevel {
    case verbose  // 详细日志
    case info     // 普通信息
    case warning  // 警告
    case error    // 错误
    
    var prefix: String {
        switch self {
        case .verbose: return "📝"
        case .info: return "ℹ️"
        case .warning: return "⚠️"
        case .error: return "❌"
        }
    }
}

func SKLog(_ message: String, level: LogLevel) {
#if DEBUG
    print("\(level.prefix) \(message)")
#endif
}

func SKLogFormat(point: CGPoint) -> String {
    return "(\(Int(point.x)), \(Int(point.y)))"
}
