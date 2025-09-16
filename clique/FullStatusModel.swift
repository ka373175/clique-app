import SwiftUI

@MainActor // Ensures all updates run on the main thread
class StatusViewModel: ObservableObject {
    @Published var fullStatuses: [FullStatus] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func fetchStatuses() async {
        guard let url = URL(string: "https://60q4fmxnb7.execute-api.us-east-2.amazonaws.com/prod/statuses") else {
            errorMessage = "Invalid URL"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            // Print raw JSON
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("Raw JSON: \(jsonString)")
                    } else {
                        print("Failed to convert data to string")
                    }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                errorMessage = "Invalid response: \(response)"
                return
            }
            
            let decodedStatuses = try JSONDecoder().decode([FullStatus].self, from: data)
            fullStatuses = decodedStatuses
            isLoading = false
        } catch {
            errorMessage = "Error fetching statuses: \(error.localizedDescription)"
            isLoading = false
        }
    }
}
