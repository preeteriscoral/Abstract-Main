import SwiftUI

struct ProfileView: View {
    var body: some View {
        VStack {
            Text("Welcome, Shopper!")
                .font(.title)
            Text("This is your profile.")
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding()
        .navigationTitle("Profile")
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
