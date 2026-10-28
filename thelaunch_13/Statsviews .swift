import SwiftUI
import SwiftData

// يستبدل: TodayStatsView, AllStatsView, StreakCard, TasksGrid في ملف الإحصائيات القديم.

// MARK: - صفحة إحصائيات اليوم
struct TodayStatsView: View {
    @Query private var completions: [Completion]
    @Query private var challenges: [Challenge]

    var body: some View {
        let s = Backend.snapshot(completions: completions, challenges: challenges)

        VStack(spacing: 0) {
            StreakCard(currentDay: s.currentDay, totalDays: s.totalDays, doneDays: s.doneDays)
                .padding(.top, 45)

            // الدونات من نقاط اليوم
            StatsChartSection(stats: CategoryStat.totals(from: s.todayTasks) { $0.points })
                .padding(.top, 32)

            TasksGrid(tasks: Array(s.todayTasks.prefix(4)), kind: .dailyPoints)
                .padding(.top, 43)
        }
    }
}

// MARK: - صفحة جميع الإحصائيات
struct AllStatsView: View {
    @Query private var completions: [Completion]
    @Query private var challenges: [Challenge]

    var body: some View {
        let s = Backend.snapshot(completions: completions, challenges: challenges)
        // الدونات من عدد مرات الإنجاز
        let stats = CategoryStat.totals(from: s.allTasks) { $0.completions }
        let topTasks = s.allTasks.sorted { $0.completions > $1.completions }.prefix(4)

        VStack(spacing: 0) {
            CompletedStreaksHeader(count: s.completedStreaks)
                .padding(.top, Layout.allStatsHeaderTop)

            DonutChart(
                stats: stats,
                size: Layout.bigDonutSize,
                innerRatio: Layout.bigDonutInnerRatio,
                labelPlacement: .inside
            )
            .padding(.top, Layout.allStatsDonutTop)

            ChartLegend(stats: stats, layout: .horizontal)
                .padding(.horizontal, 50)
                .padding(.top, Layout.allStatsLegendTop)

            TasksGrid(tasks: Array(topTasks), kind: .completions)
                .padding(.top, Layout.allStatsCardsTop)
        }
    }
}

// MARK: - كرت السلسلة
struct StreakCard: View {
    let currentDay: Int
    var totalDays = 7
    var doneDays: Set<Int> = []
    var onEditTap: () -> Void = {}

    // نعرض ٧ أيام بالصف، وإذا السلسلة أطول ينتقل الصف للأسبوع التالي
    private var visibleDays: [Int] {
        let start = ((currentDay - 1) / 7) * 7 + 1
        let end = max(start, min(start + 6, totalDays))
        return Array(start...end)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("يوم \(currentDay)")
                        .font(AppFont.bold(FontSize.streakTitle))

                    Text("سلستك الحاليه \(doneDays.count) ايام متتالية 🌿")
                        .font(TextStyle.streakSubtitle)
                }
                Spacer()
            }

            Spacer(minLength: 0)

            HStack(spacing: 9) {
                ForEach(visibleDays, id: \.self) { day in
                    DayChip(day: day, state: state(for: day))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 66)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 20))
        }
        .padding(.horizontal, 22)
        .padding(.top, 14)
        .padding(.bottom, 10)
        .frame(maxWidth: .infinity)
        .frame(height: 151)
        .background(Color.lightGreen, in: RoundedRectangle(cornerRadius: 28))
        .environment(\.layoutDirection, .rightToLeft)
    }

    private func state(for day: Int) -> DayState {
        if day == currentDay { return .current }
        return doneDays.contains(day) ? .done : .upcoming
    }
}

// MARK: - شبكة كروت المهام (من البيانات الحقيقية)
struct TasksGrid: View {
    let tasks: [TaskItem]
    var kind: PillKind = .dailyPoints

    var body: some View {
        if tasks.isEmpty {
            Text("ما فيه أنشطة مسجلة بعد 🌱")
                .font(AppFont.regular(14))
                .foregroundStyle(Color.darkGreen)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
        } else {
            HStack(alignment: .top, spacing: Layout.cardSpacing) {
                // العمود الأيمن
                VStack(spacing: Layout.cardSpacing) {
                    card(0, Layout.cardShortHeight)
                    card(1, Layout.cardTallHeight)
                }
                // العمود الأيسر
                VStack(spacing: Layout.cardSpacing) {
                    card(2, Layout.cardTallHeight)
                    card(3, Layout.cardShortHeight)
                }
            }
            .environment(\.layoutDirection, .rightToLeft)
        }
    }

    @ViewBuilder
    private func card(_ index: Int, _ height: CGFloat) -> some View {
        if tasks.indices.contains(index) {
            TaskCard(task: tasks[index], height: height, kind: kind)
        }
    }
}
