import SwiftUI

struct AuthView: View {
    @StateObject var authViewModel: AuthViewModel
    @State private var isLoginMode = true 

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Picker("Mode", selection: $isLoginMode) {
                    Text("Войти").tag(true)
                    Text("Регистрация").tag(false)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)

                if isLoginMode {
                    LoginView(authViewModel: authViewModel)
                } else {
                    RegistrationView(authViewModel: authViewModel)
                }

                Spacer()
            }
            .navigationTitle(isLoginMode ? "Вход" : "Регистрация")
        }
    }
}


