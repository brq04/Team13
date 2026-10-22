import SwiftUI
import MapKit

// MARK: - Theme
extension Color {
    init(hex: UInt32) {
        self.init(red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255)
    }

    static let brand     = Color(hex: 0x96B58B)  // الأزرار، الشريحة المختارة، دبابيس الاستكشاف
    static let brandDark = Color(hex: 0x596B52)  // الخلفيات الغامقة، الأيقونات، النصوص المميزة
    static let brandSoft = Color(hex: 0xC1D3BA)  // إطار الصورة، خلفية العنصر المختار
    static let cream     = Color(hex: 0xF3F5E7)  // Secondary: خلفية الشيت
    static let inkDark   = Color(hex: 0x151A12)  // للدارك مود
    static let inkDark2  = Color(hex: 0x283124)
}

// MARK: - Font
extension Font {
    /// الخط المخصص: The Year of Handicrafts
    static func app(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        let name: String
        switch weight {
        case .black, .heavy: name = "TheYearofHandicrafts-Black"
        case .bold:          name = "TheYearofHandicrafts-Bold"
        case .semibold:      name = "TheYearofHandicrafts-SemiBold"
        case .medium:        name = "TheYearofHandicrafts-Medium"
        default:             name = "TheYearofHandicrafts-Regular"
        }
        return .custom(name, size: size)
    }
}

// MARK: - Models
enum PlaceKind {
    case explore, volunteer

    var color: Color { self == .explore ? .brand : .red }
    var badge: String { self == .explore ? "استكشاف" : "تطوع" }
    var badgeIcon: String { self == .explore ? "tree.fill" : "person.3.fill" }
    var actionTitle: String { self == .explore ? "فتح في الخرائط" : "عرض فرصة التطوع" }
    var actionIcon: String { self == .explore ? "square.and.arrow.up" : "arrow.up.left.square" }
}

enum PlaceCategory: String, CaseIterable, Identifiable {
    case all, water, forests, gardens, waste
    var id: String { rawValue }

    var title: String {
        switch self {
        case .all:     "الكل"
        case .water:   "الماء"
        case .forests: "الغابات"
        case .gardens: "الحدائق"
        case .waste:   "الهدر"
        }
    }
}

struct PlaceTag: Hashable {
    let icon: String
    let text: String
}

struct Place: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String
    let details: String?
    let latitude: Double
    let longitude: Double
    let kind: PlaceKind
    let category: PlaceCategory
    let imageName: String      // اسم الصورة في Assets.xcassets
    let tags: [PlaceTag]

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

// MARK: - Sample data (بيانات تجريبية، بدليها ببياناتك)
extension Place {
    static let samples: [Place] = [
        Place(title: "حديقة الملك عبدالله", subtitle: "حي الملز، الرياض", details: nil,
              latitude: 24.6690, longitude: 46.7290, kind: .explore, category: .gardens,
              imageName: "king_abdullah_park",
              tags: [PlaceTag(icon: "leaf", text: "ساحات خضراء"),
                     PlaceTag(icon: "figure.walk", text: "مسارات مشي")]),

        Place(title: "كسوة فرح", subtitle: "الرياض",
              details: "ساهم في فرز الملابس وتجهيزها لتصل إلى من يحتاجها، وتستخدم من جديد بدلًا من رميها كنفايات.",
              latitude: 24.7200, longitude: 46.6900, kind: .volunteer, category: .waste,
              imageName: "kiswat_farah", tags: []),

        Place(title: "منتزه سلام", subtitle: "حي السلام، الرياض", details: nil,
              latitude: 24.7450, longitude: 46.7600, kind: .explore, category: .gardens,
              imageName: "park_salam", tags: [PlaceTag(icon: "leaf", text: "ساحات خضراء")]),

        Place(title: "مبادرة تشجير", subtitle: "الرياض",
              details: "شارك في زراعة الأشجار والعناية بها في المساحات العامة.",
              latitude: 24.6400, longitude: 46.6500, kind: .volunteer, category: .forests,
              imageName: "tree_initiative", tags: []),

        Place(title: "بحيرة وادي حنيفة", subtitle: "وادي حنيفة، الرياض", details: nil,
              latitude: 24.6000, longitude: 46.5800, kind: .explore, category: .water,
              imageName: "wadi_hanifa", tags: [PlaceTag(icon: "figure.walk", text: "مسارات مشي")]),

        Place(title: "بنك الطعام", subtitle: "الرياض",
              details: "ساهم في تقليل هدر الطعام وإيصاله لمن يحتاجه.",
              latitude: 24.7000, longitude: 46.6300, kind: .volunteer, category: .waste,
              imageName: "food_bank", tags: [])
    ]
}
