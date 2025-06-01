import XCTest
@testable import JobFinder

class MockJobService: JobServiceProtocol {
    func fetchJobs(page: Int, completion: @escaping (Result<JobsResponse, Error>) -> Void) {
        let emptyResponse = JobsResponse(page: 1, page_count: 1, results: [])
        completion(.success(emptyResponse))
    }
}

class MockAuthViewModel: AuthViewModel {
    override init() {
        super.init()
    }
}


class JobListViewModelFilterTests: XCTestCase {

    var viewModel: JobListViewModel!
    var mockJobService: MockJobService!
    var mockAuthViewModel: MockAuthViewModel!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockJobService = MockJobService()
        mockAuthViewModel = MockAuthViewModel()
        viewModel = JobListViewModel(service: mockJobService, authViewModel: mockAuthViewModel)
        
        viewModel.jobs = [
            Job(id: 1, name: "Swift Developer", locations: [Location(name: "Remote")], company: CompanySummary(name: "TechCorp"), categories: [Category(name: "Engineering")], contents: ""),
            Job(id: 2, name: "iOS Engineer", locations: [Location(name: "Almaty")], company: CompanySummary(name: "MobileSolutions"), categories: [Category(name: "Engineering")], contents: ""),
            Job(id: 3, name: "Project Manager", locations: [Location(name: "Astana")], company: CompanySummary(name: "BizGroup"), categories: [Category(name: "Management")], contents: ""),
            Job(id: 4, name: "Remote iOS Developer", locations: [Location(name: "Remote")], company: CompanySummary(name: "Global LTD"), categories: [Category(name: "Engineering")], contents: "")
        ]
    }

    override func tearDownWithError() throws {
        viewModel = nil
        mockJobService = nil
        mockAuthViewModel = nil
        try super.tearDownWithError()
    }

    func testFilterBySearchText_JobName() {
        viewModel.searchText = "Swift"
        XCTAssertEqual(viewModel.filteredJobs.count, 1, "Должна найтись 1 вакансия по 'Swift'")
        XCTAssertEqual(viewModel.filteredJobs.first?.name, "Swift Developer")
    }

    func testFilterBySearchText_CompanyName() {
        viewModel.searchText = "TechCorp"
        XCTAssertEqual(viewModel.filteredJobs.count, 1, "Должна найтись 1 вакансия по компании 'TechCorp'")
        XCTAssertEqual(viewModel.filteredJobs.first?.company.name, "TechCorp")
    }
    
    func testFilterBySearchText_PartialCaseInsensitive() {
        viewModel.searchText = "developer"
        XCTAssertEqual(viewModel.filteredJobs.count, 2, "Должно найтись 2 вакансии по 'developer'")
    }

    func testFilterByLocation() {
        viewModel.selectedLocation = "Almaty"
        XCTAssertEqual(viewModel.filteredJobs.count, 1, "Должна найтись 1 вакансия в 'Almaty'")
        XCTAssertEqual(viewModel.filteredJobs.first?.name, "iOS Engineer")
    }
    
    func testFilterByLocation_All() {
        viewModel.selectedLocation = "All"
        XCTAssertEqual(viewModel.filteredJobs.count, 4, "Должны найтись все 4 вакансии при Location = 'All'")
    }

    func testFilterByCategory() {
        viewModel.selectedCategory = "Management"
        XCTAssertEqual(viewModel.filteredJobs.count, 1, "Должна найтись 1 вакансия в категории 'Management'")
        XCTAssertEqual(viewModel.filteredJobs.first?.name, "Project Manager")
    }
    
    func testFilterBySearchTextAndCategory() {
        viewModel.searchText = "iOS"
        viewModel.selectedCategory = "Engineering"
        XCTAssertEqual(viewModel.filteredJobs.count, 2, "Должно найтись 2 'iOS' вакансии в 'Engineering'")
    }
    
    func testFilter_NoResults() {
        viewModel.searchText = "NonExistentJob"
        viewModel.selectedLocation = "Mars"
        viewModel.selectedCategory = "NonExistentCategory"
        XCTAssertTrue(viewModel.filteredJobs.isEmpty, "Не должно найтись вакансий по очень специфичному запросу")
    }
    
    func testFilter_DefaultShowsAll() {
        viewModel.searchText = ""
        viewModel.selectedLocation = "All"
        viewModel.selectedCategory = "All" 
        XCTAssertEqual(viewModel.filteredJobs.count, viewModel.jobs.count, "По умолчанию должны отображаться все вакансии")
    }
}
