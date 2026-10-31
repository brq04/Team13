import SwiftUI
import SwiftData
import Combine

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @State private var showEndOfDay = false
    @State private var promptedToday = false
    @State private var celebration: String?
    private static let endOfDayHour = 20   // الساعة اللي يطلع فيها سؤال "سويتها؟"
    @Query private var completions: [Completion]
    @Query private var challenges: [Challenge]
    private var totalPoints: Int { completions.reduce(0) { $0 + $1.points } }
    private var snapshot: StatsSnapshot {
        Backend.snapshot(completions: completions, challenges: challenges)
    }
    
    var body: some View {
        ZStack {

            ScrollView{
            // Header
            VStack(spacing: 0) {

                        // Header
                            HStack(spacing: 12) {

                                // Points badge
                                Text("\(totalPoints.arabicDigits) نقطة")
                                    .font(.system(size: 16, weight: .medium))
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .overlay {
                                        Capsule()
                                            .stroke(
                                                Color(red: 0.35, green: 0.43, blue: 0.32),
                                                lineWidth: 2
                                            )
                                    }

                                Spacer()

                                // Greeting
                                Text("مرحباً")
                                    .font(.system(size: 24, weight: .bold))

                                // Avatar image
                                Image(.avatar)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                                    .clipShape(Circle())
                            }
                            .padding(.top, 64)
                        
                
                // Daily Progress
                dailyProgressCard
                    .padding(.top, 48)

                if snapshot.plannedToday {
                    endOfDayCard
                        .padding(.top, 16)
                }
                
                
                
                // activityStatsCards
                activityStatsCards
                    .padding(.top, 24)
                
                
                
                // Discover & Learn
                discoverLearnSection
                    .padding(.top, 24)
                
                Spacer()
                    }.padding(.horizontal, 20)
            }
        }
        // الخلفية هنا (background) عشان حجم الصورة ما يكبّر الصفحة ويدفع البار برا الشاشة
        .background {
            Image(.bg)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        }
        .alert("كفو! سويت أنشطتك اليوم؟ 🌿", isPresented: $showEndOfDay) {
            Button("نعم، أنجزتها") { completeToday() }
            Button("لاحقًا", role: .cancel) {}
        } message: {
            Text("أكّد إنجازك عشان تنحسب نقاطك ونكمل هدفك")
        }
        .alert(celebration ?? "", isPresented: Binding(
            get: { celebration != nil },
            set: { if !$0 { celebration = nil } }
        )) {
            Button("حسنًا", role: .cancel) {}
        }
        .onAppear { checkEndOfDay() }
        .onReceive(Timer.publish(every: 60, on: .main, in: .common).autoconnect()) { _ in
            checkEndOfDay()
        }
    }

    // MARK: - تأكيد الإنجاز (نهاية اليوم)
    private var endOfDayCard: some View {
        HStack(spacing: 12) {
            Button { completeToday() } label: {
                Text("أنجزتها ✅")
                    .font(.custom("TheYearofHandicrafts-Bold", size: 14))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .frame(height: 40)
                    .background(Color(red: 0.35, green: 0.43, blue: 0.32), in: Capsule())
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("هل أنجزت أنشطة اليوم؟")
                    .font(.custom("TheYearofHandicrafts-Bold", size: 16))
                Text("أكّد إنجازك لتنحسب نقاطك في إحصائياتك")
                    .font(.custom("TheYearofHandicrafts-Regular", size: 12))
            }
        }
        .padding(16)
        .background(Color(red: 0.96, green: 0.97, blue: 0.91), in: RoundedRectangle(cornerRadius: 28))
    }

    private func completeToday() {
        let goalDone = Backend.completeToday(in: context)
        celebration = goalDone
            ? "أنجزت هدفك كاملًا، ما شاء الله عليك 🎉"
            : "كفو، سويتها! نقاطك انضافت لإحصائياتك 🌿"
    }

    // نهاية اليوم: يطلع السؤال مرة وحدة لو فيه أنشطة مضافة وما انأكد إنجازها
    private func checkEndOfDay() {
        guard !promptedToday, snapshot.plannedToday,
              Calendar.current.component(.hour, from: Date()) >= Self.endOfDayHour else { return }
        promptedToday = true
        showEndOfDay = true
    }
    
    
    private var dailyProgressCard: some View {
        NavigationLink {
            if snapshot.hasActive {
                // فيه سلسلة: إحصائيات اليوم
                StatsContentView()
            } else {
                // ما فيه سلسلة: اختيار الأنشطة
                Activitypage()
                    .navigationBarBackButtonHidden(true)
                    .toolbar(.hidden, for: .navigationBar)
            }
        } label: {
            dailyProgressCardContent
        }
        .buttonStyle(.plain)   // عشان ما يتغير لون النصوص
        
    }
    
    
  //dailyProgressCard
    private var dailyProgressCardContent: some View {
        let s = snapshot

        // بدون سلسلة: ٧ أيام رمادية. معها: عدد أيام الهدف بحد أقصى ٧
        // (لو الهدف أطول من ٧ ينتقل الصف للأسبوع التالي)
        let visibleDays: [Int] = {
            guard s.hasActive else { return Array(1...7) }
            let start = ((s.currentDay - 1) / 7) * 7 + 1
            let end = max(start, min(start + 6, s.totalDays))
            return Array(start...end)
        }()

        let subtitle: String = {
            guard s.hasActive else {
                return "اختر نشاطًا وحدّد مدة هدفك لتبدأ 🌱"
            }
            let today = "اليوم \(s.currentDay.arabicDigits) من \(s.totalDays.arabicDigits)"
            if s.isGoalComplete { return "\(today) · أتممت هدفك 🎉" }
            if s.todayDone { return "\(today) · أنجزت نشاط اليوم 🌿" }
            if s.plannedToday {
                return "\(today) · أضفت أنشطتك، أكّد إنجازها قبل نهاية اليوم ⏳"
            }
            return "\(today) · سجّل نشاطك اليوم 🌱"
        }()

        return VStack(alignment: .trailing, spacing: 12) {

             VStack(alignment: .trailing, spacing: 8) {
                
                HStack {
                    Text("تقدّمك اليومي")
                        .font(.custom("TheYearofHandicrafts-Bold", size: 20))

                    Spacer()

                    if s.hasActive {
                        NavigationLink {
                            Activitypage()
                                .navigationBarBackButtonHidden(true)
                                .toolbar(.hidden, for: .navigationBar)
                        } label: {
                            Text("تعديل")
                                .font(.custom("TheYearofHandicrafts-Bold", size: 16))
                                .foregroundStyle(Color(red: 0.35, green: 0.43, blue: 0.32))
                                .frame(minWidth: 70, minHeight: 44)
                                .background(.white, in: Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .environment(\.layoutDirection, .rightToLeft)

                Text(subtitle)
                    .font(.custom("TheYearofHandicrafts-Regular", size: 14))
                    .foregroundStyle(Color(red: 0.35, green: 0.43, blue: 0.32))
                    .multilineTextAlignment(.trailing)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)

            .frame(maxWidth: .infinity, alignment: .trailing)
            
            HStack(spacing: 8) {
                ForEach(visibleDays.reversed(), id: \.self) { day in
                    let state: DayState = {
                        guard s.hasActive else { return .upcoming }
                        if day < s.currentDay { return .done }       // أيام عدّت
                        if day == s.currentDay { return s.todayDone ? .done : .current }   // اليوم
                        return .upcoming                             // لسا
                    }()

                    VStack(spacing: 2) {
                        Text("يوم")
                        Text(day.arabicDigits)
                    }
                    .font(.custom("TheYearofHandicrafts-Bold", size: 12))
                    .foregroundStyle(Color.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(fillColor(for: state), in: RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding(12)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.gray.opacity(0.4), lineWidth: 0.5)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 36)
                .fill(Color(red: 0.96, green: 0.97, blue: 0.91))
        )
        .animation(.easeInOut, value: s.currentDay)
        .animation(.easeInOut, value: s.hasActive)
    }

    // نفس ألوان الصورة
    private func fillColor(for state: DayState) -> Color {
        switch state {
        case .done:     return Color(red: 0.57, green: 0.70, blue: 0.53)  // أخضر
        case .current:  return Color(red: 0.75, green: 0.83, blue: 0.72)  // أخضر فاتح
        case .upcoming: return Color(red: 0.88, green: 0.88, blue: 0.88)  // رمادي
        }
    }

   
    
    
    
    //activityStatsCards
    private var activityStatsCards: some View {
        GeometryReader { geometry in
            let cardWidth = (geometry.size.width - 16) / 2

            HStack(spacing: 16) {

                // Statistics
                NavigationLink {
                    StatsContentView()
                } label: {
                    Image(.statistics)
                        .resizable()
                        .scaledToFit()
                        .frame(width: cardWidth)
                }

                // Activities
                NavigationLink {
                    Activitypage()
                        .navigationBarBackButtonHidden(true)
                        .toolbar(.hidden, for: .navigationBar)
                } label: {
                    Image(.activities)
                        .resizable()
                        .scaledToFit()
                        .frame(width: cardWidth)
                }            }
        }
        .frame(height: 140)
    }

    
    //discoverLearnSection
    private var discoverLearnSection: some View{
        VStack(alignment: .trailing, spacing: 16) {

                Text("اكتشف وتعلّم")
                    .font(.custom("TheYearofHandicrafts-Bold", size: 20))
            
            articleCard(
                title: "البلاستيك المستخدم لمرة واحدة",
                description: "اكتشف أثر البلاستيك على البيئة وكيف نقدر نقلل استخدامه",
                image: .plasticArticle,
                url:"https://www.unep.org/ietc/resources/publication/single-use-plastics-roadmap-sustainability"
            )

            articleCard(
                title: "كل حركة تصنع فرق",
                description: "اكتشف كيف يؤثر النشاط البدني على صحتك وحياتك اليومية",
                image: .walkingArticle,
                url:"https://www.who.int/europe/publications/i/item/9789240014886?utm_source=chatgpt.com"
            )
            
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
    }
    
    // MARK: - Article Card
    private func articleCard(
        title: String,
        description: String,
        image: ImageResource,
        url: String
    ) -> some View {
        HStack(spacing: 12) {
            Link(destination: URL(string: url)!) {
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 22))
                    .foregroundStyle(.black)
                    .frame(width: 44, height: 44)
                    .background(Color.gray.opacity(0.15))
                    .clipShape(Circle())
            }
            
            VStack(alignment: .trailing, spacing: 0) {

                Text(title)
                    .font(.custom("TheYearofHandicrafts-Bold", size: 14))

                Text(description)
                    .font(.custom("TheYearofHandicrafts-Regular", size: 11))
                    .multilineTextAlignment(.trailing)

            }
            
            Image(image)
                .resizable()
                .scaledToFill()
                .frame(width: 85, height: 85)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            Color(red: 0.96, green: 0.97, blue: 0.91)
        )
        .clipShape(RoundedRectangle(cornerRadius: 32))
    }
    
}
#Preview {
    NavigationStack {
        ContentView()
    }
    .modelContainer(for: [Activity.self, Completion.self, Challenge.self], inMemory: true)
}
