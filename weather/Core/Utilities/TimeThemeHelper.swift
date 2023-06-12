import UIKit

enum TimeTheme {
    /// Возвращает имя фонового изображения в зависимости от времени суток
    /// - Returns: "daytimeTheme" для дня (6:00-18:00), "nightTheme" для ночи
    static func backgroundImageName() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        // 6 AM to 6 PM = daytime
        return (hour >= 6 && hour < 18) ? "daytimeTheme" : "nightTheme"
    }
}
