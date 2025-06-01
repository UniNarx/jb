struct UserProfile: Codable, Equatable {
    var id: String?
    let fullName: String
    let email: String
    let resumeURL: String
    var savedJobIDs: [Int]?
    var respondedJobIDs: [Int]?

    init(id: String? = nil,
         fullName: String,
         email: String,
         resumeURL: String,
         savedJobIDs: [Int]? = nil,
         respondedJobIDs: [Int]? = nil) {
        self.id = id
        self.fullName = fullName
        self.email = email
        self.resumeURL = resumeURL
        self.savedJobIDs = savedJobIDs
        self.respondedJobIDs = respondedJobIDs
    }

    static func == (lhs: UserProfile, rhs: UserProfile) -> Bool {
        return lhs.id == rhs.id &&
               lhs.fullName == rhs.fullName &&
               lhs.email == rhs.email &&
               lhs.resumeURL == rhs.resumeURL &&
               lhs.savedJobIDs == rhs.savedJobIDs &&
               lhs.respondedJobIDs == rhs.respondedJobIDs
    }
}
