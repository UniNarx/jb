import Foundation

class JobService: JobServiceProtocol {
    private let baseURL = "https://www.themuse.com/api/public/jobs"

    func fetchJobs(page: Int = 1, completion: @escaping (Result<JobsResponse, Error>) -> Void) {
        guard var components = URLComponents(string: baseURL) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        components.queryItems = [ URLQueryItem(name: "page", value: String(page)) ]
        let request = URLRequest(url: components.url!)

        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error)); return
                }
                guard let data = data else {
                    completion(.failure(URLError(.badServerResponse))); return
                }
                do {
                    let resp = try JSONDecoder().decode(JobsResponse.self, from: data)
                    completion(.success(resp))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}
