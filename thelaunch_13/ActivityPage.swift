import SwiftUI
import SwiftData

// MARK: - الأنشطة الأولية (تنحفظ بالقاعدة أول تشغيل فقط)
var sampleActivities: [Activity] { [
    // الجولة الأولى
    Activity(.food, "نعمة محفوظة", "استهلك وجباتك بوعي واقتصر على قدر حاجتك، حفظاً للنعمة وترشيداً للاستهلاك", 15, tag: "ترشيد الغذاء"),
    Activity(.transport, "خُطى نقية", "استبدل المركبة بالمشي للمسافات القريبة، لتقليل الانبعاثات وتعزيز الصحة البدنية", 30, tag: "تنقل نظيف"),
    Activity(.recycle, "فرز من المصدر", "خصص حاويات لفرز الورق والبلاستيك في منزلك، دعماً لعملية إعادة التدوير", 20, tag: "فرز النفايات"),
    Activity(.waste, "حدّ من البلاستيك", "استخدم القارورة المستدامة بدلاً من المنتجات البلاستيكية أحادية الاستخدام", 15, tag: "تقليل البلاستيك"),

    // الجولة الثانية
    Activity(.food, "حفظ النعمة", "قدّم الضيافة بقدر الحاجة، وساهم في توجيه الفائض عبر المنصات والمؤسسات المعتمدة", 30, tag: "حفظ النعمة"),
    Activity(.transport, "المشي إلى المسجد", "التزم بالمشي أداءً للعبادة وتعزيزاً للنشاط البدني ونقاء البيئة المحيطة", 20, tag: "حياة صحية"),
    Activity(.recycle, "التخلص الآمن من الإلكترونيات", "سلّم البطاريات والأجهزة التالفة لمراكز الجمع المخصصة لمنع التلوث البيئي", 30, tag: "نفايات إلكترونية"),
    Activity(.waste, "ترشيد استهلاك المياه", "أغلق صنبور المياه أثناء تنظيف الأسنان لتجنب هدر الموارد المائية", 20, tag: "ترشيد المياه"),

    // الجولة الثالثة
    Activity(.food, "خيارات غذائية مستدامة", "استبدل الأطعمة المصنعة بالمنتجات الطبيعية كالتمر والمكسرات لدعم الصحة والبيئة", 15, tag: "غذاء صحي"),
    Activity(.transport, "استخدام النقل العام", "اعتمد على المترو أو الحافلات في تنقلاتك لتقليل الازدحام المروري والبصمة الكربونية", 25, tag: "نقل عام"),
    Activity(.recycle, "تدوير العبوات", "اجمع العلب المعدنية والزجاجية واكفل وضعها في حاويات إعادة التدوير", 20, tag: "تدوير العبوات"),
    Activity(.waste, "كفاءة الطاقة", "اضبط أجهزة التكييف على درجة ٢٤° مئوية وأغلقها عند مغادرة المكان لترشيد الطاقة", 25, tag: "ترشيد الطاقة"),

    // الجولة الرابعة
    Activity(.food, "دعم المنتجات المحلية", "اختر المنتجات الزراعية المحلية الموسمية لتقليل التكاليف البيئية لعمليات النقل", 20, tag: "منتج محلي"),
    Activity(.transport, "ممارسة المشي اليومي", "خصص ٣٠ دقيقة يومياً للمشي في المسارات المخصصة لتعزيز جودة الحياة", 20, tag: "حياة صحية"),
    Activity(.recycle, "المساهمة المجتمعية", "تبرع بالملابس والأثاث الصالح للاستخدام لدعم الفئات المستحقة وتعزيز التدوير", 25, tag: "عمل مجتمعي"),
    Activity(.waste, "مبادرة السعودية الخضراء", "شارك في حملات التشجير والنظافة البيئية تسهم في تحقيق أهداف الاستدامة الوطنية", 40, tag: "السعودية الخضراء"),
]}

