import SwiftUI

struct AppBackground: View {
    var body: some View {
        ZStack {
            Color(red: 247/255, green: 250/255, blue: 245/255)

            Circle()
                .fill(RadialGradient(colors: [Color(red: 230/255, green: 236/255, blue: 200/255).opacity(0.5), Color.clear], center: .center, startRadius: 0, endRadius: 150))
                .frame(width: 300, height: 300)
                .offset(x: -80, y: -200)

            Circle()
                .fill(RadialGradient(colors: [Color(red: 230/255, green: 236/255, blue: 200/255).opacity(0.5), Color.clear], center: .center, startRadius: 0, endRadius: 150))
                .frame(width: 300, height: 300)
                .offset(x: 100, y: 50)

            Circle()
                .fill(RadialGradient(colors: [Color(red: 230/255, green: 236/255, blue: 200/255).opacity(0.5), Color.clear], center: .center, startRadius: 0, endRadius: 150))
                .frame(width: 300, height: 300)
                .offset(x: -60, y: 250)
        }
        .ignoresSafeArea()
    }
}
