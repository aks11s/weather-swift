import UIKit

enum TimeTheme {
    /// Возвращает имя фонового изображения в зависимости от времени суток
    /// - Returns: "daytimeTheme" для дня (6:00-18:00), "nightTheme" для ночи
    static func backgroundImageName() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        // С 6:00 до 18:00 — день, иначе — ночь
        return (hour >= 6 && hour < 18) ? "daytimeTheme" : "nightTheme"
    }
}