// MARK: - الشاشة الرئيسية
struct Activitypage: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Activity.createdAt) private var activities: [Activity]

    @State private var filter: ActivityCategory = .all
    @State private var selected: Set<UUID> = []
    @State private var days = 1
    @State private var showAdd = false
    @State private var confirmed = false
    @Environment(\.dismiss) private var dismiss
    @Query private var challenges: [Challenge]

    private var activeSelection: (ids: Set<UUID>, days: Int)? {
        Backend.activeSelection(challenges)
    }
    private var isEditing: Bool { activeSelection != nil }
    
    var body: some View {
        let visible = activities.filter {
            filter == .all ||
            $0.category == filter ||
            (filter == .other && $0.isCustom)
        }

        return ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {

                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.darkGreen)
                            .frame(width: 46, height: 46)
                            .background(Circle().fill(Color(hex: "#E6EAE3")))
                    }

                    Spacer()
                }
                .padding(.top, 14)

                Text("سجل أنشطتك")
                    .font(AppFont.title(32))
                    .foregroundColor(.ink)
                    .padding(.top, 22)

                Text("عادات الأستدامة اليومية")
                    .font(AppFont.custom(18, .medium))
                    .foregroundColor(.softGray)

                Tabs(selection: $filter)
                    .padding(.top, 20)

                LazyVStack(spacing: 18) {
                    ForEach(visible, id: \.id) { a in
                        let look = a.category.look
                        Card(icon: look.icon, color: look.color, bg: look.bg, tags: [a.tag ?? look.tag, "+" + arabic(a.points) + " نقطة"],
                             title: a.title, details: a.details, isOn: selected.contains(a.id))
                            .onTapGesture { toggle(a.id) }
                    }
                    if filter == .all || filter == .other {
                        Card(icon: "square.and.pencil", color: .darkGreen, bg: Color.lightGreen.opacity(0.5),
                             title: "أخرى", details: "أضف نشاطًا مستدامًا من اختيارك", dashed: true)
                            .onTapGesture { showAdd = true }
                    }
                }
                .padding(.top, 24)

                if !isEditing {
                    durationRow
                        .padding(.top, 22)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .background(ScreenBackground())
        .safeAreaInset(edge: .bottom) {
            GreenButton(text: isEditing ? "حفظ التعديل" : "تأكيد", size: 24, isOn: !selected.isEmpty) { confirm() }
                .padding(.horizontal, 57)
                .padding(.vertical, 12)
                .background(LinearGradient(colors: [.clear, Color(hex: "#F7F6F2")], startPoint: .top, endPoint: .center).ignoresSafeArea())
        }
        .environment(\.layoutDirection, .rightToLeft)
        .sheet(isPresented: $showAdd) {
            AddSheet { title, details, category in add(title, details, category) }
                .environment(\.layoutDirection, .rightToLeft)
        }
        
        .alert(isEditing ? "تم حفظ التعديل 🌿" : "تم تسجيل أنشطتك 🌿", isPresented: $confirmed) {
            Button("حسنًا", role: .cancel) { dismiss() }
        }
        
        .task { Backend.seedIfNeeded(context, with: sampleActivities) }
        .onAppear {
            guard selected.isEmpty else { return }
            if let s = activeSelection {
                selected = s.ids
                days = s.days
            } else if let first = activities.first {
                selected = [first.id]
            }
        }
    }

    private var durationRow: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("تحديد مدة الهدف").font(AppFont.title(20)).foregroundColor(.ink)
                Text("المدة اليومية للألتزام").font(AppFont.text(13)).foregroundColor(.softGray)
            }
            Spacer()

            HStack(spacing: 6) {
                stepButton("plus", 1)

                Text(arabic(days) + (days == 1 ? " يوم" : (days <= 10 ? " أيام" : " يومًا")))
                    .font(AppFont.custom(17, .bold))
                    .foregroundColor(.darkGreen)
                    .frame(minWidth: 55, alignment: .center)

                stepButton("minus", -1)
            }
            .environment(\.layoutDirection, .leftToRight)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.sage.opacity(0.6), lineWidth: 1.2))
        }
    }

    private func stepButton(_ symbol: String, _ change: Int) -> some View {
        Button {
            days = min(30, max(1, days + change))
        } label: {
            Image(systemName: symbol)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.darkGreen)
                .frame(width: 32, height: 32)
        }
    }

    private func toggle(_ id: UUID) { if !selected.insert(id).inserted { selected.remove(id) } }

    // يحفظ النشاط الجديد بالقاعدة
    private func add(_ title: String, _ details: String, _ category: ActivityCategory) {
        let new = Activity(category, title, details.isEmpty ? "نشاط مستدام أضفته بنفسك" : details, 10, tag: category.rawValue, custom: true)
        context.insert(new)
        selected.insert(new.id)
    }

    // زر التأكيد: يسجل إنجاز اليوم ويبدأ/يكمل السلسلة
    private func confirm() {
        Backend.confirm(activities.filter { selected.contains($0.id) }, days: days, in: context)
        if !isEditing { selected = [] }
        confirmed = true
    }
}

// MARK: - العناصر
struct Tabs: View {
    @Binding var selection: ActivityCategory
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(ActivityCategory.allCases, id: \.self) { c in
                        Text(c.rawValue)
                            .font(AppFont.custom(16, .bold))
                            .foregroundColor(selection == c ? Color.white : Color.darkGreen)
                            .padding(.horizontal, 18)
                            .frame(height: 42)
                            .background(Capsule().fill(selection == c ? Color.darkGreen : Color.clear))
                            .id(c)
                            .onTapGesture {
                                withAnimation {
                                    selection = c
                                    proxy.scrollTo(c, anchor: .center)
                                }
                            }
                    }
                }
                .padding(4)
            }
        }
        .clipShape(Capsule())
        .background(Capsule().fill(Color.white))
    }
}

