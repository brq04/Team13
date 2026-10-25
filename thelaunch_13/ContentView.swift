import SwiftUI
import Charts

// MARK: - الألوان
extension Color {
    static let darkGreen    = Color(red: 89/255,  green: 107/255, blue: 82/255)   // 596B52
    static let lightGreen   = Color(red: 193/255, green: 211/255, blue: 186/255)  // C1D3BA
    static let upcomingGray = Color(red: 226/255, green: 226/255, blue: 226/255)  // E2E2E2
    static let creamYellow  = Color(red: 237/255, green: 239/255, blue: 223/255)  // تقديري، بدّليه بكودك
}

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

// MARK: - قياسات مشتركة بين كل الصفحات
enum Layout {
    static let pageMargin: CGFloat = 20          // هامش الصفحة يمين ويسار
    static let cardTallHeight: CGFloat = 159     // الكرت الطويل
    static let cardShortHeight: CGFloat = 84     // الكرت القصير (كان 78)
    static let cardSpacing: CGFloat = 14         // المسافة بين الكروت (تقديرية)
    static let cardInset: CGFloat = 10           // بعد المحتوى ومربع النقاط عن حواف الكرت
    static let pillHeight: CGFloat = 20          // ارتفاع مربع النقاط (موحد)

    // الدونات (صفحة اليوم)
    static let donutSize: CGFloat = 112              // قطر الدونات (تقديري)
    static let donutLabelGap: CGFloat = 0            // ← بُعد النسب عن الحلقة (كبّريه تبعد، صغّريه تقرب)
    static let donutLabelVerticalShift: CGFloat = 2  // ← تعويض الخط العربي (ينزّل كل النسب شوي)
    static let donutLabelHalfWidth: CGFloat = 14     // نصف عرض النسبة تقريباً
    static let donutLabelHalfHeight: CGFloat = 8     // نصف ارتفاع النسبة تقريباً

    // صورة الاحتفال فوق يوم السلسلة
    static let celebIconSize: CGFloat = 24       // حجم الصورة (تقديري)
    static let celebIconOffset: CGFloat = -12    // رفعها فوق مربع اليوم (تقديري)

    // صفحة جميع الإحصائيات (كلها تقديرية من التصميم)
    static let bigDonutSize: CGFloat = 190       // قطر الدونات الكبيرة
    static let bigDonutInnerRatio: Double = 0.66 // حجم الفتحة (أكبر = حلقة أنحف)
    static let headerIconSize: CGFloat = 50      // صورة "لقد أتممت"
    static let allStatsHeaderTop: CGFloat = 30   // تحت التبويب
    static let allStatsDonutTop: CGFloat = 32    // تحت العنوان
    static let allStatsLegendTop: CGFloat = 26   // تحت الدونات
    static let allStatsCardsTop: CGFloat = 42    // تحت القائمة
}

// MARK: - أحجام الخطوط (كلها في مكان واحد، أصغر خط 11)
enum FontSize {
    static let tab: CGFloat = 14               // التبويب
    static let streakTitle: CGFloat = 20       // "يوم 4"
    static let streakSubtitle: CGFloat = 16    // "سلستك الحالية"
    static let edit: CGFloat = 16              // "تعديل"
    static let dayChip: CGFloat = 12           // "يوم" والرقم داخل المربع
    static let cardCategory: CGFloat = 12      // اسم الفئة (تقديري)
    static let cardTitle: CGFloat = 14         // نص المهمة (تقديري)
    static let cardPill: CGFloat = 11          // نص مربع النقاط
    static let chartLabel: CGFloat = 11        // النسبة على الدونات
    static let legend: CGFloat = 14            // أسماء القائمة (تقديري)
    static let statsHeaderSmall: CGFloat = 17  // "لقد أتممت" (تقديري)
    static let statsHeaderBig: CGFloat = 30    // "٧ سلاسل" (تقديري)
}

// MARK: - الشاشة الرئيسية (التبويب + المحتوى حسب التبويب)
struct ContentView: View {

    @State private var selectedTab = 0

    let tabs = ["إحصائيات اليوم", "جميع الإحصائيات"]

    var body: some View {
        ScrollView {
            VStack {

                // التبويب
                HStack(spacing: 0) {
                    ForEach(tabs.indices, id: \.self) { index in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedTab = index
                            }
                        } label: {
                            Text(tabs[index])
                                .font(.custom("GeezaPro-Bold", size: FontSize.tab))
                                .foregroundStyle(selectedTab == index ? Color.white : Color.darkGreen)
                                .frame(maxWidth: .infinity)
                                .frame(height: 40)
                                .background(selectedTab == index ? Color.darkGreen : Color.clear, in: Capsule())
                                .contentShape(Rectangle())
                        }
                    }
                }
                .buttonStyle(.plain)
                .padding(4)
                .background(Color.white, in: Capsule())
                .frame(height: 48)
                .environment(\.layoutDirection, .rightToLeft)
                .padding(.top, 40)

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
        .scrollIndicators(.hidden)
    }
}

