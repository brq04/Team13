//
//  Statspage.swift
//  thelaunch_13
//
//  Created by malhajri on 16/05/1448 AH.
//
import SwiftUI
import SwiftData
import Charts

// MARK: - أرقام عربية (١٢٣) بدل اللاتينية (123)
extension Int {
    var arabicDigits: String {
        let map: [Character: Character] = [
            "0": "٠", "1": "١", "2": "٢", "3": "٣", "4": "٤",
            "5": "٥", "6": "٦", "7": "٧", "8": "٨", "9": "٩"
        ]
        return String(String(self).map { map[$0] ?? $0 })
    }
}

extension Int {
    /// يوم / يومان / أيام / يومًا
    var arabicDays: String {
        switch self {
        case 1:     return "يوم واحد"
        case 2:     return "يومان"
        case 3...10: return "\(arabicDigits) أيام"
        default:    return "\(arabicDigits) يومًا"
        }
    }
}

// MARK: - قياسات مشتركة بين كل الصفحات
enum Layout {
    static let pageMargin: CGFloat = 20
    static let cardTallHeight: CGFloat = 159
    static let cardShortHeight: CGFloat = 84
    static let cardSpacing: CGFloat = 14
    static let cardInset: CGFloat = 10
    static let pillHeight: CGFloat = 20

    // الدونات (صفحة اليوم)
    static let donutSize: CGFloat = 112
    static let donutLabelGap: CGFloat = 0
    static let donutLabelVerticalShift: CGFloat = 2
    static let donutLabelHalfWidth: CGFloat = 14
    static let donutLabelHalfHeight: CGFloat = 8

    // صورة الاحتفال فوق يوم السلسلة
    static let celebIconSize: CGFloat = 24
    static let celebIconOffset: CGFloat = -12

    // صفحة جميع الإحصائيات
    static let bigDonutSize: CGFloat = 190
    static let bigDonutInnerRatio: Double = 0.66
    static let headerIconSize: CGFloat = 50
    static let allStatsHeaderTop: CGFloat = 30
    static let allStatsDonutTop: CGFloat = 32
    static let allStatsLegendTop: CGFloat = 26
    static let allStatsCardsTop: CGFloat = 42
}

// MARK: - أحجام الخطوط
enum FontSize {
    static let tab: CGFloat = 14
    static let streakTitle: CGFloat = 20

    // حجم "سلسلتك الحالية"
    static let streakSubtitle: CGFloat = 14

    static let edit: CGFloat = 16
    static let dayChip: CGFloat = 12
    static let cardCategory: CGFloat = 12

    // حجم السطر الثاني بالكروت مثل "قارورتي معي"
    static let cardTitle: CGFloat = 12

    static let cardPill: CGFloat = 11
    static let chartLabel: CGFloat = 11

    // حجم التصنيفات بجانب الدونات وتحتها
    static let legend: CGFloat = 14

    static let statsHeaderSmall: CGFloat = 17
    static let statsHeaderBig: CGFloat = 30
}

// MARK: - أوزان النصوص القابلة للتعديل
// غيّري regular إلى medium أو bold للوزن.
// الأحجام تغيّرينها من FontSize أعلاه.
enum TextStyle {
    static let streakSubtitle = AppFont.regular(FontSize.streakSubtitle)
    static let legend = AppFont.regular(FontSize.legend)
    static let cardTitle = AppFont.regular(FontSize.cardTitle)
}

