import Foundation

class JSONLoader {
    
    static func loadCountries() -> [Country] {
        guard let url = Bundle.main.url(forResource: "countries", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("❌ Failed to load countries.json")
            return []
        }
        
        do {
            let countries = try JSONDecoder().decode([Country].self, from: data)
            return countries
        } catch {
            print("❌ Failed to decode countries.json: \(error)")
            return []
        }
    }
    
    static func loadLandmarks() -> [Landmark] {
        guard let url = Bundle.main.url(forResource: "landmarks", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("❌ Failed to load landmarks.json")
            return []
        }
        
        do {
            let landmarks = try JSONDecoder().decode([Landmark].self, from: data)
            return landmarks
        } catch {
            print("❌ Failed to decode landmarks.json: \(error)")
            return []
        }
    }
}
