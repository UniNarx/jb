// UserProfile.swift

struct UserProfile: Codable, Equatable {
    var id: String? // UID пользователя из Auth
    let fullName: String
    let email: String
    let resumeURL: String
    // Новые поля:
    var savedJobIDs: [Int]?     // Массив ID сохраненных вакансий
    var respondedJobIDs: [Int]? // Массив ID вакансий, на которые откликнулись

    init(id: String? = nil,
         fullName: String,
         email: String,
         resumeURL: String,
         savedJobIDs: [Int]? = nil,   // Добавляем в инициализатор
         respondedJobIDs: [Int]? = nil) { // Добавляем в инициализатор
        self.id = id
        self.fullName = fullName
        self.email = email
        self.resumeURL = resumeURL
        self.savedJobIDs = savedJobIDs       // Инициализируем
        self.respondedJobIDs = respondedJobIDs // Инициализируем
    }

    // Обновляем Equatable, если вы его определяли явно
    static func == (lhs: UserProfile, rhs: UserProfile) -> Bool {
        return lhs.id == rhs.id &&
               lhs.fullName == rhs.fullName &&
               lhs.email == rhs.email &&
               lhs.resumeURL == rhs.resumeURL &&
               lhs.savedJobIDs == rhs.savedJobIDs &&             // Сравниваем новые поля
               lhs.respondedJobIDs == rhs.respondedJobIDs      // Сравниваем новые поля
    }
}
