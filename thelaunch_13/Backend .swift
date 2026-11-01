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
    var hasActive = false
    var plannedToday = false            // أضافت أنشطة اليوم ولسا ما أكدت الإنجاز
    var scheduled = false               // تحدي جديد مجدول يبدأ بكرة

    /// أنجزتي نشاط اليوم؟
    var todayDone: Bool { hasActive && doneDays.contains(currentDay) }
    /// كل أيام الهدف مكتملة؟
    var isGoalComplete: Bool { hasActive && doneDays.count >= totalDays }
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

    // MARK: - زر "تأكيد": يضيف أنشطة اليوم (خطة فقط). ما تنحسب بالإحصائيات لين تأكدين الإنجاز
    static func confirm(_ selected: [Activity], days: Int, in ctx: ModelContext) {
        guard !selected.isEmpty else { return }
        let today = today()

        // 1) السلسلة الفعالة (وإذا انتهت مدتها نقفلها)
        let actives = (try? ctx.fetch(FetchDescriptor<Challenge>(
            predicate: #Predicate { $0.isActive == true }))) ?? []
        var active = actives.first
        if let c = active, c.endDate < today || c.isCompleted {   // خلص أو انتهت مدته: نقفله ونقدر نبدأ تحدي جديد
            c.isActive = false
            active = nil
        }

        let challenge: Challenge
        if let existing = active {
            challenge = existing
            challenge.activityIDs = selected.map(\.id)
        } else {
            // لو أنجزتي أنشطة اليوم (من تحدي سابق) يبدأ التحدي الجديد بكرة، عشان ما تنحسب نقاط اليوم مرتين
            let doneToday = !((try? ctx.fetch(FetchDescriptor<Completion>(
                predicate: #Predicate { $0.day == today }))) ?? []).isEmpty
            let start = doneToday ? (cal.date(byAdding: .day, value: 1, to: today) ?? today) : today
            challenge = Challenge(startDate: start, durationDays: days, activityIDs: selected.map(\.id))
            ctx.insert(challenge)
        }
        challenge.plannedDay = today

        // 2) تعديل: نحذف إنجازات اليوم القديمة من الإحصائيات (تتحسب من جديد لما تأكدين الإنجاز)
        let cid = challenge.id
        let todays = (try? ctx.fetch(FetchDescriptor<Completion>(
            predicate: #Predicate { $0.day == today }))) ?? []
        for old in todays where old.challengeID == cid { ctx.delete(old) }
        try? ctx.save()
        refreshCompleted(challenge, in: ctx)
    }

    // MARK: - نهاية اليوم: "أنجزتها" → تنحسب أنشطة اليوم بالإحصائيات والسلسلة
    /// ترجع true لو اكتمل هدف السلسلة كله
    @discardableResult
    static func completeToday(in ctx: ModelContext) -> Bool {
        let today = today()
        let actives = (try? ctx.fetch(FetchDescriptor<Challenge>(
            predicate: #Predicate { $0.isActive == true }))) ?? []
        guard let c = actives.first(where: { $0.startDate <= today && $0.endDate >= today }) else { return false }

        let ids = Set(c.activityIDs)
        let activities = ((try? ctx.fetch(FetchDescriptor<Activity>())) ?? []).filter { ids.contains($0.id) }
        let cid = c.id
        let todays = (try? ctx.fetch(FetchDescriptor<Completion>(
            predicate: #Predicate { $0.day == today }))) ?? []
        let alreadyDone = Set(todays.filter { $0.challengeID == cid }.map(\.activityID))
        for activity in activities where !alreadyDone.contains(activity.id) {
            ctx.insert(Completion(activity: activity, challengeID: cid, date: Date(), day: today))
        }
        try? ctx.save()
        refreshCompleted(c, in: ctx)
        return c.isCompleted
    }

    // هل اكتملت كل أيام السلسلة؟ (تبقى فعّالة لين يخلص آخر يوم)
    private static func refreshCompleted(_ challenge: Challenge, in ctx: ModelContext) {
        let cid = challenge.id
        let mine = (try? ctx.fetch(FetchDescriptor<Completion>(
            predicate: #Predicate { $0.challengeID == cid }))) ?? []
        challenge.isCompleted = Set(mine.map(\.day)).count >= challenge.durationDays
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
            s.hasActive = true
            s.totalDays = c.durationDays
            s.scheduled = c.startDate > today
            let elapsed = cal.dateComponents([.day], from: c.startDate, to: today).day ?? 0
            s.currentDay = min(c.durationDays, max(1, elapsed + 1))

            for log in completions where log.challengeID == c.id {
                let d = (cal.dateComponents([.day], from: c.startDate, to: log.day).day ?? 0) + 1
                if (1...c.durationDays).contains(d) { s.doneDays.insert(d) }
            }
            // الأنشطة تبقى هي نفسها كل أيام السلسلة، فكل يوم جديد فيه خطة جاهزة تنتظر تأكيد الإنجاز
            s.plannedToday = !s.scheduled && !c.activityIDs.isEmpty && !s.doneDays.contains(s.currentDay)
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
    
    //للأنشطه المختاره في صفحة التعديل
    static func activeSelection(_ challenges: [Challenge]) -> (ids: Set<UUID>, days: Int, plannedToday: Bool)? {
        let t = today()
        guard let c = challenges.first(where: { $0.isActive && $0.endDate >= t && !$0.isCompleted }) else { return nil }
        return (Set(c.activityIDs), c.durationDays, true)   // الخطة مستمرة لين تخلص المدة
    }
}
