import SwiftUI
import UniformTypeIdentifiers

struct EditWebsiteView: View {
    @EnvironmentObject var store: ConfigurationStore
    @Environment(\.dismiss) private var dismiss
    @State private var config: WebsiteConfiguration
    @State private var showImport = false
    @State private var showShare = false
    @State private var showDeleteConfirm = false
    @State private var showStyleImporter = false
    @State private var showScriptImporter = false
    @State private var showAdblockImporter = false
    @State private var newBlacklistEntry = ""
    @State private var newAdblockURL = ""
    @State private var isDeleted = false

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
                Toggle("Hide Navigation", isOn: $config.hideNavigation)
                Toggle("Disable Text Selection", isOn: $config.disableTextSelection)
                Toggle("Allow Cookies", isOn: $config.allowCookies)
                Toggle("Allow Gestures", isOn: $config.allowBackForwardGestures)
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
                Button {
                    showStyleImporter = true
                } label: {
                    Label("Add Stylesheet", systemImage: "plus")
                }
                .buttonStyle(.plain)
            }

            Section(header: Text("User Scripts")) {
                ForEach(config.userScripts, id: \.self) { url in
                    Text(url.lastPathComponent)
                }
                .onDelete { config.userScripts.remove(atOffsets: $0) }
                Button {
                    showScriptImporter = true
                } label: {
                    Label("Add Script", systemImage: "plus")
                }
                .buttonStyle(.plain)
            }

            Section(header: Text("URL Blacklist")) {
                ForEach(config.urlBlacklist, id: \.self) { entry in
                    Text(entry)
                }
                .onDelete { config.urlBlacklist.remove(atOffsets: $0) }
                HStack {
                    TextField("Add entry", text: $newBlacklistEntry)
                    Button("Add") {
                        guard !newBlacklistEntry.isEmpty else { return }
                        config.urlBlacklist.append(newBlacklistEntry)
                        newBlacklistEntry = ""
                    }
                }
            }

            Section(header: Text("Adblock Lists")) {
                ForEach(config.adblockLists, id: \.self) { url in
                    Text(url.lastPathComponent)
                }
                .onDelete { config.adblockLists.remove(atOffsets: $0) }
                Button {
                    showAdblockImporter = true
                } label: {
                    Label("Import List", systemImage: "plus")
                }
                .buttonStyle(.plain)
                HStack {
                    TextField("Import from URL", text: $newAdblockURL)
                    Button("Add") { addAdblockURL() }
                }
            }
        }
        .navigationTitle("Edit Site")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button { showShare = true } label: {
                    Image(systemName: "square.and.arrow.up")
                }
                Button { showImport = true } label: {
                    Image(systemName: "square.and.arrow.down")
                }
                Button(role: .destructive) { showDeleteConfirm = true } label: {
                    Image(systemName: "trash")
                }
            }
        }
        .alert("Delete this site?", isPresented: $showDeleteConfirm) {
            Button("Delete", role: .destructive) {
                store.remove(config)
                isDeleted = true
                dismiss()
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
        .fileImporter(
            isPresented: $showStyleImporter,
            allowedContentTypes: [.data]
        ) { result in
            if case .success(let url) = result {
                let dest = saveFile(url)
                config.customStylesheets.append(dest)
            }
        }
        .fileImporter(
            isPresented: $showScriptImporter,
            allowedContentTypes: [.data]
        ) { result in
            if case .success(let url) = result {
                let dest = saveFile(url)
                config.userScripts.append(dest)
            }
        }
        .fileImporter(
            isPresented: $showAdblockImporter,
            allowedContentTypes: [.plainText]
        ) { result in
            if case .success(let url) = result {
                let dest = saveFile(url)
                config.adblockLists.append(dest)
            }
        }
        .onDisappear {
            if !isDeleted {
                store.addOrUpdate(config)
            }
        }
    }

    private func saveFile(_ url: URL) -> URL {
        saveFile(url, named: url.lastPathComponent)
    }

    private func saveFile(_ url: URL, named name: String) -> URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dest = docs.appendingPathComponent(name)
        if FileManager.default.fileExists(atPath: dest.path) {
            try? FileManager.default.removeItem(at: dest)
        }
        try? FileManager.default.copyItem(at: url, to: dest)
        return dest
    }

    private func addAdblockURL() {
        guard let url = URL(string: newAdblockURL), !newAdblockURL.isEmpty else { return }
        Task {
            do {
                let (temp, _) = try await URLSession.shared.download(from: url)
                let dest = saveFile(temp, named: url.lastPathComponent)
                config.adblockLists.append(dest)
                newAdblockURL = ""
            } catch {
                // ignore failures
            }
        }
    }

    private func saveFile(_ url: URL) -> URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dest = docs.appendingPathComponent(url.lastPathComponent)
        if FileManager.default.fileExists(atPath: dest.path) {
            try? FileManager.default.removeItem(at: dest)
        }
        try? FileManager.default.copyItem(at: url, to: dest)
        return dest
    }
}
