//
//  LocationManager.swift
//  clique
//
//  Created by Clique on 1/31/26.
//

import Foundation
import CoreLocation

/// Manager for handling location services
class LocationManager: NSObject, ObservableObject {
    static let shared = LocationManager()
    
    private let locationManager = CLLocationManager()
    private var locationContinuation: CheckedContinuation<CLLocationCoordinate2D, Error>?
    
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    /// Gets the current location asynchronously
    /// - Returns: Current location coordinates
    /// - Throws: LocationError if location cannot be obtained
    func getCurrentLocation() async throws -> CLLocationCoordinate2D {
        // Check authorization status
        let status = locationManager.authorizationStatus
        
        switch status {
        case .notDetermined:
            // Request authorization
            locationManager.requestWhenInUseAuthorization()
            // Wait for authorization decision
            return try await withCheckedThrowingContinuation { continuation in
                self.locationContinuation = continuation
                locationManager.requestLocation()
            }
            
        case .restricted, .denied:
            throw LocationError.authorizationDenied
            
        case .authorizedWhenInUse, .authorizedAlways:
            // Already authorized, request location
            return try await withCheckedThrowingContinuation { continuation in
                self.locationContinuation = continuation
                locationManager.requestLocation()
            }
            
        @unknown default:
            throw LocationError.unknownError
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            locationContinuation?.resume(throwing: LocationError.locationUnavailable)
            locationContinuation = nil
            return
        }
        
        locationContinuation?.resume(returning: location.coordinate)
        locationContinuation = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationContinuation?.resume(throwing: LocationError.locationFailed(error))
        locationContinuation = nil
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // Handle authorization changes if needed
        let status = manager.authorizationStatus
        
        if status == .denied || status == .restricted {
            locationContinuation?.resume(throwing: LocationError.authorizationDenied)
            locationContinuation = nil
        }
    }
}

// MARK: - LocationError

enum LocationError: LocalizedError {
    case authorizationDenied
    case locationUnavailable
    case locationFailed(Error)
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .authorizationDenied:
            return "Location access denied. Please enable location services in Settings."
        case .locationUnavailable:
            return "Unable to determine your location. Please try again."
        case .locationFailed(let error):
            return "Location error: \(error.localizedDescription)"
        case .unknownError:
            return "An unknown error occurred while getting your location."
        }
    }
}
