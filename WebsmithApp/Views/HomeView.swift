import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: ConfigurationStore

    var body: some View {
        NavigationView {
            List {
                ForEach(store.websites) { site in
                    HStack {
                        NavigationLink(destination: WebBrowserView(configuration: site)) {
                            HStack {
                                Image(systemName: "globe")
                                Text(site.nickname)
                            }
                        }
                        Spacer()
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
        }
    }
}
