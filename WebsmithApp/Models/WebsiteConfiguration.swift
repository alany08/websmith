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
    var hideNavigation: Bool = false
    var disableTextSelection: Bool = false
    var forceOrientation: OrientationOption = .system
    var allowCookies: Bool = true
    var allowBackForwardGestures: Bool = true
    var customStylesheets: [URL] = []
    var userScripts: [URL] = []
    var urlBlacklist: [String] = []
    var adblockLists: [URL] = []

    enum CodingKeys: String, CodingKey {
        case id, url, nickname, allowFullscreen, hideNavigation, disableTextSelection, forceOrientation, allowCookies, allowBackForwardGestures, customStylesheets, userScripts, urlBlacklist = "requestWhitelist", adblockLists
    }

    func exportJSON() throws -> Data {
        try JSONEncoder().encode(self)
    }

    static func importJSON(_ data: Data) throws -> WebsiteConfiguration {
        try JSONDecoder().decode(WebsiteConfiguration.self, from: data)
    }
}
