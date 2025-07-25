import SwiftUI

struct EditProfileView: View {
    @Binding var fullName: String
    @Binding var handle: String
    @Binding var bio: String
    @Binding var avatar: Image?

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Profile Info")) {
                    TextField("Full Name", text: $fullName)
                    TextField("Handle", text: $handle)
                    TextField("Bio", text: $bio)
                }
                Section(header: Text("Avatar")) {
                    avatar?
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .padding(.vertical)
                }
            }
            .navigationTitle("Edit Profile")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView(
            fullName: .constant("HDV"),
            handle:   .constant("@hdvapparel"),
            bio:      .constant("Chicago Streetwear"),
            avatar:   .constant(Image(systemName: "person.crop.circle"))
        )
    }
}

