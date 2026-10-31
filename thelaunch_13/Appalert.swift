import SwiftUI

// نافذة تنبيه عربية موحّدة: نفس تصميم نوافذ صفحة الأنشطة (customAlert) عشان كل النوافذ تطلع بنفس الشكل

struct AppAlertButton: Identifiable {
    enum Style { case primary, cancel, destructive }

    let id = UUID()
    let title: String
    let style: Style
    let action: () -> Void

    init(_ title: String, style: Style = .primary, action: @escaping () -> Void = {}) {
        self.title = title
        self.style = style
        self.action = action
    }
}

struct AppAlertModifier: ViewModifier {
    @Binding var isPresented: Bool
    let title: String
    let message: String?
    let buttons: [AppAlertButton]

    func body(content: Content) -> some View {
        content
            .overlay {
                if isPresented {
                    ZStack {
                        Color.black.opacity(0.25)
                            .ignoresSafeArea()
                            .onTapGesture { }          // يمنع الضغط على اللي ورا
                        card
                            .padding(.horizontal, 24)
                    }
                    .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: isPresented)
    }

    private var card: some View {
        VStack(alignment: .leading, spacing: 0) {       // leading = اليمين في العربي

            Text(title)
                .font(AppFont.title(20))
                .foregroundStyle(Color.ink)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            if let message {
                Text(message)
                    .font(AppFont.text(16))
                    .foregroundStyle(Color.softGray)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineSpacing(4)
                    .padding(.top, 8)
            }

            ForEach(Array(buttons.enumerated()), id: \.element.id) { index, b in
                Button {
                    isPresented = false
                    b.action()
                } label: {
                    Text(b.title)
                        .font(AppFont.title(20))
                        .foregroundStyle(foreground(b.style))
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(background(b.style), in: Capsule())
                }
                .buttonStyle(.plain)
                .padding(.top, index == 0 ? 20 : 8)
            }
        }
        .padding(24)
        .frame(maxWidth: 320)
        .background(Color(red: 0.96, green: 0.97, blue: 0.93),
                    in: RoundedRectangle(cornerRadius: 28))
        .environment(\.layoutDirection, .rightToLeft)
    }

    private func foreground(_ style: AppAlertButton.Style) -> Color {
        style == .cancel ? Color.darkGreen : .white
    }

    private func background(_ style: AppAlertButton.Style) -> Color {
        switch style {
        case .primary:     return Color.darkGreen
        case .cancel:      return Color.darkGreen.opacity(0.10)
        case .destructive: return Color(red: 0.72, green: 0.25, blue: 0.25)
        }
    }
}

extension View {
    func appAlert(isPresented: Binding<Bool>,
                  title: String,
                  message: String? = nil,
                  buttons: [AppAlertButton]) -> some View {
        modifier(AppAlertModifier(isPresented: isPresented, title: title,
                                  message: message, buttons: buttons))
    }
}
