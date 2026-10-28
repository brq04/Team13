
import SwiftUI

struct MainTabView: View {

    @State private var selectedTab = 0

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {

                if selectedTab == 0 {
                    ContentView()
                } else {
                    Text("صفحة الخريطة")
                }

                customTabBar
                    .padding(.bottom, 50)
            }
        }
    }
    
    
    // MARK: - Custom Tab Bar
    private var customTabBar: some View {
        HStack(spacing: 0) {

            tabButton(
                 title: "الخريطة",
                 icon: "map",
                 tab: 1
             )

             tabButton(
                 title: "الرئيسية",
                 icon: "house",
                 tab: 0
             )

        }
        .padding(5)
        .frame(width: 226, height: 62)
        .background(.regularMaterial)
        .clipShape(Capsule())
        .overlay {
            Capsule()
                .stroke(.white.opacity(0.8), lineWidth: 1)
        }
    }
    
    
    
    private func tabButton(
        title: String,
        icon: String,
        tab: Int
    ) -> some View {

        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 4) {

                Image(systemName: icon)
                    .font(.system(size: 27))

                Text(title)
                    .font(.custom("TheYearofHandicrafts-Bold", size: 13))
            }
            .foregroundStyle(
                selectedTab == tab
                ? Color(red: 89/255, green: 107/255, blue: 82/255)
                : .black
            )
            .frame(maxWidth: .infinity)
            .frame(height: 66)
            .background {
                if selectedTab == tab {
                    Capsule()
                        .fill(Color(red: 228/255, green: 233/255, blue: 222/255))
                }
            }
        }
        .buttonStyle(.plain)
    }

    
    
}

#Preview {
    MainTabView()
}
    
    

