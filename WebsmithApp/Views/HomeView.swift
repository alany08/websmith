import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: ConfigurationStore
    @State private var showShare = false
    @State private var shareData: Data?
    @State private var shareFileName = ""
    @State private var fullscreenSite: WebsiteConfiguration?

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.websites) { site in
                    HStack {
                        Text(site.nickname)
                        Spacer()
                        if site.hideNavigation {
                            Button {
                                fullscreenSite = site
                            } label: {
                                Image(systemName: "play.circle")
                            }
                        } else {
                            NavigationLink(destination: WebBrowserView(configuration: site)) {
                                Image(systemName: "play.circle")
                            }
                        }
                        Button {
                            if let data = try? site.exportJSON() {
                                shareData = data
                                shareFileName = "\(site.nickname).json"
                                showShare = true
                            }
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                        }
                        NavigationLink(destination: EditWebsiteView(configuration: site)) {
                            Image(systemName: "gearshape")
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
}
