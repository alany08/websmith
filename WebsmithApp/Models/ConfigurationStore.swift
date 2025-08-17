import Foundation
import SwiftUI

final class ConfigurationStore: ObservableObject {
    @Published var websites: [WebsiteConfiguration] = []

    func add(_ config: WebsiteConfiguration) {
        websites.append(config)
    }

    func remove(_ config: WebsiteConfiguration) {
        websites.removeAll { $0.id == config.id }
    }

    func exportConfiguration(_ config: WebsiteConfiguration) throws -> Data {
        try config.exportJSON()
    }

    func importConfiguration(from data: Data) throws {
        let config = try WebsiteConfiguration.importJSON(data)
        add(config)
    }
}
