import SwiftUI
import SwiftData

// MARK: - الأنشطة الأولية (تنحفظ بالقاعدة أول تشغيل فقط)
var sampleActivities: [Activity] { [
    // التنقل
    Activity(.transport, "استخدام النقل العام", "استخدم المترو أو الحافلة بدلًا من سيارتك.", 25, tag: "تنقل نظيف"),
    Activity(.transport, "المشي بدلًا من القيادة", "اذهب إلى وجهتك سيرًا بدلًا من القيادة.", 30, tag: "تنقل نظيف"),

    // التدوير
    Activity(.recycle, "فرز النفايات", "افصل المواد القابلة لإعادة التدوير.", 20, tag: "فرز النفايات"),
    Activity(.recycle, "التخلّص الآمن من الأجهزة الإلكترونية", "سلّم الأجهزة والبطاريات إلى نقاط الجمع.", 30, tag: "نفايات إلكترونية"),
    Activity(.recycle, "الحدّ من استخدام البلاستيك", "استخدم بدائل قابلة لإعادة الاستخدام.", 15, tag: "تقليل البلاستيك"),
    Activity(.recycle, "المساهمة المجتمعية", "تبرّع بما لا تحتاج إليه من ملابس وأثاث.", 25, tag: "عمل مجتمعي"),

    // الطعام
    Activity(.food, "إعداد كميات مناسبة", "أعدّ من الطعام قدر حاجتك فقط.", 15, tag: "ترشيد الغذاء"),
    Activity(.food, "الاستفادة من بقايا الطعام", "حوّل البقايا الصالحة إلى وجبة جديدة.", 20, tag: "حفظ النعمة"),
    Activity(.food, "التخطيط لشراء الطعام", "دوّن قائمة مشترياتك قبل التسوّق.", 20, tag: "حفظ النعمة"),
    Activity(.food, "استخدام الأطعمة الأقرب انتهاءً", "استهلك الأقرب انتهاءً أولًا.", 20, tag: "حفظ النعمة"),

    // ترشيد الاستهلاك
    Activity(.waste, "ترشيد استهلاك المياه", "استخدم المياه بقدر حاجتك فقط.", 20, tag: "ترشيد المياه"),
    Activity(.waste, "إطفاء الأنوار غير المستخدمة", "أطفئ الأنوار عند مغادرة الغرفة.", 15, tag: "ترشيد الطاقة"),
    Activity(.waste, "إطفاء المكيّف عند الخروج", "أطفئ المكيّف قبل مغادرة المنزل.", 25, tag: "ترشيد الطاقة"),

    // أخرى
    Activity(.other, "مبادرة السعودية الخضراء", "شارك في حملات التشجير والنظافة.", 40, tag: "السعودية الخضراء"),
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
    @State private var detailActivity: Activity?
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @Environment(\.dismiss) private var dismiss
    @Query private var challenges: [Challenge]
    @State private var swipedActivityID: UUID?
    @State private var showDeleteConfirmation = false
    @State private var activityToDelete: Activity?
    
    private var activeSelection: (ids: Set<UUID>, days: Int, plannedToday: Bool)? {
        Backend.activeSelection(challenges)
    }
    private var hasChallenge: Bool { activeSelection != nil }                    // فيه سلسلة شغالة
    private var isEditing: Bool { activeSelection?.plannedToday ?? false }       // أضافت أنشطة اليوم وتعدّلها
    
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
                    }
                    .buttonStyle(.glass)
                    .buttonBorderShape(.circle)
                    .controlSize(.large)

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

                        ZStack(alignment: .trailing) {

                            // Delete button - only for custom activities
                            if a.isCustom {
                                Button {
                                    activityToDelete = a
                                    showDeleteConfirmation = true
                                } label: {
                                    Image(systemName: "trash")
                                        .font(.system(size: 22))
                                        .foregroundStyle(.white)
                                        .frame(width: 70, height: 100)
                                        .background(.red, in:
                                            RoundedRectangle(cornerRadius: 16))
                                }
                                .buttonStyle(.plain)
                            }

                            // Your existing activity card
                            Card(
                                icon: look.icon,
                                color: look.color,
                                bg: look.bg,
                                tags: [
                                    a.category.rawValue,
                                    "+" + arabic(a.points) + " نقطة"
                                ],
                                title: a.title,
                                details: a.details,
                                isOn: selected.contains(a.id),
                                plain: a.isCustom,
                                onInfo: a.isCustom ? nil : {
                                    detailActivity = a
                                }
                            )
                            .environment(\.layoutDirection, .rightToLeft)
                            .frame(maxWidth: .infinity)
                            .offset(x: swipedActivityID == a.id ? -76 : 0)
                            .onTapGesture {
                                if swipedActivityID == a.id {
                                    swipedActivityID = nil
                                } else {
                                    toggle(a.id)
                                }
                            }
                            .simultaneousGesture(
                                DragGesture(minimumDistance: 30)
                                    .onEnded { value in
                                        guard a.isCustom else { return }

                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            if value.translation.width < -50 {
                                                swipedActivityID = a.id
                                            } else if value.translation.width > 50 {
                                                swipedActivityID = nil
                                            }
                                        }
                                    }
                            )
                        }
                        .environment(\.layoutDirection, .leftToRight)
                    }

                    if filter == .all || filter == .other {
                        Card(icon: "square.and.pencil", color: .darkGreen, bg: Color.lightGreen.opacity(0.5),
                             title: "أخرى", details: "أضف نشاطًا مستدامًا من اختيارك", dashed: true)
                            .onTapGesture { showAdd = true }
                    }
                }
                .padding(.top, 24)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
            
            
            
        }
        
        .background(AppBackground())

      
        .navigationDestination(item: $detailActivity) {
            DetailsPage(activity: $0)
        }
        
        .toolbar(.hidden, for: .tabBar)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 12) {
                if !hasChallenge {
                    durationRow
                        .padding(.horizontal, 16)
                }
                GreenButton(text: isEditing ? "حفظ التعديل" : "تأكيد", size: 24, isOn: !selected.isEmpty) { confirm() }
                    .padding(.horizontal, 57)
            }
            .padding(.vertical, 12)
            .background(Color.white.ignoresSafeArea(edges: .bottom))
        }
        .environment(\.layoutDirection, .rightToLeft)
        .sheet(isPresented: $showAdd) {
            AddSheet { title, details, category in add(title, details, category) }
                .environment(\.layoutDirection, .rightToLeft)
        }
        .fullScreenCover(isPresented: $showDeleteConfirmation) {
            deleteConfirmationAlert
                .presentationBackground(.clear)
        }
        
        .overlay {
            if confirmed {
                customAlert
            }
        }
        
        .task { Backend.seedIfNeeded(context, with: sampleActivities) }
        .onAppear {
            guard selected.isEmpty else { return }
            if let s = activeSelection {
                days = s.days
                if s.plannedToday { selected = s.ids }   // اليوم الجديد يبدأ فاضي
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
            days = min(7, max(1, days + change))
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
        let wasEditing = isEditing
        Backend.confirm(activities.filter { selected.contains($0.id) }, days: days, in: context)
        alertTitle = wasEditing ? "تم حفظ التعديل 🌿" : "تمت إضافة أنشطتك لليوم 🌿"
        
        
        alertMessage = "أكِّد إنجازها من الصفحة الرئيسية في نهاية اليوم لتُحتسب في إحصائياتك"
        
        confirmed = true
    }
    
    
    private var customAlert: some View {
        ZStack {
            Color.black.opacity(0.25)
                .ignoresSafeArea()

            VStack(alignment: .trailing, spacing: 0) {

                // Title
                Text(alertTitle)
                    .font(AppFont.title(20))
                    .foregroundStyle(Color.ink)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: .infinity, alignment: .trailing)

                // Description
                Text(alertMessage)
                    .font(AppFont.text(16))
                    .foregroundStyle(Color.softGray)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .lineSpacing(4)
                    .padding(.top, 8)

                // Confirm Button
                Button {
                    confirmed = false
                    dismiss()
                } label: {
                    Text("حسنًا")
                        .font(AppFont.title(20))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.darkGreen, in: Capsule())
                }
                .buttonStyle(.plain)
                .padding(.top, 20)
            }
            .environment(\.layoutDirection, .leftToRight)
            .padding(24)
            .frame(maxWidth: 320)
            .background(
                Color(red: 0.96, green: 0.97, blue: 0.93),
                in: RoundedRectangle(cornerRadius: 28)
            )
            .padding(.horizontal, 24)
        }
    }

    

    private var deleteConfirmationAlert: some View {
        ZStack {
            Color.black.opacity(0.25)
                .ignoresSafeArea()

            VStack(alignment: .trailing, spacing: 0) {

                // Title
                Text("هل أنت متأكد من حذف النشاط؟")
                    .font(AppFont.title(20))
                    .foregroundStyle(Color.ink)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: .infinity, alignment: .trailing)

                // Description
                Text("سيتم حذف هذا النشاط من قائمتك.")
                    .font(AppFont.text(16))
                    .foregroundStyle(Color.softGray)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .lineSpacing(4)
                    .padding(.top, 8)

                // Delete Button
                Button {
                    if let activity = activityToDelete {
                        deleteActivity(activity)
                    }
                    activityToDelete = nil
                    showDeleteConfirmation = false
                } label: {
                    Text("حذف النشاط")
                        .font(AppFont.title(20))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(
                            Color(red: 0.72, green: 0.25, blue: 0.25),
                            in: Capsule()
                        )
                }
                .buttonStyle(.plain)
                .padding(.top, 20)

                // Cancel Button
                Button {
                    activityToDelete = nil
                    showDeleteConfirmation = false
                } label: {
                    Text("تراجع")
                        .font(AppFont.title(20))
                        .foregroundStyle(Color.darkGreen)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(
                            Color.darkGreen.opacity(0.10),
                            in: Capsule()
                        )
                }
                .buttonStyle(.plain)
                .padding(.top, 8)
            }
            .environment(\.layoutDirection, .leftToRight)
            .padding(24)
            .frame(maxWidth: 320)
            .background(
                Color(red: 0.96, green: 0.97, blue: 0.93),
                in: RoundedRectangle(cornerRadius: 28)
            )
            .padding(.horizontal, 24)
        }
    }

    
    private func deleteActivity(_ activity: Activity) {
        guard activity.isCustom else { return }

        selected.remove(activity.id)
        context.delete(activity)
        swipedActivityID = nil
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
    var isOn = false, dashed = false, plain = false
    var onInfo: (() -> Void)? = nil

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
            .environment(\.layoutDirection, .rightToLeft)

            if let onInfo {
                Button(action: onInfo) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 22, weight: .light))
                        .foregroundColor(.softGray)
                }
                .buttonStyle(.plain)
            }

            Image(systemName: isOn ? "checkmark.circle.fill" : "plus.circle")
                .font(.system(size: 28, weight: .light))
                .foregroundColor(isOn ? Color.darkGreen : Color.softGray)
        }
        .padding(14)
        .frame(minHeight: 100)
        .background(RoundedRectangle(cornerRadius: 16).fill(plain ? Color.white : Color.cream))
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

            Text("إضافة نشاط")
                .font(AppFont.title(22))
                .foregroundColor(.ink)
                .padding(.top, 8)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("سجّل نشاطًا مستدامًا من اختيارك")
                .font(AppFont.text(13))
                .foregroundColor(.softGray)
                .frame(maxWidth: .infinity, alignment: .leading)

            TextField("اسم النشاط", text: $title)
                .inputStyle()
                .environment(\.layoutDirection, .leftToRight)
                .multilineTextAlignment(.trailing)

            TextField("وصف مختصر (اختياري)", text: $details)
                .inputStyle()
                .environment(\.layoutDirection, .leftToRight)
                .multilineTextAlignment(.trailing)

            Text("نوع النشاط")
                .font(AppFont.title(16))
                .foregroundColor(.ink)
                .padding(.top, 4)
                .frame(maxWidth: .infinity, alignment: .leading)

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: 10
            ) {
                ForEach(ActivityCategory.allCases.filter { $0 != .all }, id: \.self) { c in

                    HStack(spacing: 8) {

                        Circle()
                            .fill(c.look.bg)
                            .frame(width: 25, height: 25)
                            .overlay {
                                Image(systemName: c.look.icon)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(c.look.color)
                            }

                        Text(c.rawValue)
                            .font(AppFont.title(14))
                            .foregroundColor(.ink)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)

                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 10)
                    .frame(height: 35)
                    .background(
                        Capsule().fill(type == c ? Color.cream : Color.white)
                    )
                    .overlay {
                        Capsule()
                            .strokeBorder(
                                type == c ? Color.darkGreen : Color.lightGreen,
                                lineWidth: 1.5
                            )
                    }
                    .contentShape(Capsule())
                    .onTapGesture {
                        type = c
                    }
                }
            }

            Spacer(minLength: 0)

            GreenButton(text: "إضافة", size: 20, isOn: !name.isEmpty) {
                onAdd(
                    name,
                    details.trimmingCharacters(in: .whitespacesAndNewlines),
                    type
                )
                dismiss()
            }
        }
        .environment(\.layoutDirection, .rightToLeft)

        .padding(20)
        
        .frame(maxWidth: .infinity, alignment: .leading)
        .environment(\.layoutDirection, .rightToLeft)
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
        self.font(AppFont.text(16)).foregroundColor(.ink).multilineTextAlignment(.trailing)

            .padding(.horizontal, 14).frame(height: 50).background(RoundedRectangle(cornerRadius: 14).fill(Color.white))
            .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.lightGreen))
    }
}

// أرقام إنجليزية (123)
func arabic(_ number: Int) -> String { String(number) }

#Preview {
    Activitypage()
        .modelContainer(for: [Activity.self, Completion.self, Challenge.self], inMemory: true)
}
