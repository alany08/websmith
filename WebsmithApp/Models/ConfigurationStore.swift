import Foundation
import SwiftUI

final class ConfigurationStore: ObservableObject {
    @Published var websites: [WebsiteConfiguration] = [] {
        didSet { save() }
    }

    private let saveURL: URL = {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return dir.appendingPathComponent("websites.json")
    }()

    init() {
        load()
    }

    func addOrUpdate(_ config: WebsiteConfiguration) {
        if let index = websites.firstIndex(where: { $0.id == config.id }) {
            websites[index] = config
        } else {
            websites.append(config)
        }
    }

    func remove(_ config: WebsiteConfiguration) {
        websites.removeAll { $0.id == config.id }
    }

    func exportConfiguration(_ config: WebsiteConfiguration) throws -> Data {
        try config.exportJSON()
    }

    func importConfiguration(from data: Data) throws {
        let config = try WebsiteConfiguration.importJSON(data)
        addOrUpdate(config)
    }

    private func save() {
        if let data = try? JSONEncoder().encode(websites) {
            try? data.write(to: saveURL)
        }
    }

    private func load() {
        if let data = try? Data(contentsOf: saveURL),
           let decoded = try? JSONDecoder().decode([WebsiteConfiguration].self, from: data) {
            websites = decoded
        }
    }
}
