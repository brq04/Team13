import SwiftUI
import SwiftData

struct ContentView: View {
    @Query private var completions: [Completion]
    @Query private var challenges: [Challenge]
    private var totalPoints: Int { completions.reduce(0) { $0 + $1.points } }
    private var snapshot: StatsSnapshot {
        Backend.snapshot(completions: completions, challenges: challenges)
    }
    
    var body: some View {
        ZStack {
            
            // Background image
            Image(.bg)
                            .resizable()
                            .scaledToFill()
                            .ignoresSafeArea()

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
                
                
                
                // activityStatsCards
                activityStatsCards
                    .padding(.top, 24)
                
                
                
                // Discover & Learn
                discoverLearnSection
                    .padding(.top, 24)
                
                Spacer()
                    }.padding(.horizontal, 20)
            }.padding(.bottom, 110)
    }
}
    
    
    
    
    
  //dailyProgressCard
    private var dailyProgressCard: some View {
        let s = snapshot
        // نفس منطق StreakCard: صف من ٧ أيام، وينتقل للأسبوع التالي لو الهدف أطول
        let start = ((s.currentDay - 1) / 7) * 7 + 1
        let end = max(start, min(start + 6, s.totalDays))
        let visibleDays = Array(start...end)

        return VStack(alignment: .trailing, spacing: 8) {

            VStack(alignment: .trailing, spacing: 4) {
                Text("تقدّمك اليومي")
                    .font(.custom("TheYearofHandicrafts-Bold", size: 20))

                Text(s.doneDays.isEmpty
                     ? "ابدأ سلسلتك اليوم 🌱"
                     : "سلسلتك الحالية \(s.doneDays.count.arabicDigits) \(dayWord(s.doneDays.count)) متتالية 🌿")
                    .font(.custom("TheYearofHandicrafts-Light", size: 16))
            }
            .frame(maxWidth: .infinity, alignment: .trailing)

            HStack(spacing: 8) {
                ForEach(visibleDays.reversed(), id: \.self) { day in
                    let state: DayState = day == s.currentDay
                        ? .current
                        : (s.doneDays.contains(day) ? .done : .upcoming)

                    VStack(spacing: 2) {
                        Text("يوم")
                        Text(day.arabicDigits)
                    }
                    .font(.custom("TheYearofHandicrafts-Bold", size: 12))
                    .foregroundStyle(state == .done ? Color.white : Color.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(fillColor(for: state), in: RoundedRectangle(cornerRadius: 10))
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
            }
            .padding(12)
            .padding(.top, 8)
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
        .animation(.easeInOut, value: s.doneDays)
    }

    private func fillColor(for state: DayState) -> Color {
        switch state {
        case .done: return .darkGreen
        case .current: return .lightGreen
        case .upcoming: return .upcomingGray
        }
    }

    private func dayWord(_ n: Int) -> String {
        switch n {
        case 1: return "يوم"
        case 2: return "يومان"
        case 3...10: return "أيام"
        default: return "يومًا"
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
        MainTabView()
    }
    .modelContainer(for: [Activity.self, Completion.self, Challenge.self], inMemory: true)
}

