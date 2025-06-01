import SwiftUI

struct SettingsView: View {
    @AppStorage("jobEmailDigest")       private var jobEmailDigest = "daily"
    @AppStorage("jobPushAlerts")        private var jobPushAlerts = true
    @AppStorage("allowAnalytics")       private var allowAnalytics = false
    @AppStorage("sendCrashReports")     private var sendCrashReports = true
    @AppStorage("cacheSize")            private var cacheSize: Int = 0
    @AppStorage("fontSize")             private var fontSize = 1
    @AppStorage("accentColorIndex")     private var accentColorIndex = 0
    @AppStorage("betaFeaturesEnabled")  private var betaFeaturesEnabled = false

    let emailOptions = ["daily", "weekly", "off"]
    let fontSizes = ["Small", "Medium", "Large"]
    let accentColors = ["Blue", "Green", "Orange"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Jobs & Notifications")) {
                    Picker("Email Digest", selection: $jobEmailDigest) {
                        Text("Daily").tag("daily")
                        Text("Weekly").tag("weekly")
                        Text("Off").tag("off")
                    }
                }

                Section(header: Text("Privacy")) {
                    Toggle("Allow Anonymous Analytics", isOn: $allowAnalytics)
                    Toggle("Send Crash Reports", isOn: $sendCrashReports)
                }

                Section(header: Text("Feedback")) {
                    Link("Contact Support", destination: URL(string: "mailto:support@jobfinder.app")!)
                    Link("Rate on App Store",  destination: URL(string: "itms-apps://itunes.apple.com/app/idYOUR_APP_ID")!)
                }

                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                    }
                    Link("JobFinder Website", destination: URL(string: "https://yourapp.com")!)
                }
            }
            .navigationTitle("Settings")
        }
    }
}
