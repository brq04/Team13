import SwiftUI
import CoreText
#if canImport(UIKit)
import UIKit
#endif

// MARK: - الألوان (مشتركة بين الصفحتين)
extension Color {
    init(hex: String) {
        let n = Int(hex.dropFirst(), radix: 16) ?? 0
        self.init(red: Double((n >> 16) & 255) / 255,
                  green: Double((n >> 8) & 255) / 255,
                  blue: Double(n & 255) / 255)
    }

    static let darkGreen  = Color(hex: "#596B52")
    static let sage       = Color(hex: "#96B58B")
    static let lightGreen = Color(hex: "#C1D3BA")
    static let cream      = Color(hex: "#F3F5E7")
    static let ink        = Color(hex: "#283124")
    static let softGray   = Color(hex: "#4F5D4A")

    // أسماء صفحة الإحصائيات (نفس الألوان)
    static let foodGreen    = Color.sage
    static let inkGreen     = Color.ink
    static let creamYellow  = Color(red: 237/255, green: 239/255, blue: 223/255)
    static let upcomingGray = Color(red: 226/255, green: 226/255, blue: 226/255)
}

// MARK: - الخطوط (يدعم أسلوب الصفحتين)
enum AppFont {
    enum Weight: String { case black, bold, semibold, medium, regular }

    private static let names: [String: String] = {
        #if canImport(UIKit)
        for ext in ["otf", "ttf"] {
            for url in Bundle.main.urls(forResourcesWithExtension: ext, subdirectory: nil) ?? [] {
                CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
            }
        }
        var found: [String: String] = [:]
        for family in UIFont.familyNames {
            for name in UIFont.fontNames(forFamilyName: family) where name.lowercased().contains("handicrafts") {
                if let dash = name.lastIndex(of: "-") {
                    found[String(name[name.index(after: dash)...]).lowercased()] = name
                }
            }
        }
        return found
        #else
        return [:]
        #endif
    }()

    static func custom(_ size: CGFloat, _ weight: Weight) -> Font {
        if let name = names[weight.rawValue] { return Font.custom(name, size: size) }
        return Font.system(size: size, weight: weight == .regular ? .regular : .bold)
    }

    // أسلوب صفحة الأنشطة
    static func title(_ size: CGFloat) -> Font { custom(size, .bold) }
    static func text(_ size: CGFloat) -> Font { custom(size, .regular) }

    // أسلوب صفحة الإحصائيات
    static func bold(_ size: CGFloat) -> Font { custom(size, .bold) }
    static func medium(_ size: CGFloat) -> Font { custom(size, .medium) }
    static func regular(_ size: CGFloat) -> Font { custom(size, .regular) }
}
