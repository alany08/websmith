import SwiftUI

struct EditWebsiteView: View {
    @EnvironmentObject var store: ConfigurationStore
    @State private var config = WebsiteConfiguration(url: "", nickname: "")
    @State private var showImport = false
    @State private var showShare = false

    var body: some View {
        Form {
            Section(header: Text("General")) {
                TextField("URL", text: $config.url)
                TextField("Nickname", text: $config.nickname)
            }

            Section(header: Text("Settings")) {
                Toggle("Fullscreen", isOn: $config.allowFullscreen)
                Toggle("Disable Text Selection", isOn: $config.disableTextSelection)
                Toggle("Show Leave Bar", isOn: $config.showTopBar)
                Picker("Orientation", selection: $config.forceOrientation) {
                    ForEach(OrientationOption.allCases, id: \.self) { option in
                        Text(option.rawValue.capitalized).tag(option)
                    }
                }
            }

            Section(header: Text("Styles & Scripts")) {
                Text("Custom Stylesheets: \(config.customStylesheets.count)")
                Text("User Scripts: \(config.userScripts.count)")
            }

            Section(header: Text("Request Filtering")) {
                Text("Whitelist entries: \(config.requestWhitelist.count)")
                Text("Adblock lists: \(config.adblockLists.count)")
            }
        }
        .navigationTitle("Edit Site")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Save") { store.add(config) }
            }
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button("Share") { showShare = true }
                Button("Import") { showImport = true }
            }
        }
    }
}
