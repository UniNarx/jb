import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var editableFullName: String = ""
    @State private var editableResumeURL: String = ""
    @State private var saveStatusMessage: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Информация о пользователе")) {
                    TextField("Полное имя", text: $editableFullName)
                    HStack {
                        Text("Email")
                        Spacer()
                        Text(authViewModel.currentUserProfile?.email ?? "Не указан")
                            .foregroundColor(.gray)
                    }
                }
                Section(header: Text("Резюме")) {
                    TextField("Ссылка на резюме (URL)", text: $editableResumeURL)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                }
                Section {
                    Button {
                        updateProfileData()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Сохранить изменения")
                            Spacer()
                        }
                    }

                    if !saveStatusMessage.isEmpty {
                        HStack {
                            Spacer()
                            Text(saveStatusMessage)
                                .font(.caption)
                                .foregroundColor(saveStatusMessage.contains("Ошибка") ? .red : .green)
                            Spacer()
                        }
                        .padding(.top, 4)
                    }
                }
                
                Section { 
                    Button(role: .destructive) {
                        authViewModel.signOut()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Выйти из аккаунта")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Профиль")
            .onAppear {
                if let profile = authViewModel.currentUserProfile {
                    self.editableFullName = profile.fullName
                    self.editableResumeURL = profile.resumeURL
                }
            }
            .onChange(of: authViewModel.currentUserProfile) { oldValue, newValue in
                if let profile = newValue {
                    self.editableFullName = profile.fullName
                    self.editableResumeURL = profile.resumeURL
                } else {
                    self.editableFullName = ""
                    self.editableResumeURL = ""
                }
            }
        }
    }

    private func updateProfileData() {
        guard let userId = authViewModel.userSession?.uid else {
            saveStatusMessage = "Ошибка: Пользователь не найден."
            return
        }
        
        let updatedProfile = UserProfile(
            id: userId,
            fullName: editableFullName,
            email: authViewModel.currentUserProfile?.email ?? "",
            resumeURL: editableResumeURL,
            savedJobIDs: authViewModel.currentUserProfile?.savedJobIDs,
            respondedJobIDs: authViewModel.currentUserProfile?.respondedJobIDs
        )

        authViewModel.updateUserProfile(profileData: updatedProfile) { result in
            switch result {
            case .success():
                saveStatusMessage = "Профиль успешно сохранен!"
            case .failure(let error):
                saveStatusMessage = "Ошибка сохранения: \(error.localizedDescription)"
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                saveStatusMessage = ""
            }
        }
    }
}

