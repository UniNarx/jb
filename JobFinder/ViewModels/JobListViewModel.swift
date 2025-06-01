import Foundation
import Combine
import FirebaseAuth


final class JobListViewModel: ObservableObject {
    private let service: JobServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    private var authViewModel: AuthViewModel

    @Published var jobs: [Job] = []
    @Published var searchText = ""
    @Published var selectedLocation = "All"
    @Published var selectedCategory = "All"
    @Published var currentPage = 1
    @Published var totalPages = 1
    @Published var isLoading = false

    @Published var savedJobIDs: Set<Int> = []
    @Published var respondedJobIDs: Set<Int> = []

    init(service: JobServiceProtocol = JobService(), authViewModel: AuthViewModel) {
        self.service = service
        self.authViewModel = authViewModel

        loadPage(1)

        authViewModel.$userSession
            .receive(on: DispatchQueue.main)
            .sink { [weak self] firebaseUserSession in
                self?.handleUserSessionChange(userSession: firebaseUserSession)
            }
            .store(in: &cancellables)

        authViewModel.$currentUserProfile
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userProfile in
                self?.updateJobIDsFromProfile(userProfile: userProfile)
            }
            .store(in: &cancellables)

        if authViewModel.userSession != nil {
            if let profile = authViewModel.currentUserProfile {
                updateJobIDsFromProfile(userProfile: profile)
            } else {
                self.savedJobIDs = []
                self.respondedJobIDs = []
            }
        } else {
            self.savedJobIDs = []
            self.respondedJobIDs = []
            print("JobListViewModel: Пользователь не авторизован. savedJobIDs и respondedJobIDs инициализированы пустыми.")
        }
    }

    private func handleUserSessionChange(userSession: FirebaseAuth.User?) {
        if let user = userSession {
            print("JobListViewModel: Пользователь вошел (\(user.uid)). Обновляем Job IDs из профиля (если есть).")
            if let profile = authViewModel.currentUserProfile {
                updateJobIDsFromProfile(userProfile: profile)
            } else {
                self.savedJobIDs = []
                self.respondedJobIDs = []
            }
        } else {
            print("JobListViewModel: Пользователь вышел. savedJobIDs и respondedJobIDs очищены.")
            self.savedJobIDs = []
            self.respondedJobIDs = []
        }
    }

    private func updateJobIDsFromProfile(userProfile: UserProfile?) {
        if let profile = userProfile, authViewModel.userSession != nil {
            print("JobListViewModel: Обновление Job IDs из профиля Firebase: \(profile.fullName)")
            self.savedJobIDs = Set(profile.savedJobIDs ?? [])
            self.respondedJobIDs = Set(profile.respondedJobIDs ?? [])
        } else if authViewModel.userSession == nil {
           
        }
    }



    func toggleSave(jobID: Int) {
        guard authViewModel.userSession != nil else {
            print("JobListViewModel: Пользователь не авторизован. Действие 'toggleSave' проигнорировано.")
            return
        }

        if savedJobIDs.contains(jobID) {
            print("JobListViewModel: Пользователь авторизован. Удаляем savedJob ID (\(jobID)) через Firebase.")
            authViewModel.removeSavedJobFromProfile(jobID: jobID) { error in
                if let error = error {
                    print("DEBUG: Ошибка удаления savedJob ID (\(jobID)) из Firebase: \(error.localizedDescription)")
                } else {
                    print("DEBUG: Firebase успешно удалил savedJob ID (\(jobID)). Локальные ID обновятся через подписку.")
                }
            }
        } else {
            print("JobListViewModel: Пользователь авторизован. Добавляем savedJob ID (\(jobID)) через Firebase.")
            authViewModel.addSavedJobToProfile(jobID: jobID) { error in
                if let error = error {
                    print("DEBUG: Ошибка добавления savedJob ID (\(jobID)) в Firebase: \(error.localizedDescription)")
                } else {
                    print("DEBUG: Firebase успешно добавил savedJob ID (\(jobID)). Локальные ID обновятся через подписку.")
                }
            }
        }
    }

    func recordResponse(jobID: Int) {
        guard authViewModel.userSession != nil else {
            print("JobListViewModel: Пользователь не авторизован. Действие 'recordResponse' проигнорировано.")
            return
        }

        guard !respondedJobIDs.contains(jobID) else {
            print("JobListViewModel: Уже откликались на вакансию ID (\(jobID)).")
            return
        }

        print("JobListViewModel: Пользователь авторизован. Добавляем respondedJob ID (\(jobID)) через Firebase.")
        authViewModel.addRespondedJobToProfile(jobID: jobID) { error in
            if let error = error {
                print("DEBUG: Ошибка добавления respondedJob ID (\(jobID)) в Firebase: \(error.localizedDescription)")
            } else {
                print("DEBUG: Firebase успешно добавил respondedJob ID (\(jobID)). Локальные ID обновятся через подписку.")
            }
        }
    }

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

    func loadPage(_ page: Int) {
        guard !isLoading && page <= totalPages else { return }
        isLoading = true
        service.fetchJobs(page: page) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let resp):
                    self.totalPages = resp.page_count
                    self.currentPage = resp.page
                    if page == 1 {
                        self.jobs = resp.results
                    } else {
                        let newJobs = resp.results.filter { newJob in !self.jobs.contains(where: { $0.id == newJob.id }) }
                        self.jobs.append(contentsOf: newJobs)
                    }
                case .failure(let err):
                    print("Error loading jobs:", err)
                }
                self.isLoading = false
            }
        }
    }
}