// MARK: - الشاشة الرئيسية
struct StatsContentView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0

    let tabs = ["إحصائيات اليوم", "جميع الإحصائيات"]

    var body: some View {
        ScrollView {
            VStack {
                // زر الرجوع (يمين)
                HStack {
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.darkGreen)
                            .frame(width: 46, height: 46)
                            .background(Circle().fill(Color(hex: "#E6EAE3")))
                    }
                }
                .padding(.top, 14)

                // التبويب
                HStack(spacing: 0) {
                    ForEach(tabs.indices, id: \.self) { index in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedTab = index
                            }
                        } label: {
                            Text(tabs[index])
                                .font(AppFont.bold(FontSize.tab))
                                .foregroundStyle(
                                    selectedTab == index
                                    ? Color.white
                                    : Color.darkGreen
                                )
                                .frame(maxWidth: .infinity)
                                .frame(height: 40)
                                .background(
                                    selectedTab == index
                                    ? Color.darkGreen
                                    : Color.clear,
                                    in: Capsule()
                                )
                                .contentShape(Rectangle())
                        }
                    }
                }
                .buttonStyle(.plain)
                .padding(4)
                .background(Color.white, in: Capsule())
                .frame(height: 48)
                .environment(\.layoutDirection, .rightToLeft)
                .padding(.top, 16)

                // المحتوى حسب التبويب
                if selectedTab == 0 {
                    TodayStatsView()
                } else {
                    AllStatsView()
                }
            }
            .padding(.horizontal, Layout.pageMargin)
            .padding(.bottom, 20)
        }
        .background(AppBackground())
        .scrollIndicators(.hidden)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
    }
}

// MARK: - عنوان "لقد أتممت ٧ سلاسل"
struct CompletedStreaksHeader: View {
    let count: Int

    // سلسلة واحدة / سلسلتين / ٣ سلاسل / ١١ سلسلة
    private var countText: String {
        switch count {
        case 1:       return "سلسلة واحدة"
        case 2:       return "سلسلتين"
        case 0, 3...10: return "\(count.arabicDigits) سلاسل"
        default:      return "\(count.arabicDigits) سلسلة"
        }
    }

    var body: some View {
        HStack(spacing: 6) {
            VStack(spacing: 0) {
                Text("لقد أتممت")
                    .font(AppFont.bold(FontSize.statsHeaderSmall))
                    .foregroundStyle(Color.black)

                Text(countText)
                    .font(AppFont.bold(FontSize.statsHeaderBig))
                    .foregroundStyle(Color.darkGreen)
            }

            Image("celeb_icon")
                .resizable()
                .scaledToFit()
                .frame(
                    width: Layout.headerIconSize,
                    height: Layout.headerIconSize
                )
        }
        .frame(maxWidth: .infinity)
        .environment(\.layoutDirection, .rightToLeft)
    }
}

// MARK: - مربع اليوم
enum DayState {
    case done
    case current
    case upcoming
}

struct DayChip: View {
    let day: Int
    let state: DayState
    var isToday = false

    var body: some View {
        VStack(spacing: 2) {
            Text("يوم")
            Text(day.arabicDigits)
        }
        .font(AppFont.bold(FontSize.dayChip))
        .foregroundStyle(state == .done ? Color.white : Color.black)
        .frame(width: 35, height: 42)
        .background(
            fillColor,
            in: RoundedRectangle(cornerRadius: 10)
        )
        .overlay(alignment: .top) {
            if state == .current || isToday {
                Image("celeb_icon")
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: Layout.celebIconSize,
                        height: Layout.celebIconSize
                    )
                    .offset(y: Layout.celebIconOffset)
            }
        }
    }

    private var fillColor: Color {
        switch state {
        case .done:
            return .darkGreen
        case .current:
            return .lightGreen
        case .upcoming:
            return .upcomingGray
        }
    }
}

// MARK: - مهمة متاحة للاختيار
struct TaskOption: Identifiable {
    let id = UUID()
    let title: String
    let reward: Int
    let detail: String
    var tag: String? = nil
}

