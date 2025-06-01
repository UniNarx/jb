import Foundation
import Combine

final class JobListViewModel: ObservableObject {
    private let service: JobServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    @Published var jobs: [Job] = []
    @Published var searchText = ""
    @Published var selectedLocation = "All"
    @Published var selectedCategory = "All"
    @Published var currentPage = 1
    @Published var totalPages = 1
    @Published var isLoading = false
    @Published var savedJobIDs: Set<Int> = []
    @Published var responseCount: Int = UserDefaults.standard.integer(forKey: "responseCount")
    @Published var respondedJobIDs: Set<Int> =
    Set(UserDefaults.standard.array(forKey: "respondedJobs") as? [Int] ?? [])

    func recordResponse() {
        responseCount += 1
        UserDefaults.standard.set(responseCount, forKey: "responseCount")
    }
    func recordResponse(jobID: Int) {
            guard !respondedJobIDs.contains(jobID) else { return }
            respondedJobIDs.insert(jobID)
            UserDefaults.standard.set(Array(respondedJobIDs), forKey: "respondedJobs")
        }

    // Init
    init(service: JobServiceProtocol = JobService()) {
        self.service = service
        loadSavedJobs()
        loadPage(1)
    }

    // Computed
    var locations: [String] {
        let names = jobs.flatMap { $0.locations.map(\.name) }
        return ["All"] + Set(names).sorted()
    }
    var categories: [String] {
        let names = jobs.flatMap { $0.categories.map(\.name) }
        return ["All"] + Set(names).sorted()
    }
    var filteredJobs: [Job] {
        jobs.filter { job in
            let matchesSearch = searchText.isEmpty
                || job.name.localizedCaseInsensitiveContains(searchText)
                || job.company.name.localizedCaseInsensitiveContains(searchText)
            let matchesLocation = selectedLocation == "All"
                || job.locations.contains { $0.name == selectedLocation }
            let matchesCategory = selectedCategory == "All"
                || job.categories.contains { $0.name == selectedCategory }
            return matchesSearch && matchesLocation && matchesCategory
        }
    }

    // Pagination
    func loadPage(_ page: Int) {
        guard !isLoading && page <= totalPages else { return }
        isLoading = true
        service.fetchJobs(page: page) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let resp):
                self.totalPages = resp.page_count
                self.currentPage = resp.page
                if page == 1 {
                    self.jobs = resp.results
                } else {
                    self.jobs.append(contentsOf: resp.results)
                }
            case .failure(let err):
                print("Error loading jobs:", err)
            }
            self.isLoading = false
        }
    }

    // Persistence
    private func loadSavedJobs() {
        if let array = UserDefaults.standard.array(forKey: "savedJobs") as? [Int] {
            savedJobIDs = Set(array)
        }
    }
    func toggleSave(jobID: Int) {
        if savedJobIDs.contains(jobID) {
            savedJobIDs.remove(jobID)
        } else {
            savedJobIDs.insert(jobID)
        }
        saveSavedJobs()
    }
    private func saveSavedJobs() {
        UserDefaults.standard.set(Array(savedJobIDs), forKey: "savedJobs")
    }
}
