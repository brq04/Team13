import SwiftUI
import SwiftData

@main
struct HabitsApp: App {
    let container: ModelContainer

    init() {
        container = try! ModelContainer(for: Activity.self, Completion.self, Challenge.self)
        Backend.seedIfNeeded(container.mainContext, with: sampleActivities)
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .modelContainer(container)
        }
    }
}

// مؤقت للتجربة: لما تربطينهم بتنقلك الحقيقي احذفيه
struct RootView: View {
    @State private var refresh = 0

    var body: some View {
        TabView {
            Activitypage()
                .tabItem { Label("الأنشطة", systemImage: "checklist") }
            StatsContentView()
                .tabItem { Label("الإحصائيات", systemImage: "chart.pie") }
        }
        .id(refresh)
        #if DEBUG
        .overlay(alignment: .topLeading) {
            // زر تجربة: يقدّم اليوم +١ عشان تشوفين السلسلة تتقدم
            Button("يوم +١") {
                Backend.dayOffset += 1
                refresh += 1
            }
            .font(.caption.bold())
            .padding(8)
            .background(.ultraThinMaterial, in: Capsule())
            .padding(.leading, 12)
            .padding(.top, 4)
        }
        #endif
    }
}
