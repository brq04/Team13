import SwiftUI
import SwiftData

@main
struct HabitsApp: App {
    let container: ModelContainer
    @State private var stage = 0   // 0 ترحيب، 1 onboarding، 2 التطبيق (يبدأ من الترحيب كل تشغيل)

    init() {
        container = try! ModelContainer(for: Activity.self, Completion.self, Challenge.self)
        Backend.seedIfNeeded(container.mainContext, with: sampleActivities)
    }

    var body: some Scene {
        WindowGroup {
            Group {
                switch stage {
                case 0:  WlcPage { withAnimation { stage = 1 } }
                case 1:  OnboardingPage { withAnimation { stage = 2 } }
                default: MainTabView()
                }
            }
            .modelContainer(container)

        }
    }
}
