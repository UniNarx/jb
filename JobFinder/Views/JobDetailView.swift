import SwiftUI

struct JobDetailView: View {
    let job: Job
    @EnvironmentObject private var vm: JobListViewModel
    @State private var showSuccessBanner = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                VStack(alignment: .leading, spacing: 8) {
                    Text(job.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    HStack {
                        Image(systemName: "building.2.fill")
                            .foregroundColor(.secondary)
                        Text(job.company.name)
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }

                    if !job.locations.isEmpty {
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundColor(.secondary)
                            Text(job.locations.map { $0.name }.joined(separator: ", "))
                                .font(.subheadline)
                        }
                    }
                    
                    if !job.categories.isEmpty {
                        HStack {
                            Image(systemName: "tag.fill")
                                .foregroundColor(.secondary)
                            Text(job.categories.map { $0.name }.joined(separator: ", "))
                                .font(.subheadline)
                                .foregroundColor(.accentColor)
                        }
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text("Описание вакансии")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    HTMLView(html: job.contents)
                        .frame(minHeight: 300)
                }
                
                Divider()

                VStack(spacing: 15) {
                    Button {
                        vm.toggleSave(jobID: job.id)
                    } label: {
                        HStack {
                            Image(systemName: vm.savedJobIDs.contains(job.id) ? "bookmark.fill" : "bookmark")
                            Text(vm.savedJobIDs.contains(job.id) ? "Убрать из сохраненных" : "Сохранить вакансию")
                        }
                        .font(.headline)
                        .foregroundColor(vm.savedJobIDs.contains(job.id) ? .white : .blue)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(vm.savedJobIDs.contains(job.id) ? Color.blue : Color.blue.opacity(0.15))
                        .cornerRadius(10)
                    }

                    if vm.respondedJobIDs.contains(job.id) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Вы откликнулись")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(10)
                    } else {
                        Button {
                            vm.recordResponse(jobID: job.id)
                            withAnimation { showSuccessBanner = true }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                withAnimation { showSuccessBanner = false }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "paperplane.fill")
                                Text("Откликнуться")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .cornerRadius(10)
                        }
                    }
                }
                .padding(.top)

            }
            .padding()
        }
        .navigationTitle("Детали вакансии")
        .navigationBarTitleDisplayMode(.inline)
        .overlay(alignment: .top) {
            if showSuccessBanner {
                Text("Вы успешно откликнулись!")
                    .font(.footnote)
                    .padding(8)
                    .frame(maxWidth: .infinity)
                    .background(.green.opacity(0.85))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            withAnimation {
                                showSuccessBanner = false
                            }
                        }
                    }
            }
        }
    }
}

