import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: ConfigurationStore

    var body: some View {
        NavigationView {
            List {
                ForEach(store.websites) { site in
                    NavigationLink(destination: WebBrowserView(configuration: site)) {
                        HStack {
                            Image(systemName: "globe")
                            Text(site.nickname)
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
            }
        }
    }
}
