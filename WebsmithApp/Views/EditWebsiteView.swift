import SwiftUI
import UniformTypeIdentifiers

struct EditWebsiteView: View {
    @EnvironmentObject var store: ConfigurationStore
    @State private var config: WebsiteConfiguration
    @State private var showImport = false
    @State private var showShare = false
    @State private var showDeleteConfirm = false
    @State private var showLeaveWarning = false
    @State private var showStyleImporter = false
    @State private var showScriptImporter = false
    @State private var showAdblockImporter = false
    @State private var newWhitelistEntry = ""

    init(configuration: WebsiteConfiguration? = nil) {
        _config = State(initialValue: configuration ?? WebsiteConfiguration(url: "", nickname: ""))
    }

    var body: some View {
        Form {
            Section(header: Text("General")) {
                TextField("URL", text: $config.url)
                TextField("Nickname", text: $config.nickname)
            }

            Section(header: Text("Settings")) {
                Toggle("Fullscreen", isOn: $config.allowFullscreen)
                Toggle("Disable Text Selection", isOn: $config.disableTextSelection)
                Toggle("Allow Cookies", isOn: $config.allowCookies)
                Toggle("Allow Gestures", isOn: $config.allowBackForwardGestures)
                Toggle("Show Leave Bar", isOn: $config.showTopBar)
                    .onChange(of: config.showTopBar) { value in
                        if !value { showLeaveWarning = true }
                    }
                Picker("Orientation", selection: $config.forceOrientation) {
                    ForEach(OrientationOption.allCases, id: \.self) { option in
                        Text(option.rawValue.capitalized).tag(option)
                    }
                }
            }

            Section(header: Text("Custom Stylesheets")) {
                ForEach(config.customStylesheets, id: \.self) { url in
                    Text(url.lastPathComponent)
                }
                .onDelete { config.customStylesheets.remove(atOffsets: $0) }
                Button("Add Stylesheet") { showStyleImporter = true }
            }

            Section(header: Text("User Scripts")) {
                ForEach(config.userScripts, id: \.self) { url in
                    Text(url.lastPathComponent)
                }
                .onDelete { config.userScripts.remove(atOffsets: $0) }
                Button("Add Script") { showScriptImporter = true }
            }

            Section(header: Text("Request Whitelist")) {
                ForEach(config.requestWhitelist, id: \.self) { entry in
                    Text(entry)
                }
                .onDelete { config.requestWhitelist.remove(atOffsets: $0) }
                HStack {
                    TextField("Add entry", text: $newWhitelistEntry)
                    Button("Add") {
                        guard !newWhitelistEntry.isEmpty else { return }
                        config.requestWhitelist.append(newWhitelistEntry)
                        newWhitelistEntry = ""
                    }
                }
            }

            Section(header: Text("Adblock Lists")) {
                ForEach(config.adblockLists, id: \.self) { url in
                    Text(url.lastPathComponent)
                }
                .onDelete { config.adblockLists.remove(atOffsets: $0) }
                Button("Import List") { showAdblockImporter = true }
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
                Button("Delete", role: .destructive) { showDeleteConfirm = true }
            }
        }
        .alert("Removing the leave bar will require restarting the app to exit.", isPresented: $showLeaveWarning) {
            Button("OK", role: .cancel) {}
        }
        .alert("Delete this site?", isPresented: $showDeleteConfirm) {
            Button("Delete", role: .destructive) {
                store.remove(config)
            }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $showShare) {
            if let data = try? config.exportJSON() {
                ShareSheet(data: data, fileName: "\(config.nickname).json")
            } else {
                Text("Unable to export")
            }
        }
        .fileImporter(isPresented: $showImport, allowedContentTypes: [.json]) { result in
            switch result {
            case .success(let url):
                if let data = try? Data(contentsOf: url), let imported = try? WebsiteConfiguration.importJSON(data) {
                    config = imported
                }
            case .failure:
                break
            }
        }
        .fileImporter(isPresented: $showStyleImporter, allowedContentTypes: [.css]) { result in
            if case .success(let url) = result {
                config.customStylesheets.append(url)
            }
        }
        .fileImporter(isPresented: $showScriptImporter, allowedContentTypes: [.javascript]) { result in
            if case .success(let url) = result {
                config.userScripts.append(url)
            }
        }
        .fileImporter(isPresented: $showAdblockImporter, allowedContentTypes: [.plainText]) { result in
            if case .success(let url) = result {
                config.adblockLists.append(url)
            }
        }
    }
}
