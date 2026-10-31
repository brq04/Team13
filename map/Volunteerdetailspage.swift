import SwiftUI
import MapKit

/// صفحة فرصة التطوع (تفتح من شيت الخريطة)
struct VolunteerDetailsPage: View {
    let place: Place
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {

                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.brandDark)
                            .frame(width: 46, height: 46)
                            .background(Circle().fill(Color.white.opacity(0.8)))
                    }
                    Spacer()
                }
                .padding(.top, 14)

                PlaceImage(place: place)

                VStack(alignment: .leading, spacing: 8) {
                    Text(place.title).font(.app(24, .bold))
                    Label(place.subtitle, systemImage: "mappin")
                        .font(.app(13))
                        .foregroundStyle(.secondary)
                    if let details = place.details {
                        Text(details)
                            .font(.app(14))
                            .foregroundStyle(.secondary)
                            .padding(.top, 4)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if !place.tasks.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("المهام التطوعية").font(.app(18, .bold))
                        ForEach(place.tasks, id: \.self) { task in
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Color.brandDark)
                                Text(task).font(.app(14))
                            }
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.7), in: RoundedRectangle(cornerRadius: 20))
                }

                // الموقع (بس لو تأكدنا منه من الخرائط)
                if place.located {
                    Map(initialPosition: .region(MKCoordinateRegion(
                        center: place.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)))) {
                        Marker(place.title, coordinate: place.coordinate)
                            .tint(.red)
                    }
                    .frame(height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .allowsHitTesting(false)
                }

            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .safeAreaInset(edge: .bottom) {
            // الأزرار ثابتة تحت
            if place.located || place.link != nil {
                VStack(spacing: 10) {
                    if let link = place.link, let url = URL(string: link) {
                        Link(destination: url) {
                            actionLabel("سجّل كمتطوع", icon: "arrow.up.left.square", filled: true)
                        }
                    }
                    if place.located {
                        Button {
                            let item = MKMapItem(placemark: MKPlacemark(coordinate: place.coordinate))
                            item.name = place.title
                            item.openInMaps()
                        } label: {
                            actionLabel("فتح في الخرائط", icon: "map", filled: place.link == nil)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 10)
                .padding(.bottom, 12)
                .background(.ultraThinMaterial)
            }
        }
        .background {
            LinearGradient(colors: [Color.brandSoft.opacity(0.6), .cream],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        }
        .environment(\.layoutDirection, .rightToLeft)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
    }

    private func actionLabel(_ text: String, icon: String, filled: Bool) -> some View {
        HStack(spacing: 8) {
            Text(text)
            Image(systemName: icon)
        }
        .font(.app(15, .semibold))
        .foregroundStyle(filled ? Color.white : Color.brandDark)
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .background(filled ? Color.brandDark : Color.white.opacity(0.8),
                    in: RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    NavigationStack { VolunteerDetailsPage(place: Place.samples[1]) }
}
