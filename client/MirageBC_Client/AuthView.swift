//
//  AuthView.swift
//  MirageBC_Client
//
//  Created by LEV POLYAKOV on 15.06.2019.
//  Copyright © 2019 Lev Polyakov. All rights reserved.
//

import SwiftUI
import Moya
import ObjectMapper
import Moya_ObjectMapper

class AuthViewModel {
    let provider = MoyaProvider<UserActions>()
    
    func authorize(image: UIImage,  completion: @escaping (User?) -> ()) {
        provider.request(.authorization(image: image)) { (response) in
            switch response.result {
            case let .success(response):
                do {
                    let user = try response.mapObject(User.self)
                    completion(user)
                } catch {
                    completion(nil)
                }
            case let .failure(error):
                print(error)
                completion(nil)
            }
        }
    }
}


struct AuthView : View {
    let model = AuthViewModel()
    
    @Binding var currentUser: User?
    @State var image: UIImage? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 30)
            VStack {
                Text("Для входа прикрепите вашу фото")
                if image != nil {
                    Image(uiImage: image!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100, alignment: .center)
                } else {
                    PresentationButton(Text("Прикрепить фото"), destination: ImagePickerView(image: $image))
                }
            }
            
            Button(action: {
                if let image = self.image {
                    self.model.authorize(image: image) { (user) in
                        if let user = user {
                            UserDefaults.standard.setValue(user.userId, forKey: "currentUser")
                            UserDefaults.standard.synchronize()
                            self.currentUser = user                            
                        } else {
                            // Show error
                        }
                    }
                }
            }, label: {
                Text("Авторизация")
                    .padding(.init(top: 10, leading: 30, bottom: 10, trailing: 30))
                    .background(Color.orange)
                    .cornerRadius(5)
            }).disabled({
                return image == nil
                }())
            Spacer(minLength: 400)
        }
    }
}

#if DEBUG
struct AuthView_Previews : PreviewProvider {
    @State static var user: User? = nil
    
    static var previews: some View {
        AuthView(currentUser: $user)
    }
}
#endif
