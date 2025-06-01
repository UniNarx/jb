import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var vm: JobListViewModel
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        if authViewModel.userSession == nil {
            AuthView(authViewModel: authViewModel)
        } else {
            TabView {
                NavigationView {
                    VStack(spacing: 0) {
                        HStack {
                            Text("Location:")
                            Picker("", selection: $vm.selectedLocation) {
                                ForEach(vm.locations, id: \.self) { Text($0) }
                            }
                            .pickerStyle(.menu)

                            Spacer(minLength: 16)

                            Text("Category:")
                            Picker("", selection: $vm.selectedCategory) {
                                ForEach(vm.categories, id: \.self) { Text($0) }
                            }
                            .pickerStyle(.menu)
                        }
                        .padding(.horizontal)

                        List {
                            ForEach(vm.filteredJobs) { job in
                                NavigationLink {
                                    JobDetailView(job: job)
                                        .environmentObject(vm)
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(job.name).font(.headline)
                                            Text(job.company.name)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                            if let cat = job.categories.first?.name {
                                                Text(cat)
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                        Spacer()
                                        Image(systemName: vm.savedJobIDs.contains(job.id)
                                              ? "bookmark.fill"
                                              : "bookmark")
                                            .imageScale(.large)
                                    }
                                }
                                .buttonStyle(.plain)
                                .onAppear {
                                    if job == vm.filteredJobs.last {
                                        vm.loadPage(vm.currentPage + 1)
                                    }
                                }
                            }

                            if vm.isLoading {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                    Spacer()
                                }
                            }
                        }
                        .listStyle(.plain)
                        .searchable(text: $vm.searchText,
                                    placement: .navigationBarDrawer(displayMode: .always))
                    }
                    .navigationTitle("JobFinder")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Выйти") {
                                authViewModel.signOut()
                            }
                        }
                    }
                }
                .tabItem { Label("Jobs", systemImage: "magnifyingglass") }

                NavigationView {
                    SavedJobsView()
                        .environmentObject(vm)
                }
                .tabItem { Label("Saved", systemImage: "bookmark.fill") }
                 ProfileView()
                    .tabItem { Label("Profile", systemImage: "person.crop.circle") }

                SettingsView()
                    .tabItem { Label("Settings", systemImage: "gearshape") }

                StatsView()
                    .environmentObject(vm)
                    .tabItem { Label("Stats", systemImage: "chart.bar") }
            }
        }
    }
}