// MARK: - صفحة إحصائيات اليوم
struct TodayStatsView: View {

    // الدونات تنحسب من نقاط اليوم في الكروت
    private let stats = CategoryStat.totals(from: TaskItem.all) { $0.points }

    var body: some View {
        VStack(spacing: 0) {

            // كرت السلسلة
            StreakCard(currentDay: 4)
                .padding(.top, 45)

            // الدونات
            StatsChartSection(stats: stats)
                .padding(.top, 32)

            // كروت المهام (نقاط اليوم)
            TasksGrid(kind: .dailyPoints)
                .padding(.top, 43)
        }
    }
}

// MARK: - صفحة جميع الإحصائيات
struct AllStatsView: View {

    // الدونات تنحسب من عدد مرات إنجاز كل مهمة في الكروت
    private let stats = CategoryStat.totals(from: TaskItem.all) { $0.completions }

    var body: some View {
        VStack(spacing: 0) {

            // العنوان: لقد أتممت ٧ سلاسل
            CompletedStreaksHeader(count: 7)
                .padding(.top, Layout.allStatsHeaderTop)

            // الدونات الكبيرة (النسب داخل الحلقة)
            DonutChart(
                stats: stats,
                size: Layout.bigDonutSize,
                innerRatio: Layout.bigDonutInnerRatio,
                labelPlacement: .inside
            )
            .padding(.top, Layout.allStatsDonutTop)

            // القائمة الأفقية
            ChartLegend(stats: stats, layout: .horizontal)
                .padding(.top, Layout.allStatsLegendTop)

            // كروت المهام (كم مرة أنجزتها)
            TasksGrid(kind: .completions)
                .padding(.top, Layout.allStatsCardsTop)
        }
    }
}

// MARK: - عنوان "لقد أتممت ٧ سلاسل"
struct CompletedStreaksHeader: View {
    let count: Int   // لاحقاً من الـbackend (ملاحظة: "سلاسل" صحيحة للأعداد من 3 إلى 10 فقط، نعدلها وقت الربط)

    var body: some View {
        HStack(spacing: 6) {
            VStack(spacing: 0) {
                Text("لقد أتممت")
                    .font(.custom("GeezaPro-Bold", size: FontSize.statsHeaderSmall))
                    .foregroundStyle(Color.black)
                Text("\(count.arabicDigits) سلاسل")
                    .font(.custom("GeezaPro-Bold", size: FontSize.statsHeaderBig))
                    .foregroundStyle(Color.darkGreen)
            }
            Image("celeb_icon")
                .resizable()
                .scaledToFit()
                .frame(width: Layout.headerIconSize, height: Layout.headerIconSize)
        }
        .frame(maxWidth: .infinity)
        .environment(\.layoutDirection, .rightToLeft)
    }
}

// MARK: - كرت السلسلة (المستطيل الأخضر + البوكس الأبيض)
struct StreakCard: View {
    let currentDay: Int
    let totalDays = 7
    var onEditTap: () -> Void = {}   // لاحقاً نربطه بصفحة التعديل

    var body: some View {
        VStack(spacing: 0) {

            // الجزء العلوي (يمين: العنوان / يسار: تعديل)
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("يوم \(currentDay)")
                        .font(.custom("GeezaPro-Bold", size: FontSize.streakTitle))
                    Text("سلستك الحاليه \(totalDays) ايام متتالية 🌿")
                        .font(.custom("GeezaPro", size: FontSize.streakSubtitle))
                }

                Spacer()

                Button("تعديل", action: onEditTap)
                    .font(.custom("GeezaPro-Bold", size: FontSize.edit))
                    .foregroundStyle(Color.darkGreen)
            }

            Spacer(minLength: 0)

            // البوكس الأبيض (الأيام السبعة)
            HStack(spacing: 9) {
                ForEach(1...totalDays, id: \.self) { day in
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
        if day < currentDay { return .done }
        if day == currentDay { return .current }
        return .upcoming
    }
}

// MARK: - مربع اليوم
enum DayState {
    case done       // يوم خلص
    case current    // اليوم الحالي
    case upcoming   // يوم جاي
}

struct DayChip: View {
    let day: Int
    let state: DayState

