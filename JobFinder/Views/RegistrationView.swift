import SwiftUI

struct RegistrationView: View {
    @ObservedObject var authViewModel: AuthViewModel

    var body: some View {
        VStack(spacing: 20) {
           
            HStack {
                Image(systemName: "person.fill")
                    .foregroundColor(.gray)
                    .frame(width: 20, alignment: .center)
                TextField("Полное имя", text: $authViewModel.fullName)
                    .textContentType(.name)
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
            .padding(.horizontal)

            HStack {
                Image(systemName: "envelope.fill")
                    .foregroundColor(.gray)
                    .frame(width: 20, alignment: .center)
                TextField("Email", text: $authViewModel.email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .textContentType(.emailAddress)
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
            .padding(.horizontal)

            HStack {
                Image(systemName: "lock.fill")
                    .foregroundColor(.gray)
                    .frame(width: 20, alignment: .center)
                SecureField("Пароль", text: $authViewModel.password)
                    .textContentType(.newPassword)
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
            .padding(.horizontal)
            
            HStack {
                Image(systemName: "link")
                    .foregroundColor(.gray)
                    .frame(width: 20, alignment: .center)
                TextField("Ссылка на резюме (URL)", text: $authViewModel.resumeURL)
                    .keyboardType(.URL)
                    .autocapitalization(.none)
                    .textContentType(.URL)
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
            .padding(.horizontal)

            if let errorMessage = authViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
            }
            Button(action: {
                authViewModel.signUp()
            }) {
                Text("Зарегистрироваться")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(gradient: Gradient(colors: [Color.green.opacity(0.8), Color.green]), startPoint: .top, endPoint: .bottom)
                    ) 
                    .cornerRadius(10)
                    .shadow(color: Color.green.opacity(0.4), radius: 5, x: 0, y: 5) // Тень
                    .padding(.horizontal)
            }

            Spacer()
        }
        .padding(.top, 20)
    }
}


