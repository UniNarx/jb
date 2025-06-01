import SwiftUI

@main
struct JobFinderApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(JobListViewModel())
                .environment(\.managedObjectContext,
                             persistenceController.container.viewContext)
        }
    }
}
