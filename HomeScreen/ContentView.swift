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
                            .padding(.top, 50)
                        
                // Daily Progress
                dailyProgressCard
                    .padding(.top, 50)
                
                        Spacer()
                    }.padding(.horizontal, 20)
    }
}
    
  
    private var dailyProgressCard: some View {
        VStack(alignment: .trailing, spacing: 16) {

            // Title and streak
            VStack(alignment: .trailing, spacing: 6) {
                Text("تقدّمك اليومي")
                    .font(.system(size: 24, weight: .bold))

                Text("سلسلتك الحالية 7 أيام متتالية 🌿")
                    .font(.system(size: 16))
            }
            .frame(maxWidth: .infinity, alignment: .trailing)

            // Seven-day tracker
            HStack(spacing: 6) {
                ForEach((1...7).reversed(), id: \.self) { day in
                    VStack(spacing: 2) {
                        Text("يوم")
                        Text("\(day)")
                    }
                    .font(.system(size: 13, weight: .medium))
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

    
}
#Preview {
    ContentView()
}

#Playground {
    _ = 1 + 2
}
