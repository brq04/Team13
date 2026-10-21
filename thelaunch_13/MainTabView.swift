import SwiftUI

enum AppTab { case home, map }

struct MainTabView: View {
    @State private var tab: AppTab = .map

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.brandSoft.opacity(0.6), .cream],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            switch tab {
            case .home: HomeView()
            case .map:  MapHomeView()
            }
        }
        .safeAreaInset(edge: .bottom) {
            TabBar(selection: $tab).padding(.bottom, 4)
        }
    }
}

struct HomeView: View {
    var body: some View {
        // TODO: صفحة الرئيسية
        Text("الرئيسية")
            .font(.title.bold())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct TabBar: View {
    @Binding var selection: AppTab

    var body: some View {
        // الترتيب المنطقي: أول عنصر = اليمين في العربي
        HStack(spacing: 0) {
            item(.home, title: "الرئيسية", icon: "house")
            item(.map,  title: "الخريطة",  icon: "map")
        }
        .padding(5)
        .frame(width: 205, height: 62)
        .background(.white.opacity(0.85), in: Capsule())
        .overlay(Capsule().stroke(.gray.opacity(0.2), lineWidth: 1))
    }

    private func item(_ tab: AppTab, title: String, icon: String) -> some View {
        let selected = selection == tab
        return Button {
            withAnimation(.snappy) { selection = tab }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: selected ? "\(icon).fill" : icon)
                    .font(.system(size: 22))
                Text(title).font(.system(size: 12, weight: .medium))
            }
            .foregroundStyle(selected ? Color.brandDark : .primary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background { if selected { Capsule().fill(Color.brandSoft) } }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MainTabView()
        .environment(\.layoutDirection, .rightToLeft)
}


