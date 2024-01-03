//
//  ContentView.swift
//  cenima
//
//  Created by Aniurm on 2023/11/27.
//

import SwiftUI

struct NaviView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ViewController {
        return ViewController()
    }

    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
        // Update the view controller if needed
    }
}

struct ContentView: View {
    var body: some View {
        VStack {
            // Embed the UIViewControllerRepresentable
            NaviView()
        }
        .padding()
    }
}
