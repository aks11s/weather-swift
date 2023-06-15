import Foundation

/// Погодное условие — преобразует код WMO в текстовое описание и иконку
enum WeatherCondition {
    case clearSky
    case mainlyClear
    case partlyCloudy
    case overcast
    case fog
    case drizzle
    case rain
    case snow
    case thunderstorm
    case unknown

    // MARK: - Init from WMO code

    init(wmoCode: Int) {
        switch wmoCode {
        case 0:         self = .clearSky
        case 1:         self = .mainlyClear
        case 2:         self = .partlyCloudy
        case 3:         self = .overcast
        case 45, 48:    self = .fog
        case 51...67:   self = .drizzle
        case 71...77:   self = .snow
        case 80...82:   self = .rain
        case 85, 86:    self = .snow
        case 95...99:   self = .thunderstorm
        default:        self = .unknown
        }
    }

    var description: String {
        switch self {
        case .clearSky:     return "Clear"
        case .mainlyClear:  return "Mainly Clear"
        case .partlyCloudy: return "Partly Cloudy"
        case .overcast:     return "Overcast"
        case .fog:          return "Fog"
        case .drizzle:      return "Drizzle"
        case .rain:         return "Rain"
        case .snow:         return "Snow"
        case .thunderstorm: return "Thunderstorm"
        case .unknown:      return "Unknown"
        }
    }

    var sfSymbol: String {
        switch self {
        case .clearSky:     return "sun.max.fill"
        case .mainlyClear:  return "sun.max.fill"
        case .partlyCloudy: return "cloud.sun.fill"
        case .overcast:     return "cloud.fill"
        case .fog:          return "cloud.fog.fill"
        case .drizzle:      return "cloud.drizzle.fill"
        case .rain:         return "cloud.rain.fill"
        case .snow:         return "cloud.snow.fill"
        case .thunderstorm: return "cloud.bolt.fill"
        case .unknown:      return "questionmark.circle"
        }
    }
}
