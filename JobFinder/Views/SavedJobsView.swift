import SwiftUI

struct SavedJobsView: View {
    @EnvironmentObject private var vm: JobListViewModel
    @State private var selectedTab: Tab = .saved

    enum Tab: String, CaseIterable, Identifiable {
        case saved = "Saved"
        case applied = "Applied"
        var id: Self { self }
    }

    private var savedJobs: [Job] {
        vm.jobs.filter { vm.savedJobIDs.contains($0.id) }
    }
    private var appliedJobs: [Job] {
        vm.jobs.filter { vm.respondedJobIDs.contains($0.id) }
    }

    var body: some View {
        VStack {
            Picker("Tabs", selection: $selectedTab) {
                ForEach(Tab.allCases) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            List {
                ForEach(selectedTab == .saved ? savedJobs : appliedJobs) { job in
                    NavigationLink {
                        JobDetailView(job: job)
                            .environmentObject(vm)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(job.name)
                                .font(.headline)
                            Text(job.company.name)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                if (selectedTab == .saved ? savedJobs : appliedJobs).isEmpty {
                    Text("No jobs here")
                        .foregroundColor(.secondary)
                        .italic()
                }
            }
        }
        .navigationTitle(selectedTab == .saved ? "Saved Jobs" : "Applied Jobs")
    }
}
