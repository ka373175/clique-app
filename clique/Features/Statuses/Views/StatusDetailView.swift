//
//  StatusDetailView.swift
//  clique
//
//  Created by Praveen Kumar on 8/30/25.
//

import SwiftUI
import MapKit

struct StatusDetailView: View {
    let status: FullStatus
    
    var body: some View {
        VStack(spacing: 24) {
            // Large emoji circle (similar to StatusRowView but bigger)
            ZStack {
                Circle()
                    .fill(IconColor.from(status.iconColor).color.gradient)
                    .frame(width: 120, height: 120)
                Text(status.initials)
                    .foregroundColor(.white)
                    .font(.system(size: 48, weight: .bold))
                Text(status.statusEmoji ?? "")
                    .font(.system(size: 36))
                    .offset(x: 40, y: 38)
            }
            
            // Username
            Text("\(status.firstName) \(status.lastName)")
                .font(.title)
                .fontWeight(.semibold)
            
            // Status text
            Text(status.statusText.isEmpty ? "No status yet" : status.statusText)
                .font(.title3)
                .foregroundStyle(status.statusText.isEmpty ? .tertiary : .secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Location map (if available)
            if let latitude = status.latitude, let longitude = status.longitude {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Location")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    Map(position: .constant(.region(MKCoordinateRegion(
                        center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    )))) {
                        Marker(status.firstName, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                    }
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }
                .padding(.top, 16)
            }
            
            Spacer()
        }
        .padding(.top, 40)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        StatusDetailView(status: statusesForTesting[0])
    }
}
