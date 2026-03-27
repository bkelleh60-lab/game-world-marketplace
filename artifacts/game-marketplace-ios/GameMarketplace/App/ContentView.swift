import SwiftUI

/// Root view that adapts for iPhone (tab bar) and iPad (sidebar).
struct ContentView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var sidebarSelection: SidebarItem? = .discover

    var body: some View {
        if horizontalSizeClass == .compact {
            iPhoneLayout
        } else {
            iPadLayout
        }
    }

    // MARK: - iPhone layout (TabView)

    private var iPhoneLayout: some View {
        TabView {
            Tab("Discover", systemImage: "sparkles") {
                GameListView()
            }
            Tab("Create", systemImage: "pencil.and.list.clipboard") {
                CreateGameView()
            }
            Tab("My Games", systemImage: "star.fill") {
                SellerDashboardView()
            }
        }
        .tint(.orange)
    }

    // MARK: - iPad layout (NavigationSplitView)

    private var iPadLayout: some View {
        NavigationSplitView {
            List(SidebarItem.allCases, id: \.self, selection: $sidebarSelection) { item in
                Label(item.title, systemImage: item.icon)
            }
            .navigationTitle("🎮 Game World")
        } detail: {
            switch sidebarSelection {
            case .discover, .none:
                GameListView()
            case .create:
                CreateGameView()
            case .myGames:
                SellerDashboardView()
            }
        }
        .tint(.orange)
    }
}

// MARK: - Sidebar items

private enum SidebarItem: CaseIterable, Hashable {
    case discover
    case create
    case myGames

    var title: String {
        switch self {
        case .discover: return "Discover Games"
        case .create:   return "Create a Game"
        case .myGames:  return "My Games"
        }
    }

    var icon: String {
        switch self {
        case .discover: return "sparkles"
        case .create:   return "pencil.and.list.clipboard"
        case .myGames:  return "star.fill"
        }
    }
}