// MARK: - الكارد
struct Card: View {
    let icon: String, color: Color, bg: Color
    var tags: [String] = []
    let title: String, details: String
    var isOn = false, dashed = false

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            IconBadge(icon: icon, color: color, bg: bg)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 8) {
                    ForEach(tags, id: \.self) { tag in
                        Text(tag)
                            .font(AppFont.custom(12, .semibold))
                            .foregroundColor(.ink)
                            .padding(.horizontal, 12)
                            .frame(height: 26)
                            .background(Capsule().fill(Color.white))
                            .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
                    }
                }

                Text(title)
                    .font(AppFont.title(18))
                    .foregroundColor(.ink)
                    .minimumScaleFactor(0.8)
                    .lineLimit(2)

                Text(details)
                    .font(AppFont.text(12))
                    .foregroundColor(.softGray)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: isOn ? "checkmark.circle.fill" : "plus.circle")
                .font(.system(size: 28, weight: .light))
                .foregroundColor(isOn ? Color.darkGreen : Color.softGray)
        }
        .padding(14)
        .frame(minHeight: 100)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.cream))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.sage, style: StrokeStyle(lineWidth: 1, dash: dashed ? [5, 4] : [])))
    }
}

struct IconBadge: View {
    let icon: String, color: Color, bg: Color
    var size: CGFloat = 48
    var body: some View {
        RoundedRectangle(cornerRadius: size * 0.26)
            .fill(bg)
            .frame(width: size, height: size)
            .overlay(
                Image(systemName: icon)
                    .font(.system(size: size * 0.46, weight: .medium))
                    .foregroundColor(color)
            )
    }
}

struct GreenButton: View {
    let text: String, size: CGFloat, isOn: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(text).font(AppFont.title(size)).foregroundColor(isOn ? Color.white : Color.ink.opacity(0.3))
                .frame(maxWidth: .infinity).frame(height: 50)
                .background(RoundedRectangle(cornerRadius: 16).fill(isOn ? Color.darkGreen : Color.lightGreen.opacity(0.5)))
                .shadow(color: Color.darkGreen.opacity(isOn ? 0.35 : 0), radius: 10, y: 5)
        }.disabled(!isOn)
    }
}

struct AddSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var details = ""
    @State private var type: ActivityCategory = .other
    let onAdd: (String, String, ActivityCategory) -> Void
    var body: some View {
        let name = title.trimmingCharacters(in: .whitespacesAndNewlines)
        VStack(alignment: .leading, spacing: 14) {
            Text("إضافة نشاط").font(AppFont.title(22)).foregroundColor(.ink).padding(.top, 8)
            Text("سجّل نشاطًا مستدامًا من اختيارك").font(AppFont.text(13)).foregroundColor(.softGray)
            TextField("اسم النشاط", text: $title).inputStyle()
            TextField("وصف مختصر (اختياري)", text: $details).inputStyle()
            Text("نوع النشاط").font(AppFont.title(16)).foregroundColor(.ink).padding(.top, 4)
            HStack(spacing: 8) {
                ForEach(ActivityCategory.allCases.filter { $0 != .all }, id: \.self) { c in
                    VStack(spacing: 6) {
                        IconBadge(icon: c.look.icon, color: c.look.color, bg: c.look.bg, size: 38)
                        Text(c.rawValue).font(AppFont.title(12)).foregroundColor(.ink).lineLimit(1).minimumScaleFactor(0.7)
                    }
                    .frame(maxWidth: .infinity).padding(.vertical, 10)
                    .background(RoundedRectangle(cornerRadius: 14).fill(type == c ? Color.cream : Color.white))
                    .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(type == c ? Color.darkGreen : Color.lightGreen, lineWidth: 1.5))
                    .onTapGesture { type = c }
                }
            }
            Spacer(minLength: 0)
            GreenButton(text: "إضافة", size: 20, isOn: !name.isEmpty) {
                onAdd(name, details.trimmingCharacters(in: .whitespacesAndNewlines), type)
                dismiss()
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .presentationBackground { ScreenBackground() }
        .presentationDetents([.fraction(0.62), .large])
    }
}

// MARK: - أدوات مساعدة
struct ScreenBackground: View {
    var body: some View {
        ZStack {
            Color(hex: "#F7F6F2")
            RadialGradient(colors: [Color(hex: "#DCE6E6"), .clear], center: .topTrailing, startRadius: 0, endRadius: 420)
            RadialGradient(colors: [Color(hex: "#ECEAE4"), .clear], center: .bottom, startRadius: 0, endRadius: 380)
        }.ignoresSafeArea()
    }
}

extension View {
    func inputStyle() -> some View {
        self.font(AppFont.text(16)).foregroundColor(.ink).multilineTextAlignment(.leading)
            .padding(.horizontal, 14).frame(height: 50).background(RoundedRectangle(cornerRadius: 14).fill(Color.white))
            .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.lightGreen))
    }
}

func arabic(_ number: Int) -> String {
    let digits = Array("٠١٢٣٤٥٦٧٨٩")
    return String(String(number).compactMap { $0.wholeNumberValue }.map { digits[$0] })
}

#Preview {
    Activitypage()
        .modelContainer(for: [Activity.self, Completion.self, Challenge.self], inMemory: true)
}
