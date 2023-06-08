import UIKit

enum AppColor {

    // MARK: - Gradient (Locations background)
    static let gradientTop    = UIColor(hex: "#391A49")
    static let gradientMid    = UIColor(hex: "#301D5C")
    static let gradientBottom = UIColor(hex: "#262171")

    // MARK: - Primary
    static let primary        = UIColor(hex: "#262171")
    static let primaryBlur    = UIColor(hex: "#262171").withAlphaComponent(0.97)

    // MARK: - Text & Icons
    static let white          = UIColor(hex: "#FFFFFF")
    static let whiteMuted     = UIColor(hex: "#FFFFFF").withAlphaComponent(0.8)
    static let whiteDim       = UIColor(hex: "#FFFFFF").withAlphaComponent(0.6)
    static let whiteFaint     = UIColor(hex: "#FFFFFF").withAlphaComponent(0.5)
    static let whiteOverlay   = UIColor(hex: "#FFFFFF").withAlphaComponent(0.15)
    static let forecastText   = UIColor(hex: "#ECECEC")

    // MARK: - Backgrounds
    static let black          = UIColor(hex: "#000000")
    static let blackOverlay   = UIColor(hex: "#000000").withAlphaComponent(0.33)
    static let cardBackground = UIColor(hex: "#AAA5A5")
    static let forecastOverlay = UIColor(hex: "#535353").withAlphaComponent(0.3)

    // MARK: - Actions
    static let deleteRed      = UIColor(hex: "#FF453B")

    // MARK: - Transparent
    static let clear          = UIColor.clear
}

// MARK: - UIColor+Hex

extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var rgb: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgb)
        let r = CGFloat((rgb >> 16) & 0xFF) / 255
        let g = CGFloat((rgb >> 8) & 0xFF) / 255
        let b = CGFloat(rgb & 0xFF) / 255
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}
