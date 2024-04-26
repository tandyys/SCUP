//
//  PhototsView.swift
//  SCUP
//
//  Created by tandyys on 25/04/24.
//

import SwiftUI

struct PhototsView: View {
    @State private var isViewControllerPresented = false
    var body: some View {
            VStack {
                Button("Show ViewController") {
                    self.isViewControllerPresented.toggle()
                }
            }
            .sheet(isPresented: $isViewControllerPresented) {
                ViewControllerWrapper()
            }
        }
}

#Preview {
    PhototsView()
}
