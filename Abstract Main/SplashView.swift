//
//  SplashView.swift
//  Abstract Main
//
//  Created by Preet Sahota on 6/4/25.
//


// SplashView.swift

import SwiftUI

struct SplashView: View {
    // Controls the logo’s fade/scale animation
    @State private var animateLogo = false

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            Image("AppLogo") // ← Replace "AppLogo" with the name of your actual asset
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .opacity(animateLogo ? 1 : 0)
                .scaleEffect(animateLogo ? 1 : 0.8)
                .onAppear {
                    withAnimation(.easeIn(duration: 0.6)) {
                        animateLogo = true
                    }
                }
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
