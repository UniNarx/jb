import XCTest
@testable import JobFinder

final class ModelDecodingTests: XCTestCase {

    func testJobsResponseDecoding() throws {
        let json = """
        {
          "page": 1,
          "page_count": 1,
          "results": [
            {
              "id": 123,
              "name": "Test Job",
              "locations": [{ "name": "Remote" }],
              "company": { "name": "TestCo" },
              "categories": [{ "name": "Engineering" }],
              "contents": "Job description"
            }
          ]
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let response = try decoder.decode(JobsResponse.self, from: json)

        XCTAssertEqual(response.page, 1)
        XCTAssertEqual(response.page_count, 1)
        XCTAssertEqual(response.results.count, 1)

        let job = response.results[0]
        XCTAssertEqual(job.id, 123)
        XCTAssertEqual(job.name, "Test Job")
        XCTAssertEqual(job.locations.map(\.name), ["Remote"])
        XCTAssertEqual(job.company.name, "TestCo")
        XCTAssertEqual(job.categories.map(\.name), ["Engineering"])
        XCTAssertEqual(job.contents, "Job description")
    }

    func testJobEquatableImplementation() {
        let a = Job(id: 1, name: "A", locations: [], company: CompanySummary(name: ""), categories: [], contents: "")
        let b = Job(id: 1, name: "B", locations: [], company: CompanySummary(name: ""), categories: [], contents: "")
        let c = Job(id: 2, name: "A", locations: [], company: CompanySummary(name: ""), categories: [], contents: "")

        XCTAssertEqual(a, b)
        XCTAssertNotEqual(a, c)
    }
}
