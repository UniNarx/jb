import SwiftUI
import FirebaseCore

@main
struct JobFinderApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject var authViewModel = AuthViewModel()
    @StateObject var jobListViewModel: JobListViewModel

    init() {
        FirebaseApp.configure()
        print("Firebase сконфигурирован!")

        let authVM = AuthViewModel()
        _authViewModel = StateObject(wrappedValue: authVM)

        _jobListViewModel = StateObject(wrappedValue: JobListViewModel(authViewModel: authVM))
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(jobListViewModel)
                .environment(\.managedObjectContext,
                             persistenceController.container.viewContext)
        }
    }
}
