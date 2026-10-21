import SwiftUI
import MapKit

struct MapHomeView: View {
    @State private var search = ""
    @State private var category: PlaceCategory = .all
    @State private var selected: Place?
    @State private var locationManager = CLLocationManager()
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 24.69, longitude: 46.70),
            span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
        )
    )

    private var places: [Place] {
        Place.samples.filter { p in
            (category == .all || p.category == category) &&
            (search.isEmpty || p.title.localizedCaseInsensitiveContains(search))
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            AppHeader()
            SearchBar(text: $search)
            CategoryChips(selection: $category)
            mapView
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .sheet(item: $selected) { place in
            PlaceSheet(place: place) { handleAction(for: place) }
        }
        .onAppear { locationManager.requestWhenInUseAuthorization() }
    }

    private var mapView: some View {
        Map(position: $position) {
            UserAnnotation()
            ForEach(places) { place in
                Annotation("", coordinate: place.coordinate, anchor: .bottom) {
                    Button { selected = place } label: {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(.white, place.kind.color)
                    }
                }
            }
        }
        .mapStyle(.standard(pointsOfInterest: .excludingAll))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(alignment: .bottomLeading) {   // bottomLeading = أسفل اليمين في العربي
            VStack(alignment: .leading, spacing: 10) {
                Button {
                    withAnimation { position = .userLocation(fallback: .automatic) }
                } label: {
                    Image(systemName: "location.fill")
                        .foregroundStyle(.white)
                        .frame(width: 42, height: 42)
                        .background(Color.brand, in: Circle())
                }
                MapLegend()
            }
            .padding(12)
        }
    }

    private func handleAction(for place: Place) {
        switch place.kind {
        case .explore:
            let item = MKMapItem(placemark: MKPlacemark(coordinate: place.coordinate))
            item.name = place.title
            item.openInMaps()
        case .volunteer:
            // TODO: افتحي صفحة تفاصيل فرصة التطوع
            break
        }
    }
}

// MARK: - Components

struct AppHeader: View {
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "mappin.and.ellipse")
                .font(.system(size: 30))
                .foregroundStyle(Color.brandDark)
            VStack(alignment: .leading, spacing: 2) {
                Text("خريطة المجتمع").font(.system(size: 22, weight: .bold))
                Text("اصنع الفرق حولك").font(.system(size: 11)).foregroundStyle(.secondary)
            }
            Spacer()
        }
    }
}

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
            TextField("البحث", text: $text)
            Image(systemName: "mic").foregroundStyle(.secondary)
        }
        .padding(.horizontal, 15)
        .frame(height: 48)
        .background(.white.opacity(0.7), in: Capsule())
        .overlay(Capsule().stroke(.gray.opacity(0.2), lineWidth: 1))
    }
}

struct CategoryChips: View {
    @Binding var selection: PlaceCategory

    var body: some View {
        HStack(spacing: 0) {
            ForEach(PlaceCategory.allCases) { c in
                Button {
                    withAnimation(.snappy) { selection = c }
                } label: {
                    Text(c.title)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(selection == c ? .white : .primary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .background { if selection == c { Capsule().fill(Color.brand) } }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(.white.opacity(0.85), in: Capsule())
        .overlay(Capsule().stroke(.gray.opacity(0.2), lineWidth: 1))
    }
}

struct MapLegend: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            row(icon: "tree.fill", color: .brand,
                title: "استكشاف", subtitle: "يمكنك استكشاف أماكن زراعتها")
            row(icon: "person.3.fill", color: .red,
                title: "يحتاج متطوعين", subtitle: "أماكن تحتاج لتحسين ومساعدة")
        }
        .padding(10)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func row(icon: String, color: Color, title: String, subtitle: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon).font(.system(size: 20)).foregroundStyle(color)
            VStack(alignment: .leading, spacing: 1) {
                Text(title).font(.system(size: 12, weight: .bold))
                Text(subtitle).font(.system(size: 9)).foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    MapHomeView()
        .environment(\.layoutDirection, .rightToLeft)
}