// MARK: - الفئة
struct Category: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
    let textColor: Color
    let pillTextColor: Color
    let tasks: [TaskOption]

    // 1. التنقل
    static let transport = Category(
        name: "التنقل",
        icon: "figure.walk.motion",
        color: .darkGreen,
        textColor: .white,
        pillTextColor: .darkGreen,
        tasks: [
            TaskOption(
                title: "تنقّل بلا انبعاثات",
                reward: 30,
                detail: "استبدل رحلات السيارة القصيرة بالمشي أو الدراجة الهوائية."
            ),
            TaskOption(
                title: "امشِ إلى المسجد القريب",
                reward: 20,
                detail: "امشِ بدلاً من استخدام السيارة، حركة صحية وهواء أنقى."
            ),
            TaskOption(
                title: "استخدم النقل العام",
                reward: 25,
                detail: "اختر المترو أو الحافلة بدل السيارة الخاصة لتقليل الازدحام والانبعاثات."
            ),
            TaskOption(
                title: "ممشى بعد المغرب",
                reward: 20,
                detail: "امشِ 30 دقيقة في ممشى قريب وقت الجو المعتدل لصحة قلبك ونشاطك."
            )
        ]
    )

    // 2. التدوير
    static let recycling = Category(
        name: "التدوير",
        icon: "arrow.3.trianglepath",
        color: .lightGreen,
        textColor: .darkGreen,
        pillTextColor: .white,
        tasks: [
            TaskOption(
                title: "خطوة نحو إعادة التدوير",
                reward: 20,
                detail: "افصل البلاستيك والورق في الحاويات المخصصة لدعم التدوير."
            ),
            TaskOption(
                title: "سلّم الأجهزة القديمة",
                reward: 30,
                detail: "سلّم البطاريات والأجهزة الإلكترونية التالفة لنقاط الجمع بدل رميها."
            ),
            TaskOption(
                title: "دوّر العلب والقوارير",
                reward: 20,
                detail: "اجمع علب الألمنيوم وقوارير المياه وضعها في حاويات التدوير."
            ),
            TaskOption(
                title: "تبرّع بما لا تحتاجه",
                reward: 25,
                detail: "تبرّع بالملابس والأثاث الصالح للاستخدام لجهة خيرية بدل رميه."
            )
        ]
    )

    // 3. الطعام
    static let food = Category(
        name: "الطعام",
        icon: "fork.knife",
        color: .foodGreen,
        textColor: .inkGreen,
        pillTextColor: .white,
        tasks: [
            TaskOption(
                title: "تقليل هدر الطعام",
                reward: 15,
                detail: "استهلك البقايا، والكميات قبل انتهاء صلاحيتها لتفادي الهدر."
            ),
            TaskOption(
                title: "ولائم بلا هدر",
                reward: 30,
                detail: "حضّر للضيوف بقدر الحاجة، وقدّم الفائض لجهة خيرية لحفظ النعمة."
            ),
            TaskOption(
                title: "تمر ومكسرات",
                reward: 15,
                detail: "اجعل التمر والمكسرات وجبتك الخفيفة بدل الحلويات المصنعة."
            ),
            TaskOption(
                title: "اشترِ المنتج المحلي",
                reward: 20,
                detail: "اختر الخضار والفواكه المحلية الموسمية لطعام أطزج وبصمة كربونية أقل."
            )
        ]
    )

    // 4. تقليل الهدر
    static let waste = Category(
        name: "تقليل الهدر",
        icon: "arrow.up.bin",
        color: .creamYellow,
        textColor: .darkGreen,
        pillTextColor: .white,
        tasks: [
            TaskOption(
                title: "قارورتي معي",
                reward: 15,
                detail: "احمل قارورتك الخاصة بدل القوارير البلاستيكية، واشرب ماءً كافياً يومياً."
            ),
            TaskOption(
                title: "ترشيد المياه",
                reward: 20,
                detail: "قلّل مدة الاستحمام وأغلق الصنبور أثناء غسل الأسنان، ماء موفّر ثمين."
            ),
            TaskOption(
                title: "كيّف بذكاء",
                reward: 25,
                detail: "اضبط المكيف على 24° وأطفئه عند الخروج لتوفير الكهرباء.",
                tag: "ترشيد الطاقة"
            ),
            TaskOption(
                title: "حملة تنظيف وتشجير",
                reward: 40,
                detail: "شارك مع جيرانك في حملة تنظيف أو زراعة أشجار دعماً للسعودية الخضراء."
            )
        ]
    )

    // 5. أخرى
    static let other = Category(
        name: "أخرى",
        icon: "ellipsis.circle",
        color: .inkGreen,
        textColor: .white,
        pillTextColor: .inkGreen,
        tasks: []
    )

    // ترتيب الفئات في الدونات والقائمة
    static let all: [Category] = [
        .transport,
        .recycling,
        .food,
        .waste,
        .other
    ]
}

// MARK: - المهمة المختارة
struct TaskItem: Identifiable {
    let id = UUID()
    let category: Category
    let title: String
    let points: Int
    let completions: Int

    // بيانات تجريبية (للمعاينة فقط)
    static let walk = TaskItem(
        category: .transport,
        title: Category.transport.tasks[3].title,
        points: 15,
        completions: 25
    )

