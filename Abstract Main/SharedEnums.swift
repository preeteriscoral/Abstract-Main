// SharedEnums.swift

import Foundation

/// At signup, user chooses either Explorer (shopper) or Creator
enum UserType: String, CaseIterable, Identifiable {
    case explorer = "Explorer"
    case creator  = "Creator"
    var id: String { rawValue }
}

/// Controls whether the auth screen is in Sign In or Sign Up mode
enum AuthMode {
    case signUp, signIn
}

