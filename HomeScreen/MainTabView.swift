import SwiftUI

/// تاب بار النظام (نفس تطبيق الصحة من أبل): ثابت تحت، زجاجي، ويتحرك مع النظام
struct MainTabView: View {

    @State private var selectedTab = 0   // 0 الرئيسية، 1 الخريطة

    init() {
        // خط التطبيق لأسماء التبويبات
        if let font = UIFont(name: "TheYearofHandicrafts-Bold", size: 11) {
            UITabBarItem.appearance().setTitleTextAttributes([.font: font], for: .normal)
            UITabBarItem.appearance().setTitleTextAttributes([.font: font], for: .selected)
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {

            // الخريطة أول عنصر = يسار، والرئيسية = يمين
            Tab("الخريطة", systemImage: "map", value: 1) {
                NavigationStack {
                    MapHomeView()
                        .environment(\.layoutDirection, .rightToLeft)
                        .toolbar(.hidden, for: .navigationBar)
                        .background {
                            LinearGradient(colors: [Color.brandSoft.opacity(0.6), .cream],
                                           startPoint: .top, endPoint: .bottom)
                                .ignoresSafeArea()
                        }
                }
            }

            Tab("الرئيسية", systemImage: "house", value: 0) {
                NavigationStack {
                    ContentView()
                }
            }
        }
        .tint(Color(red: 89/255, green: 107/255, blue: 82/255))
    }
}

#Preview {
    MainTabView()
}