    static let sorting = TaskItem(
        category: .recycling,
        title: Category.recycling.tasks[0].title,
        points: 15,
        completions: 15
    )

    static let bottle = TaskItem(
        category: .waste,
        title: Category.waste.tasks[0].title,
        points: 35,
        completions: 35
    )

    static let foodWaste = TaskItem(
        category: .food,
        title: Category.food.tasks[0].title,
        points: 15,
        completions: 25
    )

    static let all: [TaskItem] = [
        .walk,
        .sorting,
        .bottle,
        .foodWaste
    ]
}

// MARK: - محتوى مربع الكرت الصغير
enum PillKind {
    case dailyPoints
    case completions
}

// MARK: - كرت المهمة
struct TaskCard: View {
    let task: TaskItem
    let height: CGFloat
    var kind: PillKind = .dailyPoints

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 6) {
                Image(systemName: task.category.icon)
                Text(task.category.name)
            }
            .font(AppFont.bold(FontSize.cardCategory))

            Text(task.title)
                .font(TextStyle.cardTitle)
                .multilineTextAlignment(.leading)
        }
        .foregroundStyle(task.category.textColor)
        .padding(Layout.cardInset)
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .topLeading
        )
        .frame(height: height)
        .background(
            task.category.color,
            in: RoundedRectangle(cornerRadius: 20)
        )
        .overlay(alignment: .bottomTrailing) {
            pill
                .padding(Layout.cardInset)
        }
        .environment(\.layoutDirection, .rightToLeft)
    }

    private var pillText: String {
        switch kind {
        case .dailyPoints:
            return "\(task.points.arabicDigits) نقطة خلال اليوم"
        case .completions:
            return "أنجزت المهمة \(task.completions.arabicDigits) مرة"
        }
    }

    private var pill: some View {
        Text(pillText)
            .font(AppFont.bold(FontSize.cardPill))
            .foregroundStyle(task.category.pillTextColor)
            .padding(.horizontal, 10)
            .frame(height: Layout.pillHeight)
            .background(task.category.textColor, in: Capsule())
    }
}

// MARK: - إحصائية فئة
struct CategoryStat: Identifiable {
    let category: Category
    let value: Int

    var id: UUID { category.id }

    // جمع قيم المهام لكل فئة وإظهار الفئات ذات القيمة الأكبر من صفر
    static func totals(
        from tasks: [TaskItem],
        using value: (TaskItem) -> Int
    ) -> [CategoryStat] {
        Category.all
            .map { category in
                let sum = tasks
                    .filter { $0.category.id == category.id }
                    .reduce(0) { $0 + value($1) }

                return CategoryStat(category: category, value: sum)
            }
            .filter { $0.value > 0 }
    }
}

// MARK: - مكان النسب
enum LabelPlacement {
    case outside
    case inside
}

// MARK: - الدونات
struct DonutChart: View {
    let stats: [CategoryStat]
    var size: CGFloat = Layout.donutSize
    var innerRatio: Double = 0.6
    var labelPlacement: LabelPlacement = .outside

    private struct DonutLabel: Identifiable {
        let id: UUID
        let percent: Int
        let angle: Double
        let color: Color
    }

    private var total: Int {
        stats.reduce(0) { $0 + $1.value }
    }

    private var labels: [DonutLabel] {
        guard total > 0 else { return [] }

        // نسب صحيحة مجموعها 100
        let exact = stats.map {
            Double($0.value) / Double(total) * 100
        }

        var percents = exact.map { Int($0) }
        let remainder = 100 - percents.reduce(0, +)

        let order = exact.indices.sorted {
            (exact[$0] - Double(percents[$0]))
            > (exact[$1] - Double(percents[$1]))
        }

        for index in order.prefix(remainder) {
            percents[index] += 1
        }

        var result: [DonutLabel] = []
        var running = 0.0

        for (index, stat) in stats.enumerated() {
            let fraction = Double(stat.value) / Double(total)
            let middle = running + fraction / 2

            result.append(
                DonutLabel(
                    id: stat.id,
                    percent: percents[index],
                    angle: middle * 2 * .pi,
                    color: labelPlacement == .inside
                    ? stat.category.textColor
                    : Color.darkGreen
                )
            )

            running += fraction
        }

        return result
    }

