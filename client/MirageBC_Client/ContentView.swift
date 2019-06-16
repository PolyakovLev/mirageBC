//
//  ContentView.swift
//  MirageBC_Client
//
//  Created by LEV POLYAKOV on 15.06.2019.
//  Copyright © 2019 Lev Polyakov. All rights reserved.
//

import SwiftUI

struct ContentView : View {
    @State var currentUser: User? = nil
    
    var body: some View {
        NavigationView {
            Group {
                if self.currentUser != nil {
                    OrdersListView(currentUser: $currentUser)
                } else {
                    NeedAuthView(currentUser: $currentUser)
                }
            }
        }
    }
}

struct NeedAuthView: View {
    @Binding var currentUser: User?
    
    var body: some View {
        VStack(alignment: .center, spacing: 100) {
            Image("osel")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 300, height: nil, alignment: .center)
            VStack(spacing: 20.0) {
                NavigationButton(destination: RegistationView(currentUser: $currentUser, name: "", phone: "", image: nil, registered: false)) {
                    Text("Регистрация")
                        .padding(.init(top: 10, leading: 30, bottom: 10, trailing: 30))
                        .background(Color.orange)
                        .cornerRadius(5)
                }
                NavigationButton(destination: AuthView(currentUser: $currentUser, image: nil)) {
                    Text("Авторизация")
                        .padding(.init(top: 10, leading: 30, bottom: 10, trailing: 30))
                        .background(Color.orange)
                        .cornerRadius(5)
                }
            }
            Spacer()
            }.navigationBarTitle(Text("Вкусно-кофе"))
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
