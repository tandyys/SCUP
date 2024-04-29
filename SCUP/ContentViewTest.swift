//
//  ContentViewTest.swift
//  SCUP
//
//  Created by Vincent Saranang on 25/04/24.
//

import SwiftUI

struct ContentViewTest: View {
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
    ContentViewTest()
}
