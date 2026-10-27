import Foundation
import SwiftData

// كل منطق البيانات هنا. الصفحتين ما تلمس قاعدة البيانات مباشرة إلا عبر هذا الملف.
// لو بعدين تبين سيرفر (Firebase/Supabase) تغيرين هذا الملف بس.

struct StatsSnapshot {
    var todayTasks: [TaskItem] = []     // إنجازات اليوم مجمعة لكل نشاط
    var allTasks: [TaskItem] = []       // كل الإنجازات مجمعة لكل نشاط
    var currentDay = 1
    var totalDays = 7
    var doneDays: Set<Int> = []         // أيام السلسلة اللي سجلتي فيها
    var completedStreaks = 0
}

enum Backend {
    private static var cal: Calendar { .current }
    /// للتجربة فقط: يقدّم "اليوم" عشان تجربين السلسلة بدون ما تنتظرين
    static var dayOffset = 0
    private static func today() -> Date {
        let d = cal.date(byAdding: .day, value: dayOffset, to: Date()) ?? Date()
        return cal.startOfDay(for: d)
    }

    // MARK: - تعبئة الأنشطة: يضيف أي نشاط أساسي ناقص (آمن لو انتشغل أكثر من مرة)
    static func seedIfNeeded(_ ctx: ModelContext, with items: [Activity]) {
        let existing = (try? ctx.fetch(FetchDescriptor<Activity>())) ?? []
        let titles = Set(existing.filter { !$0.isCustom }.map(\.title))
        var added = false
        for item in items where !titles.contains(item.title) {
            ctx.insert(item)
            added = true
        }
        if added { try? ctx.save() }
    }

    // MARK: - زر "تأكيد": يسجل إنجاز اليوم ويبدأ/يكمل السلسلة
    static func confirm(_ selected: [Activity], days: Int, in ctx: ModelContext) {
        guard !selected.isEmpty else { return }
        let today = today()

        // 1) السلسلة الفعالة (وإذا انتهت مدتها نقفلها)
        let actives = (try? ctx.fetch(FetchDescriptor<Challenge>(
            predicate: #Predicate { $0.isActive == true }))) ?? []
        var active = actives.first
        if let c = active, c.endDate < today {
            c.isActive = false
            active = nil
        }

        let challenge: Challenge
        if let existing = active {
            challenge = existing
            challenge.activityIDs = selected.map(\.id)
        } else {
            challenge = Challenge(startDate: today, durationDays: days, activityIDs: selected.map(\.id))
            ctx.insert(challenge)
        }

        // 2) إنجاز اليوم (مرة وحدة لكل نشاط باليوم)
        let todays = (try? ctx.fetch(FetchDescriptor<Completion>(
            predicate: #Predicate { $0.day == today }))) ?? []
        let alreadyDone = Set(todays.map(\.activityID))
        for activity in selected where !alreadyDone.contains(activity.id) {
            ctx.insert(Completion(activity: activity, challengeID: challenge.id, date: Date(), day: today))
        }
        try? ctx.save()

        // 3) هل اكتملت كل أيام السلسلة؟
        let cid = challenge.id
        let mine = (try? ctx.fetch(FetchDescriptor<Completion>(
            predicate: #Predicate { $0.challengeID == cid }))) ?? []
        let doneDays = Set(mine.map(\.day))
        if doneDays.count >= challenge.durationDays {
            challenge.isCompleted = true
            challenge.isActive = false
        }
        try? ctx.save()
    }

    // MARK: - الإحصائيات (دالة صافية: تاخذ البيانات وترجع اللي تحتاجه الصفحة)
    static func snapshot(completions: [Completion], challenges: [Challenge]) -> StatsSnapshot {
        var s = StatsSnapshot()
        let today = today()

        s.todayTasks = tasks(from: completions.filter { $0.day == today })
        s.allTasks = tasks(from: completions)
        s.completedStreaks = challenges.filter(\.isCompleted).count

        if let c = challenges.first(where: { $0.isActive && $0.endDate >= today }) {
            s.totalDays = c.durationDays
            let elapsed = cal.dateComponents([.day], from: c.startDate, to: today).day ?? 0
            s.currentDay = min(c.durationDays, max(1, elapsed + 1))

            for log in completions where log.challengeID == c.id {
                let d = (cal.dateComponents([.day], from: c.startDate, to: log.day).day ?? 0) + 1
                if (1...c.durationDays).contains(d) { s.doneDays.insert(d) }
            }
        }
        return s
    }

    // تجميع السجلات لكل نشاط → TaskItem (اللي تستخدمه صفحة الإحصائيات)
    private static func tasks(from logs: [Completion]) -> [TaskItem] {
        Dictionary(grouping: logs, by: \.activityID).values
            .compactMap { group -> TaskItem? in
                guard let first = group.first else { return nil }
                return TaskItem(
                    category: first.category.statCategory,
                    title: first.title,
                    points: group.reduce(0) { $0 + $1.points },
                    completions: group.count
                )
            }
            .sorted { $0.points != $1.points ? $0.points > $1.points : $0.title < $1.title }
    }
}
