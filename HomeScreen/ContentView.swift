import SwiftUI
import Playgrounds

struct ContentView: View {
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
                                Text("15 نقطة")
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
        VStack(alignment: .trailing, spacing: 8) {

            // Title and streak
            VStack(alignment: .trailing, spacing: 4) {
                Text("تقدّمك اليومي")
                    .font(.custom("TheYearofHandicrafts-Bold",size: 20))

                Text("سلسلتك الحالية 7 أيام متتالية 🌿")
                    .font(.custom("TheYearofHandicrafts-Light",size: 16))
            }
            .frame(maxWidth: .infinity, alignment: .trailing)

            // Seven-day tracker
            HStack(spacing: 8) {
                ForEach((1...7).reversed(), id: \.self) { day in
                    VStack(spacing: 2) {
                        Text("يوم")
                        Text("\(day)")
                    }
                    .font(.custom("TheYearofHandicrafts-Bold", size: 12))
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(
                        day <= 3
                        ? Color(red: 0.57, green: 0.70, blue: 0.53)
                        : day == 4
                        ? Color(red: 0.75, green: 0.83, blue: 0.72)
                        : Color(red: 0.88, green: 0.88, blue: 0.88)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 10))
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
    }

    
    
    
    //activityStatsCards
    private var activityStatsCards: some View {
        GeometryReader { geometry in
            let cardWidth = (geometry.size.width - 16) / 2

            HStack(spacing: 16) {

                Image(.statistics)
                    .resizable()
                    .scaledToFit()
                    .frame(width: cardWidth)

                Image(.activities)
                    .resizable()
                    .scaledToFit()
                    .frame(width: cardWidth)
            }
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
    MainTabView()
}

#Playground {
    _ = 1 + 2
}
