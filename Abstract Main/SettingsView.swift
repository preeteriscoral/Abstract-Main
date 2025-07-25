import SwiftUI

struct SettingsView: View {
  var body: some View {
    List {
      Section("Security") {
        NavigationLink("Reset Password", destination: Text("🔒 Reset Password"))
        NavigationLink("Two-Factor Auth", destination: Text("🔑 Two-Factor Auth"))
      }
      Section("Profile") {
        NavigationLink("Change Username", destination: Text("✏️ Change Username"))
        NavigationLink("Archive Posts", destination: Text("🗄️ Archive Posts"))
      }
      Section("Payments") {
        NavigationLink("Orders & Payments", destination: Text("💳 Orders & Payments"))
      }
    }
    .navigationTitle("Settings")
    .listStyle(.insetGrouped)
  }
}

