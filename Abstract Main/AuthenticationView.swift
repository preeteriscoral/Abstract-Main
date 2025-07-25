// AuthenticationView.swift

import SwiftUI

struct AuthenticationView: View {
    @Binding var isSignedIn: Bool           // Bound to AppStorage("isSignedIn") in RootView
    @Binding var userTypeRaw: String        // Bound to AppStorage("userType") in RootView

    /// Now persists “stay signed in” preference across launches
    @AppStorage("staySignedIn") private var staySignedIn: Bool = false

    @State private var authMode: AuthMode = .signUp
    @State private var email: String = ""
    @State private var password: String = ""

    @State private var showVerification: Bool = false

    private var userType: UserType {
        get { UserType(rawValue: userTypeRaw) ?? .explorer }
        set { userTypeRaw = newValue.rawValue }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer().frame(height: 60)

                Text("Abstract")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                // 1) Explorer vs. Creator picker
                Picker("I am a …", selection: Binding(
                    get: { userTypeRaw },
                    set: { userTypeRaw = $0 }
                )) {
                    ForEach(UserType.allCases) { type in
                        Text(type.rawValue).tag(type.rawValue)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 32)

                // 2) Sign Up vs. Sign In picker
                Picker("", selection: $authMode) {
                    Text("Sign Up").tag(AuthMode.signUp)
                    Text("Sign In").tag(AuthMode.signIn)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 32)

                // 3) Email & Password fields
                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)

                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                }
                .padding(.horizontal, 32)

                // 4) "Stay signed in" toggle (now read/written to AppStorage)
                Toggle("Stay signed in", isOn: $staySignedIn)
                    .padding(.horizontal, 32)

                // 5) Primary button
                if userType == .creator && authMode == .signUp {
                    // Signing up as Creator → present verification screen
                    NavigationLink(
                        destination: CreatorVerificationView(isSignedIn: $isSignedIn),
                        isActive: $showVerification
                    ) {
                        Button(action: {
                            showVerification = true
                        }) {
                            Text("Sign Up as Creator")
                                .foregroundColor(.white)
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                        .padding(.horizontal, 32)
                    }
                    .isDetailLink(false)

                } else {
                    // Otherwise (Explorer SignUp, or any SignIn) → sign in directly
                    Button(action: {
                        authenticateDirectly()
                    }) {
                        let buttonTitle = (authMode == .signUp ? "Sign Up" : "Sign In")
                        Text("\(buttonTitle) as \(userType.rawValue)")
                            .foregroundColor(.white)
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal, 32)
                }

                Spacer()
            }
        }
    }

    /// For Explorer (or Sign In), we bypass Creator verification and set `isSignedIn = true` immediately.
    private func authenticateDirectly() {
        // In a real app: validate credentials here.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isSignedIn = true
        }
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    @State static var signedIn = false
    @State static var userTypeRaw = UserType.explorer.rawValue

    static var previews: some View {
        AuthenticationView(isSignedIn: $signedIn, userTypeRaw: $userTypeRaw)
    }
}