    // بُعد النسبة عن المركز
    private func labelRadius(
        outer: CGFloat,
        s: CGFloat,
        c: CGFloat
    ) -> CGFloat {
        switch labelPlacement {
        case .outside:
            let push =
                abs(s) * Layout.donutLabelHalfWidth
                + abs(c) * Layout.donutLabelHalfHeight

            return outer + Layout.donutLabelGap + push

        case .inside:
            return outer * (1 + CGFloat(innerRatio)) / 2
        }
    }

    var body: some View {
        Chart(stats) { stat in
            SectorMark(
                angle: .value("القيمة", stat.value),
                innerRadius: .ratio(innerRatio)
            )
            .foregroundStyle(stat.category.color)
        }
        .chartLegend(.hidden)
        .chartOverlay { proxy in
            GeometryReader { geo in
                if let anchor = proxy.plotFrame {
                    let plot = geo[anchor]
                    let center = CGPoint(x: plot.midX, y: plot.midY)
                    let outerRadius = min(plot.width, plot.height) / 2

                    ForEach(labels) { item in
                        let s = CGFloat(sin(item.angle))
                        let c = CGFloat(cos(item.angle))

                        let radius = labelRadius(
                            outer: outerRadius,
                            s: s,
                            c: c
                        )

                        Text("\(item.percent)%")
                            .font(AppFont.bold(FontSize.chartLabel))
                            .foregroundStyle(item.color)
                            .position(
                                x: center.x + radius * s,
                                y: center.y - radius * c
                                    + Layout.donutLabelVerticalShift
                            )
                    }
                }
            }
        }
        .frame(width: size, height: size)
        .environment(\.layoutDirection, .leftToRight)
    }
}

// MARK: - شكل القائمة
enum LegendLayout {
    case vertical
    case horizontal
}

// MARK: - قائمة الأسماء مع الدونات
struct ChartLegend: View {
    let stats: [CategoryStat]
    var layout: LegendLayout = .vertical

    var body: some View {
        switch layout {
        case .vertical:
            VStack(alignment: .leading, spacing: 16) {
                ForEach(stats) { stat in
                    item(for: stat)
                }
            }

        case .horizontal:
            // 3 فئات في كل صف
            // أول عمود يمين وآخر عمود يسار
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), alignment: .leading),
                    GridItem(.flexible(), alignment: .center),
                    GridItem(.flexible(), alignment: .trailing)
                ],
                spacing: 14
            ) {
                ForEach(
                    Array(stats.enumerated()),
                    id: \.element.id
                ) { index, stat in
                    item(for: stat)
                        .frame(
                            maxWidth: .infinity,
                            alignment: index % 3 == 0
                            ? .leading
                            : (index % 3 == 1 ? .center : .trailing)
                        )
                }
            }
            .frame(maxWidth: .infinity)
            .environment(\.layoutDirection, .rightToLeft)
        }
    }

    private func item(for stat: CategoryStat) -> some View {
        HStack(spacing: 10) {
            Circle()
                .fill(Color.darkGreen)
                .frame(width: 10, height: 10)

            Text(stat.category.name)
                .font(TextStyle.legend)
        }
    }
}

// MARK: - الدونات والقائمة لصفحة اليوم
struct StatsChartSection: View {
    let stats: [CategoryStat]

    var body: some View {
        HStack(spacing: 50) {
            DonutChart(stats: stats)
            ChartLegend(stats: stats)
        }
        .frame(maxWidth: .infinity)
        .environment(\.layoutDirection, .rightToLeft)
    }
}

// MARK: - المعاينة
#Preview {
    StatsContentView()
        .modelContainer(for: [Activity.self, Completion.self, Challenge.self], inMemory: true)
}

// معاينة كل الفئات الخمس
#Preview("ألوان الفئات") {
    VStack(spacing: 10) {
        ForEach(Category.all) { category in
            TaskCard(
                task: TaskItem(
                    category: category,
                    title: "مهمة تجريبية",
                    points: 10,
                    completions: 5
                ),
                height: Layout.cardShortHeight
            )
        }
    }
    .padding(Layout.pageMargin)
}
