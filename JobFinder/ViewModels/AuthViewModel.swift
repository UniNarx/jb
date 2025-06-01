import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var fullName = ""
    @Published var resumeURL = ""

    @Published var userSession: FirebaseAuth.User?
    @Published var errorMessage: String?
    @Published var currentUserProfile: UserProfile?
    @Published var isLoading = false // Мы это пропустили, но если захотите, добавим позже

    init() {
        self.userSession = Auth.auth().currentUser
        if let user = self.userSession {
            print("DEBUG: Пользователь уже авторизован при запуске: \(user.uid)")
            fetchUserProfile(userId: user.uid)
        }
    }

    func signIn() {
        // isLoading = true // Если используем isLoading
        // errorMessage = nil
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            // defer { self?.isLoading = false } // Если используем isLoading
            guard let self = self else { return }

            if let error = error {
                self.errorMessage = error.localizedDescription
                print("DEBUG: Ошибка входа - \(error.localizedDescription)")
                return
            }

            guard let user = authResult?.user else {
                self.errorMessage = "Не удалось получить данные пользователя после входа."
                return
            }

            self.userSession = user
            self.errorMessage = nil
            print("DEBUG: Пользователь успешно вошел: \(user.uid)")
            self.fetchUserProfile(userId: user.uid)

            self.email = ""
            self.password = ""
        }
    }

    func signUp() {
        // isLoading = true // Если используем isLoading
        // errorMessage = nil
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }

            if let error = error {
                self.errorMessage = error.localizedDescription
                print("DEBUG: Ошибка регистрации - \(error.localizedDescription)")
                // self.isLoading = false // Если используем isLoading
                return
            }

            guard let user = authResult?.user else {
                self.errorMessage = "Не удалось получить данные пользователя после регистрации."
                // self.isLoading = false // Если используем isLoading
                return
            }

            self.userSession = user
            print("DEBUG: Пользователь успешно зарегистрирован: \(user.uid)")
            
            let initialProfileData = UserProfile(
                id: user.uid,
                fullName: self.fullName,
                email: self.email,
                resumeURL: self.resumeURL,
                savedJobIDs: [], // Убедитесь, что это здесь
                respondedJobIDs: []
            )

            self.saveNewUserProfile(profileData: initialProfileData) { [weak self] success in
                // defer { self?.isLoading = false } // Если используем isLoading
                guard let self = self else { return }
                if success {
                    self.currentUserProfile = initialProfileData
                    self.errorMessage = nil
                    self.email = ""
                    self.password = ""
                    self.fullName = ""
                    self.resumeURL = ""
                } else {
                    // errorMessage уже должен быть установлен в saveNewUserProfile
                    print("DEBUG: Ошибка сохранения профиля после регистрации.")
                }
            }
        }
    }
    
    private func saveNewUserProfile(profileData: UserProfile, completion: @escaping (Bool) -> Void) {
        guard let userId = profileData.id else {
            self.errorMessage = "User ID отсутствует для сохранения профиля."
            completion(false)
            return
        }
        let db = Firestore.firestore()

        let userData: [String: Any] = [
            "fullName": profileData.fullName,
            "email": profileData.email,
            "resumeURL": profileData.resumeURL,
            "savedJobIDs": profileData.savedJobIDs ?? [], // Используем ?? [] для сохранения пустого массива, если nil
            "respondedJobIDs": profileData.respondedJobIDs ?? [] // Используем ?? [] для сохранения пустого массива, если nil
        ]

        db.collection("users").document(userId).setData(userData) { error in
            if let error = error {
                print("DEBUG: Ошибка сохранения профиля пользователя в Firestore: \(error.localizedDescription)")
                self.errorMessage = "Ошибка сохранения профиля."
                completion(false)
            } else {
                print("DEBUG: Профиль пользователя (включая job IDs) успешно сохранен в Firestore для userId: \(userId)")
                self.errorMessage = nil
                completion(true)
            }
        }
    }

    func signOut() {
        // isLoading = true // Если используем isLoading
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUserProfile = nil
            self.errorMessage = nil
            print("DEBUG: Пользователь успешно вышел.")
        } catch let signOutError as NSError {
            self.errorMessage = "Ошибка выхода: \(signOutError.localizedDescription)"
            print("DEBUG: Ошибка выхода: %s", signOutError)
        }
        // isLoading = false // Если используем isLoading
    }

    func fetchUserProfile(userId: String) {
        // isLoading = true // Если используем isLoading
        // errorMessage = nil
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { [weak self] (document, error) in
            // defer { self?.isLoading = false } // Если используем isLoading
            guard let self = self else { return }

            if let error = error {
                print("DEBUG: Ошибка загрузки профиля пользователя: \(error.localizedDescription)")
                self.errorMessage = "Не удалось загрузить данные профиля."
                return
            }

            if let document = document, document.exists {
                guard let data = document.data() else {
                    print("DEBUG: Документ профиля пуст для userId: \(userId).")
                    self.errorMessage = "Профиль пользователя не найден (данные пусты)."
                    return
                }
                let fullName = data["fullName"] as? String ?? ""
                let email = data["email"] as? String ?? "" // Email также есть в Auth.auth().currentUser.email
                let resumeURL = data["resumeURL"] as? String ?? ""
                
                // Извлекаем новые поля
                let savedJobIDs = data["savedJobIDs"] as? [Int] // Могут быть nil, если поле не существует или другого типа
                let respondedJobIDs = data["respondedJobIDs"] as? [Int] // Могут быть nil

                self.currentUserProfile = UserProfile(
                    id: document.documentID,
                    fullName: fullName,
                    email: email,
                    resumeURL: resumeURL,
                    savedJobIDs: savedJobIDs,         // Присваиваем загруженное значение
                    respondedJobIDs: respondedJobIDs  // Присваиваем загруженное значение
                )
                print("DEBUG: Профиль пользователя успешно загружен (включая job IDs): \(self.currentUserProfile?.fullName ?? "N/A")")
                self.errorMessage = nil
            } else {
                print("DEBUG: Документ профиля пользователя не существует для userId: \(userId).")
                self.errorMessage = "Профиль пользователя не найден."
                // currentUserProfile останется nil или предыдущим значением, если была ошибка.
                // Возможно, стоит установить self.currentUserProfile = nil здесь, если документ не найден.
            }
        }
    }
    
    func updateUserProfile(profileData: UserProfile, completion: @escaping (Result<Void, Error>) -> Void) {
        // isLoading = true // Если используем isLoading
        // errorMessage = nil
        guard let userId = profileData.id else {
            completion(.failure(NSError(domain: "AuthViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "User ID is missing for update"])))
            // self.isLoading = false // Если используем isLoading
            return
        }

        let db = Firestore.firestore()
        
        // Создаем словарь для Firestore, включая ВСЕ поля из profileData
        let updatedData: [String: Any] = [
            "fullName": profileData.fullName,
            "email": profileData.email, // Email здесь для полноты объекта UserProfile, хотя обычно он не меняется через этот UI
            "resumeURL": profileData.resumeURL,
            "savedJobIDs": profileData.savedJobIDs ?? [], // Если nil, сохраняем как пустой массив
            "respondedJobIDs": profileData.respondedJobIDs ?? [] // Если nil, сохраняем как пустой массив
        ]

        db.collection("users").document(userId).setData(updatedData, merge: true) { [weak self] error in
            // defer { self?.isLoading = false } // Если используем isLoading
            guard let self = self else { return }
            
            if let error = error {
                print("DEBUG: Ошибка обновления профиля пользователя в Firestore: \(error.localizedDescription)")
                self.errorMessage = "Ошибка обновления профиля."
                completion(.failure(error))
            } else {
                print("DEBUG: Профиль пользователя (включая job IDs) успешно обновлен в Firestore для userId: \(userId)")
                // Обновляем локальный currentUserProfile после успешного сохранения
                // profileData должен содержать все актуальные поля, включая job IDs,
                // так как ProfileView передает их из authViewModel.currentUserProfile
                self.currentUserProfile = profileData
                self.errorMessage = nil
                completion(.success(()))
            }
        }
    }
    
    // Добавьте эти методы в конец класса AuthViewModel

    // MARK: - Saved Jobs Management
    func addSavedJobToProfile(jobID: Int, completion: @escaping (Error?) -> Void) {
        guard let userId = userSession?.uid else {
            let error = NSError(domain: "AuthViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "Пользователь не авторизован для сохранения вакансии."])
            completion(error)
            return
        }
        let db = Firestore.firestore()
        db.collection("users").document(userId).updateData([
            "savedJobIDs": FieldValue.arrayUnion([jobID])
        ]) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                print("DEBUG: Ошибка добавления savedJob ID (\(jobID)) в Firestore: \(error.localizedDescription)")
                completion(error)
            } else {
                print("DEBUG: savedJob ID (\(jobID)) успешно добавлен в Firestore для userId: \(userId)")
                // Обновляем локальный currentUserProfile
                if self.currentUserProfile?.savedJobIDs?.contains(jobID) == false {
                    self.currentUserProfile?.savedJobIDs?.append(jobID)
                } else if self.currentUserProfile?.savedJobIDs == nil {
                     self.currentUserProfile?.savedJobIDs = [jobID]
                }
                completion(nil)
            }
        }
    }

    func removeSavedJobFromProfile(jobID: Int, completion: @escaping (Error?) -> Void) {
        guard let userId = userSession?.uid else {
            let error = NSError(domain: "AuthViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "Пользователь не авторизован для удаления сохраненной вакансии."])
            completion(error)
            return
        }
        let db = Firestore.firestore()
        db.collection("users").document(userId).updateData([
            "savedJobIDs": FieldValue.arrayRemove([jobID])
        ]) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                print("DEBUG: Ошибка удаления savedJob ID (\(jobID)) из Firestore: \(error.localizedDescription)")
                completion(error)
            } else {
                print("DEBUG: savedJob ID (\(jobID)) успешно удален из Firestore для userId: \(userId)")
                // Обновляем локальный currentUserProfile
                self.currentUserProfile?.savedJobIDs?.removeAll(where: { $0 == jobID })
                completion(nil)
            }
        }
    }

    // MARK: - Responded Jobs Management
    func addRespondedJobToProfile(jobID: Int, completion: @escaping (Error?) -> Void) {
        guard let userId = userSession?.uid else {
            let error = NSError(domain: "AuthViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "Пользователь не авторизован для отметки отклика на вакансию."])
            completion(error)
            return
        }
        let db = Firestore.firestore()
        db.collection("users").document(userId).updateData([
            "respondedJobIDs": FieldValue.arrayUnion([jobID])
        ]) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                print("DEBUG: Ошибка добавления respondedJob ID (\(jobID)) в Firestore: \(error.localizedDescription)")
                completion(error)
            } else {
                print("DEBUG: respondedJob ID (\(jobID)) успешно добавлен в Firestore для userId: \(userId)")
                // Обновляем локальный currentUserProfile
                if self.currentUserProfile?.respondedJobIDs?.contains(jobID) == false {
                    self.currentUserProfile?.respondedJobIDs?.append(jobID)
                } else if self.currentUserProfile?.respondedJobIDs == nil {
                    self.currentUserProfile?.respondedJobIDs = [jobID]
                }
                completion(nil)
            }
        }
    }
}