    var body: some View {
        VStack(spacing: 2) {
            Text("يوم")
            Text("\(day)")
        }
        .font(.custom("GeezaPro-Bold", size: FontSize.dayChip))
        .foregroundStyle(state == .done ? Color.white : Color.black)
        .frame(width: 35, height: 42)
        .background(fillColor, in: RoundedRectangle(cornerRadius: 10))
        // صورة الاحتفال فوق اليوم الحالي فقط
        .overlay(alignment: .top) {
            if state == .current {
                Image("celeb_icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: Layout.celebIconSize, height: Layout.celebIconSize)
                    .offset(y: Layout.celebIconOffset)
            }
        }
    }

    private var fillColor: Color {
        switch state {
        case .done:     return .darkGreen
        case .current:  return .lightGreen
        case .upcoming: return .upcomingGray
        }
    }
}

// MARK: - الفئة (التنقل / الهدر / إعادة التدوير)
struct Category: Identifiable {
    let id = UUID()
    let name: String
    let icon: String            // مؤقتاً من SF Symbols، لاحقاً أيقوناتك
    let color: Color            // لون الكرت (ونفسه لون الدونات)
    let textColor: Color        // لون النص فوق الكرت (ولون خلفية مربع النقاط)
    let pillTextColor: Color    // لون النص داخل مربع النقاط
    let options: [String]       // المهام المتاحة لهالفئة

    static let transport = Category(
        name: "التنقل", icon: "figure.walk.motion",
        color: .darkGreen, textColor: .white, pillTextColor: .darkGreen,
        options: ["المشي في الهواء الطلق", "ركوب الدراجة بدل السيارة"]
    )
    static let waste = Category(
        name: "الهدر", icon: "arrow.up.bin",
        color: .creamYellow, textColor: .darkGreen, pillTextColor: .white,
        options: ["تقليل هدر الطعام"]
    )
    static let recycling = Category(
        name: "إعادة التدوير", icon: "arrow.3.trianglepath",
        color: .lightGreen, textColor: .darkGreen, pillTextColor: .white,
        options: ["عزل البلاستيك والورق في الخانات المخصصة"]
    )

    // كل الفئات بالترتيب (الدونات والقائمة تمشي عليه)
    static let all: [Category] = [.transport, .waste, .recycling]
}

// MARK: - المهمة
struct TaskItem: Identifiable {
    let id = UUID()
    let category: Category
    let title: String      // يجي لاحقاً من الصفحة الثانية
    let points: Int        // نقاط اليوم، تجي لاحقاً من الـbackend
    let completions: Int   // كم مرة أنجزت المهمة (صفحة جميع الإحصائيات)

    // بيانات تجريبية
    static let walk    = TaskItem(category: .transport, title: Category.transport.options[0], points: 15, completions: 25)
    static let bike    = TaskItem(category: .transport, title: Category.transport.options[1], points: 15, completions: 25)
    static let food    = TaskItem(category: .waste,     title: Category.waste.options[0],     points: 35, completions: 35)
    static let sorting = TaskItem(category: .recycling, title: Category.recycling.options[0], points: 15, completions: 15)

    // كل المهام (الدونات تحسب منها)
    static let all: [TaskItem] = [.walk, .bike, .food, .sorting]
}

// MARK: - وش يظهر داخل مربع الكرت الصغير؟
enum PillKind {
    case dailyPoints    // "١٥ نقطة خلال اليوم"
    case completions    // "أنجزت المهمة ٢٥ مرة"
}

// MARK: - كرت المهمة
struct TaskCard: View {
    let task: TaskItem
    let height: CGFloat
    var kind: PillKind = .dailyPoints

    var body: some View {
        // المحتوى (فوق يمين)
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 6) {
                Image(systemName: task.category.icon)
                Text(task.category.name)
            }
            .font(.custom("GeezaPro-Bold", size: FontSize.cardCategory))

            Text(task.title)
                .font(.custom("GeezaPro", size: FontSize.cardTitle))
                .multilineTextAlignment(.leading)
        }
        .foregroundStyle(task.category.textColor)
        .padding(Layout.cardInset)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .frame(height: height)
        .background(task.category.color, in: RoundedRectangle(cornerRadius: 20))
        // مربع صغير مثبت على حافة الكرت (تحت يسار)
        .overlay(alignment: .bottomTrailing) {
            pill
                .padding(Layout.cardInset)
        }
        .environment(\.layoutDirection, .rightToLeft)
    }

    private var pillText: String {
        switch kind {
        case .dailyPoints: return "\(task.points.arabicDigits) نقطة خلال اليوم"
        case .completions: return "أنجزت المهمة \(task.completions.arabicDigits) مرة"
        }
    }

    private var pill: some View {
        Text(pillText)
            .font(.custom("GeezaPro-Bold", size: FontSize.cardPill))
            .foregroundStyle(task.category.pillTextColor)
            .padding(.horizontal, 10)
            .frame(height: Layout.pillHeight)
            .background(task.category.textColor, in: Capsule())
    }
}

// MARK: - شبكة كروت المهام
struct TasksGrid: View {
    var kind: PillKind = .dailyPoints

