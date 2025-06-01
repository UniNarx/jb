import Foundation

protocol JobServiceProtocol {
    func fetchJobs(page: Int, completion: @escaping (Result<JobsResponse, Error>) -> Void)
}
