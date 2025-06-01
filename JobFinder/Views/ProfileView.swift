import SwiftUI
import CoreData

struct ProfileView: View {
    @Environment(\.managedObjectContext) private var ctx
    @FetchRequest(
        entity: User.entity(),
        sortDescriptors: []
    ) private var users: FetchedResults<User>

    @State private var fullName: String = ""
    @State private var email: String = ""
    @State private var resumeURL: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("User Info")) {
                    TextField("Full Name", text: $fullName)
                    TextField("Email", text: $email)
                }
                Section(header: Text("Resume")) {
                    TextField("Link to Resume (URL)", text: $resumeURL)
                }
                Section {
                    Button("Save Profile") {
                        saveProfile()
                    }
                }
            }
            .navigationTitle("Profile")
            .onAppear(perform: loadProfile)
        }
    }

    private func loadProfile() {
        if let user = users.first {
            fullName  = user.fullName  ?? ""
            email     = user.email     ?? ""
            resumeURL = user.resumeURL ?? ""
        } else {
            let newUser = User(context: ctx)
            newUser.fullName = ""
            newUser.email = ""
            newUser.resumeURL = ""
            try? ctx.save()
        }
    }

    private func saveProfile() {
        let user = users.first!
        user.fullName  = fullName
        user.email     = email
        user.resumeURL = resumeURL
        do {
            try ctx.save()
        } catch {
            print("Failed to save profile:", error)
        }
    }
}