    var body: some View {
        HStack(alignment: .top, spacing: Layout.cardSpacing) {
            // العمود الأيمن
            VStack(spacing: Layout.cardSpacing) {
                TaskCard(task: .walk, height: Layout.cardShortHeight, kind: kind)
                TaskCard(task: .sorting, height: Layout.cardTallHeight, kind: kind)
            }
            // العمود الأيسر
            VStack(spacing: Layout.cardSpacing) {
                TaskCard(task: .food, height: Layout.cardTallHeight, kind: kind)
                TaskCard(task: .bike, height: Layout.cardShortHeight, kind: kind)
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
}

// MARK: - إحصائية فئة (قيمتها نقاط اليوم أو مرات الإنجاز حسب الصفحة)
struct CategoryStat: Identifiable {
    let category: Category
    let value: Int

    var id: UUID { category.id }

    // يجمع قيمة المهام لكل فئة (مثلاً التنقل = المشي + الدراجة)
    static func totals(from tasks: [TaskItem], using value: (TaskItem) -> Int) -> [CategoryStat] {
        Category.all.map { category in
            let sum = tasks
                .filter { $0.category.id == category.id }
                .reduce(0) { $0 + value($1) }
            return CategoryStat(category: category, value: sum)
        }
    }
}

// MARK: - مكان النسب: خارج الحلقة أو داخلها
enum LabelPlacement {
    case outside
    case inside
}

// MARK: - الدونات
struct DonutChart: View {
    let stats: [CategoryStat]
    var size: CGFloat = Layout.donutSize
    var innerRatio: Double = 0.6                 // أكبر = حلقة أنحف
    var labelPlacement: LabelPlacement = .outside

    // موقع كل نسبة: رقمها وزاويتها (من فوق مع عقارب الساعة) ولونها
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

        // نسب صحيحة مجموعها 100 بالضبط (الباقي يتوزع على أكبر الكسور)
        let exact = stats.map { Double($0.value) / Double(total) * 100 }
        var percents = exact.map { Int($0) }
        let remainder = 100 - percents.reduce(0, +)
        let order = exact.indices.sorted {
            (exact[$0] - Double(percents[$0])) > (exact[$1] - Double(percents[$1]))
        }
        for index in order.prefix(remainder) {
            percents[index] += 1
        }

        var result: [DonutLabel] = []
        var running = 0.0
        for (index, stat) in stats.enumerated() {
            let fraction = Double(stat.value) / Double(total)
            let middle = running + fraction / 2          // منتصف الشريحة
            result.append(
                DonutLabel(
                    id: stat.id,
                    percent: percents[index],
                    angle: middle * 2 * .pi,
                    color: labelPlacement == .inside ? stat.category.textColor : Color.darkGreen
                )
            )
            running += fraction
        }
        return result
    }

    // بعد النسبة عن المركز
    private func labelRadius(outer: CGFloat, s: CGFloat, c: CGFloat) -> CGFloat {
        switch labelPlacement {
        case .outside:
            // نزيح النص بحسب اتجاهه عشان تتساوى المسافة بين حافته والحلقة
            let push = abs(s) * Layout.donutLabelHalfWidth + abs(c) * Layout.donutLabelHalfHeight
            return outer + Layout.donutLabelGap + push
        case .inside:
            // في منتصف سماكة الحلقة
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
                    let plot = geo[anchor]                                  // مساحة الحلقة الفعلية
                    let center = CGPoint(x: plot.midX, y: plot.midY)
                    let outerRadius = min(plot.width, plot.height) / 2

                    ForEach(labels) { item in
                        let s = CGFloat(sin(item.angle))
                        let c = CGFloat(cos(item.angle))
                        let radius = labelRadius(outer: outerRadius, s: s, c: c)

                        Text("\(item.percent)%")
                            .font(.custom("GeezaPro-Bold", size: FontSize.chartLabel))
                            .foregroundStyle(item.color)
                            .position(
                                x: center.x + radius * s,
                                y: center.y - radius * c + Layout.donutLabelVerticalShift
                            )
                    }
                }
            }
        }
        .frame(width: size, height: size)
        .environment(\.layoutDirection, .leftToRight)   // عشان الرسم يبدأ من فوق مع عقارب الساعة بدون ما ينقلب
    }
}

// MARK: - شكل القائمة: عمودية أو أفقية
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
            HStack(spacing: 0) {
                ForEach(stats) { stat in
                    item(for: stat)
                        .frame(maxWidth: .infinity)
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
                .font(.custom("GeezaPro-Bold", size: FontSize.legend))
        }
    }
}

// MARK: - قسم الإحصائيات (الدونات + القائمة) لصفحة اليوم
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

#Preview {
    ContentView()
}
