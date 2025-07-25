//
//  CreatorVerificationView.swift
//  Abstract Main
//
//  Created by Preet Sahota on 6/4/25.
//


// CreatorVerificationView.swift

import SwiftUI

/// After a Creator signs up, they land here to verify themselves.
/// Once verification succeeds, we flip `isSignedIn = true` to show MainTabView.
struct CreatorVerificationView: View {
    /// Bound to AppStorage("isSignedIn") in Abstract_MainApp.swift
    @Binding var isSignedIn: Bool

    /// Simple text field for a “verification code” (you'll replace with real logic later)
    @State private var verificationInput: String = ""
    @State private var showError: Bool = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer().frame(height: 40)

            Text("Creator Verification")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundColor(.primary)

            Text("To finish creating your Creator account, please enter your unique verification code below. This helps us prevent bots or wholesalers from flooding the app.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 32)

            // MARK: – Verification code field
            TextField("Enter verification code", text: $verificationInput)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
                .padding(.horizontal, 32)

            if showError {
                Text("Invalid code. Please try again.")
                    .font(.caption)
                    .foregroundColor(.red)
            }

            // MARK: – Verify button
            Button(action: {
                attemptVerification()
            }) {
                Text("Verify My Account")
                    .foregroundColor(.white)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(8)
            }
            .padding(.horizontal, 32)

            Spacer()
        }
        .navigationTitle("Creator Verification")
    }

    /// Dummy verification logic: if the code is “1234”, we succeed; otherwise show error.
    private func attemptVerification() {
        if verificationInput == "1234" {
            // In a real app, you’d call your backend here to verify.
            isSignedIn = true
        } else {
            showError = true
        }
    }
}

struct CreatorVerificationView_Previews: PreviewProvider {
    @State static var signedIn = false
    static var previews: some View {
        NavigationStack {
            CreatorVerificationView(isSignedIn: $signedIn)
        }
    }
}
