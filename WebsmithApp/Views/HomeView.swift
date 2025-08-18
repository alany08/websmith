import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: ConfigurationStore
    @State private var showShare = false
    @State private var shareData: Data?
    @State private var shareFileName = ""
    @State private var fullscreenSite: WebsiteConfiguration?
    @State private var selectedSite: WebsiteConfiguration?
    @State private var navigateActive = false

    var body: some View {
        Group {
            if #available(iOS 16, *) {
                NavigationStack { content }
            } else {
                NavigationView { content }
            }
        }
    }

    private var content: some View {
        List {
            ForEach(store.websites) { site in
                HStack {
                    Text(site.nickname)
                    Spacer()
                    Button {
                        if let data = try? site.exportJSON() {
                            shareData = data
                            shareFileName = "\(site.nickname).json"
                            showShare = true
                        }
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .buttonStyle(.borderless)

                    NavigationLink(destination: EditWebsiteView(configuration: site)) {
                        Image(systemName: "gearshape")
                    }
                    .buttonStyle(.borderless)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if site.hideNavigation {
                        fullscreenSite = site
                    } else {
                        selectedSite = site
                        navigateActive = true
                    }
                }
            }
            .onDelete { indexSet in
                indexSet.map { store.websites[$0] }.forEach { store.remove($0) }
            }
        }
        .navigationTitle("Websmith")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: EditWebsiteView()) {
                    Image(systemName: "plus")
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gear")
                }
            }
        }
        .background(
            NavigationLink(
                destination: WebBrowserView(configuration: selectedSite ?? WebsiteConfiguration(url: "", nickname: "")),
                isActive: $navigateActive
            ) { EmptyView() }
            .hidden()
        )
        .sheet(isPresented: $showShare) {
            if let data = shareData {
                ShareSheet(data: data, fileName: shareFileName)
            }
        }
        .fullScreenCover(item: $fullscreenSite) { site in
            WebBrowserView(configuration: site)
                .interactiveDismissDisabled()
        }
    }
}
