// RootView.swift
// Abstract Main

import SwiftUI

struct RootView: View {
    // MARK: – Persisted flags
    @AppStorage("isSignedIn")   private var isSignedIn   = false
    @AppStorage("userType")     private var userTypeRaw  = UserType.explorer.rawValue
    @AppStorage("staySignedIn") private var staySignedIn = false

    // MARK: – Control showing the splash screen
    @State private var showSplash = true

    // Compute our UserType from the stored raw string
    private var userType: UserType {
        UserType(rawValue: userTypeRaw) ?? .explorer
    }

    // Erased content so all branches compile to AnyView
    private var content: AnyView {
        if showSplash {
            return AnyView(SplashView())
        }

        if isSignedIn {
            // ← Now passing `userType:` here
            return AnyView(MainTabView(userType: userType))
        }

        // Not signed in → show authentication
        return AnyView(
            AuthenticationView(
                isSignedIn: $isSignedIn,
                userTypeRaw: $userTypeRaw
            )
        )
    }

    var body: some View {
        content
            .onAppear {
                // Hide splash after a short delay (skip if “staySignedIn”)
                let delay = (staySignedIn && isSignedIn) ? 0.3 : 1.5
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    showSplash = false
                }
            }
    }
}

