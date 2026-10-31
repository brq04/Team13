//
//  PlaceSheet.swift
//  thelaunch_13
//
//  Created by malhajri on 17/05/1448 AH.
//
import SwiftUI

struct PlaceSheet: View {
    let place: Place
    let onAction: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "chevron.up")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)
                .padding(.top, 10)

            PlaceImage(place: place)

            VStack(alignment: .leading, spacing: 8) {
                Text(place.title).font(.app(20, .bold))

                if let details = place.details {
                    Text(details)
                        .font(.app(13))
                        .foregroundStyle(.secondary)
                } else {
                    Label(place.subtitle, systemImage: "mappin")
                        .font(.app(13))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if !place.tags.isEmpty {
                HStack(spacing: 8) {
                    ForEach(place.tags, id: \.self) { tag in
                        HStack(spacing: 4) {
                            Image(systemName: tag.icon)
                            Text(tag.text)
                        }
                        .font(.app(11))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .overlay(Capsule().stroke(Color.brand.opacity(0.5), lineWidth: 1))
                    }
                    Spacer()
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 24)
        .safeAreaInset(edge: .bottom) {
            // الزر ثابت تحت دايمًا
            Button(action: onAction) {
                HStack(spacing: 8) {
                    Text(place.kind.actionTitle)
                    Image(systemName: place.kind.actionIcon)
                }
                .font(.app(15, .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.brand, in: RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .presentationDetents([.height(430)])
        .presentationCornerRadius(32)
        .presentationBackground(Color.cream)
    }
}

struct PlaceImage: View {
    let place: Place

    var body: some View {
        ZStack(alignment: .topLeading) {   // topLeading = أعلى اليمين في العربي
            Group {
                if UIImage(named: place.imageName) != nil {
                    Image(place.imageName).resizable().scaledToFill()
                } else {
                    LinearGradient(colors: [Color.brandSoft, Color.brand.opacity(0.5)],
                                   startPoint: .top, endPoint: .bottom)
                        .overlay(Image(systemName: "leaf.fill")
                            .font(.largeTitle).foregroundStyle(.white))
                }
            }
            .frame(height: 150)
            .frame(maxWidth: .infinity)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 10))

            HStack(spacing: 4) {
                Text(place.kind.badge)
                Image(systemName: place.kind.badgeIcon)
            }
            .font(.app(10, .medium))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.white.opacity(0.9), in: Capsule())
            .padding(10)
        }
        .padding(6)
        .background(Color.brandSoft, in: RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    PlaceSheet(place: Place.samples[0]) {}
        .environment(\.layoutDirection, .rightToLeft)
}
