//
//  MapHomeView.swift
//  thelaunch_13
//
//  Created by malhajri on 17/05/1448 AH.
//
import SwiftUI
import MapKit

struct MapHomeView: View {
    var bottomInset: CGFloat = 0   // مساحة البار السفلي عشان ما يغطي المفتاح
    @State private var search = ""
    @State private var category: PlaceCategory = .all
    @State private var selected: Place?
    @State private var detail: Place?                       // صفحة الفرصة
    @State private var allPlaces = Place.samples            // تتحدث مواقعها من الخرائط
    private let location = LocationService.shared
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 24.69, longitude: 46.70),
            span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
        )
    )

    private var places: [Place] {
        allPlaces.filter { p in
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
        .background {
            Image(.bg)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        }
        .sheet(item: $selected) { place in
            PlaceSheet(place: place) { handleAction(for: place) }
        }
        .navigationDestination(item: $detail) { VolunteerDetailsPage(place: $0) }
        .onAppear {
            if location.status == .notDetermined { location.requestPermission() }
            if location.isAuthorized { position = .userLocation(fallback: .automatic) }
        }
        .onChange(of: location.isAuthorized) { _, allowed in
            // أول ما توافق على الإذن، الخريطة تروح لموقعك الحقيقي
            if allowed { withAnimation { position = .userLocation(fallback: .automatic) } }
        }
        .task { await resolveLocations() }
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
        .overlay(alignment: .bottom) {
            VStack(spacing: 10) {
                HStack {   // أول عنصر = اليمين في العربي
                    Button {
                        locateMe()
                    } label: {
                        Image(systemName: "location.fill")
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.brand, in: Circle())
                    }
                    Spacer()
                }
                MapLegend()
            }
            .padding(12)
            .padding(.bottom, bottomInset)
        }
    }

    private func locateMe() {
        switch location.status {
        case .notDetermined:
            location.requestPermission()
        case .denied, .restricted:
            // الإذن مرفوض: نفتح إعدادات التطبيق
            if let url = URL(string: UIApplication.openSettingsURLString) { UIApplication.shared.open(url) }
        default:
            withAnimation { position = .userLocation(fallback: .automatic) }
        }
    }

    private func handleAction(for place: Place) {
        switch place.kind {
        case .explore:
            let item = MKMapItem(placemark: MKPlacemark(coordinate: place.coordinate))
            item.name = place.title
            item.openInMaps()
        case .volunteer:
            selected = nil      // نقفل الشيت
            detail = place      // ونفتح صفحة الفرصة
        }
    }

    /// يجيب الموقع الحقيقي لكل مكان من خرائط أبل (داخل الرياض فقط)
    @MainActor
    private func resolveLocations() async {
        let riyadh = CLLocation(latitude: 24.71, longitude: 46.68)
        for i in allPlaces.indices {
            guard let query = allPlaces[i].searchQuery, !allPlaces[i].located else { continue }
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = query
            request.region = MKCoordinateRegion(center: riyadh.coordinate,
                                                latitudinalMeters: 60_000, longitudinalMeters: 60_000)
            guard let item = try? await MKLocalSearch(request: request).start().mapItems.first else { continue }
            let c = item.placemark.coordinate
            guard CLLocation(latitude: c.latitude, longitude: c.longitude).distance(from: riyadh) < 60_000 else { continue }
            allPlaces[i].latitude = c.latitude
            allPlaces[i].longitude = c.longitude
            allPlaces[i].located = true
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
                Text("خريطة المجتمع").font(.app(22, .bold))
                Text("اصنع الفرق حولك").font(.app(11)).foregroundStyle(.secondary)
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
            TextField("البحث", text: $text).font(.app(14))
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
                        .font(.app(12, .medium))
                        .foregroundStyle(selection == c ? .white : .primary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .background { if selection == c { Capsule().fill(Color.brandDark) } }
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
        VStack(alignment: .leading, spacing: 12) {
            row(icon: "tree.fill", color: .pinGreen,
                title: "استكشاف", subtitle: "يمكنك استكشاف أماكن زراعتها")
            row(icon: "person.3.fill", color: .red,
                title: "يحتاج متطوعين", subtitle: "أماكن تحتاج لتحسين ومساعدة")
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 18)
        .frame(maxWidth: .infinity)   // بعرض الخريطة كاملة
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }

    private func row(icon: String, color: Color, title: String, subtitle: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon).font(.system(size: 26)).foregroundStyle(color)
                .frame(width: 34)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.app(15, .bold))
                Text(subtitle).font(.app(12)).foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
    }
}

#Preview {
    MapHomeView()
        .environment(\.layoutDirection, .rightToLeft)
}
