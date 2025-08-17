import Foundation

enum OrientationOption: String, Codable, CaseIterable {
    case system
    case portrait
    case landscape
}

struct WebsiteConfiguration: Identifiable, Codable, Equatable {
    var id = UUID()
    var url: String
    var nickname: String
    var allowFullscreen: Bool = false
    var disableTextSelection: Bool = false
    var forceOrientation: OrientationOption = .system
    var showTopBar: Bool = true
    var customStylesheets: [URL] = []
    var userScripts: [URL] = []
    var requestWhitelist: [String] = []
    var adblockLists: [URL] = []

    func exportJSON() throws -> Data {
        try JSONEncoder().encode(self)
    }

    static func importJSON(_ data: Data) throws -> WebsiteConfiguration {
        try JSONDecoder().decode(WebsiteConfiguration.self, from: data)
    }
}
