import SwiftUI

struct JobDetailView: View {
    let job: Job
    @EnvironmentObject private var vm: JobListViewModel

    @State private var showSuccessBanner = false

    var body: some View {
        VStack(spacing: 0) {
            if showSuccessBanner {
                Text("You've applied for this job!")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(job.name).font(.title2).bold()
                    Text(job.company.name)
                        .font(.headline).foregroundColor(.secondary)

                    if !job.locations.isEmpty {
                        Text("Locations:").font(.subheadline).bold()
                        ForEach(job.locations, id: \.name) {
                            Text("• \($0.name)")
                        }
                    }

                    Text("Description:").font(.headline)
                    HTMLView(html: job.contents)
                        .frame(minHeight: 300)

                    HStack(spacing: 12) {
                        Button {
                            vm.toggleSave(jobID: job.id)
                        } label: {
                            HStack {
                                Image(systemName: vm.savedJobIDs.contains(job.id)
                                      ? "bookmark.fill" : "bookmark")
                                Text(vm.savedJobIDs.contains(job.id) ? "Unsave" : "Save")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                        }

                        if vm.respondedJobIDs.contains(job.id) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Applied")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(8)
                        } else {
                            Button {
                                vm.recordResponse(jobID: job.id)
                                withAnimation { showSuccessBanner = true }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    withAnimation { showSuccessBanner = false }
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "paperplane.fill")
                                    Text("Apply")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.top)

                    Spacer()
                }
                .padding()
            }
        }
        .navigationTitle("Details")
    }
}
