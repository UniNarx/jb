import Foundation

struct JobsResponse: Codable {
    let page: Int
    let page_count: Int
    let results: [Job]
}
