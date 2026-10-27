import SwiftUI
import SwiftData

// MARK: - التصنيف (يربط صفحة الأنشطة بصفحة الإحصائيات)
enum ActivityCategory: String, CaseIterable {
    case all = "الكل", transport = "تنقل", recycle = "تدوير", food = "طعام", waste = "تقليل الهدر", other = "أخرى"

    var look: (icon: String, color: Color, bg: Color, tag: String) {
        switch self {
        case .transport: return ("bicycle", Color(hex: "#2F6FED"), Color(hex: "#E1EDFC"), "تنقل مستدام")
        case .recycle:   return ("arrow.3.trianglepath", Color(hex: "#A24FE0"), Color(hex: "#EEDDF7"), "إدارة النفايات")
        case .food:      return ("carrot", Color(hex: "#F5A12B"), Color(hex: "#FDEFD9"), "غذاء مستدام")
        case .waste:     return ("leaf", Color.darkGreen, Color.lightGreen.opacity(0.5), "ترشيد الموارد")
        default:         return ("sparkles", Color.darkGreen, Color.lightGreen.opacity(0.5), "مبادرة شخصية")
        }
    }

    /// فئة صفحة الإحصائيات المقابلة (struct Category في ملف الإحصائيات)
    var statCategory: Category {
        switch self {
        case .transport: return .transport
        case .recycle:   return .recycling
        case .food:      return .food
        case .waste:     return .waste
        default:         return .other
        }
    }
}

// MARK: - النشاط (قائمة الأنشطة المتاحة + اللي تضيفها المستخدمة)
@Model
final class Activity {
    var id: UUID
    var categoryRaw: String
    var title: String
    var details: String
    var points: Int
    var tag: String?
    var isCustom: Bool
    var createdAt: Date

    var category: ActivityCategory { ActivityCategory(rawValue: categoryRaw) ?? .other }

    init(_ c: ActivityCategory, _ title: String, _ details: String, _ points: Int,
         tag: String? = nil, custom: Bool = false) {
        self.id = UUID()
        self.categoryRaw = c.rawValue
        self.title = title
        self.details = details
        self.points = points
        self.tag = tag
        self.isCustom = custom
        self.createdAt = Date()
    }
}

// MARK: - سجل الإنجاز (كل مرة تنجز فيها نشاط)
@Model
final class Completion {
    var id: UUID
    var activityID: UUID
    var challengeID: UUID
    var title: String          // نسخة من الاسم عشان الإحصائيات تبقى لو انحذف النشاط
    var categoryRaw: String
    var points: Int
    var date: Date
    var day: Date              // بداية اليوم، للتجميع

    var category: ActivityCategory { ActivityCategory(rawValue: categoryRaw) ?? .other }

    init(activity: Activity, challengeID: UUID, date: Date, day: Date) {
        self.id = UUID()
        self.activityID = activity.id
        self.challengeID = challengeID
        self.title = activity.title
        self.categoryRaw = activity.categoryRaw
        self.points = activity.points
        self.date = date
        self.day = day
    }
}

// MARK: - السلسلة (الهدف: عدد أيام)
@Model
final class Challenge {
    var id: UUID
    var startDate: Date        // بداية اليوم
    var durationDays: Int
    var activityIDs: [UUID]
    var isActive: Bool
    var isCompleted: Bool

    var endDate: Date {
        Calendar.current.date(byAdding: .day, value: durationDays - 1, to: startDate) ?? startDate
    }

    init(startDate: Date, durationDays: Int, activityIDs: [UUID]) {
        self.id = UUID()
        self.startDate = startDate
        self.durationDays = durationDays
        self.activityIDs = activityIDs
        self.isActive = true
        self.isCompleted = false
    }
}
