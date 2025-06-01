import SwiftUI

struct StatsView: View {
    @EnvironmentObject private var vm: JobListViewModel

    private var uniqueCompaniesCount: Int {
        Set(vm.jobs.map { $0.company.name }).count
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Applications")) {
                                    HStack {
                                        Text("You’ve applied:")
                                        Spacer()
                                        Text("\(vm.respondedJobIDs.count)")
                                    }
                                }
                Section(header: Text("Jobs Loaded")) {
                    HStack {
                        Text("Total jobs:")
                        Spacer()
                        Text("\(vm.jobs.count)")
                    }
                }
                Section(header: Text("Saved Jobs")) {
                    HStack {
                        Text("You’ve bookmarked:")
                        Spacer()
                        Text("\(vm.savedJobIDs.count)")
                    }
                }
                Section(header: Text("Companies")) {
                    HStack {
                        Text("Unique companies:")
                        Spacer()
                        Text("\(uniqueCompaniesCount)")
                    }
                }
            }
            .navigationTitle("Statistics")
        }
    }
}
