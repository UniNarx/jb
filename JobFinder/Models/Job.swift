import Foundation

struct Job: Codable, Identifiable, Equatable {
    let id: Int
    let name: String
    let locations: [Location]
    let company: CompanySummary
    let categories: [Category]
    let contents: String

    static func == (lhs: Job, rhs: Job) -> Bool { lhs.id == rhs.id }
}
