//
//  RegistationView.swift
//  MirageBC_Client
//
//  Created by LEV POLYAKOV on 15.06.2019.
//  Copyright © 2019 Lev Polyakov. All rights reserved.
//

import SwiftUI
import Moya
import ObjectMapper
import Moya_ObjectMapper

struct User: Mappable, Codable {
    
    var userId: String?
    
    // MARK: JSON
    init?(map: Map) {
        userId <- map["userId"]
        guard userId != nil else { return nil }
    }
    
    mutating func mapping(map: Map) {
        userId <- map["userId"]
    }
    
}

class RegistationViewModel {
    let provider = MoyaProvider<UserActions>()
    
    func register(name: String, phone: String, image: UIImage,  completion: @escaping (User?) -> ()) {
        provider.request(.registration(image: image, name: name, number: phone)) { (response) in
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
    
    func alerControllerPresent(message: String)  {
        let ac = UIAlertController(title: "Error", message: "Sorry registration fail", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        ac.addAction(okAction)
    
    }
}

struct RegistationView : View {
    @Binding var currentUser: User?
    @State var name: String = ""
    @State var phone: String = ""
    @State var image: UIImage? = nil
    @State var registered = false
    
    let model = RegistationViewModel()
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(spacing: 20) {
                Spacer(minLength: 30)
                VStack(alignment: .leading) {
                    Text("Имя")
                        .padding(.bottom, -10)
                    TextField($name, placeholder: Text("Иван"))
                }.padding(.leading, 20.0)
                
                VStack(alignment: .leading) {
                    Text("Телефон")
                        .padding(.bottom, -10)
                    TextField($phone, placeholder: Text("79265555555"))
                }.padding(.leading, 20.0)
                
                VStack {
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
                        self.model.register(name: self.name, phone: self.phone, image: image) { (user) in
                            if let user = user {
                                UserDefaults.standard.setValue(user.userId, forKey: "currentUser")
                                UserDefaults.standard.synchronize()
                                self.currentUser = user                            
                            } else {
                                let ac = UIAlertController(title: "Error", message: "Sorry registration fail", preferredStyle: .alert)
                                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                
                                ac.addAction(okAction)
                            }
                        }
                    }
                }, label: {
                    Text("Регистрация")
                        .padding(.init(top: 10, leading: 30, bottom: 10, trailing: 30))
                        .background(Color.orange)
                        .cornerRadius(5)
                })
                    .disabled({
                        return name.isEmpty || phone.isEmpty || image == nil
                    }())
                Spacer(minLength: 400)
            }
        }
    }
}

#if DEBUG
struct RegistationView_Previews : PreviewProvider {
    @State static var user: User? = nil
    
    static var previews: some View {
        RegistationView(currentUser: $user, name: "", phone: "", image: nil, registered: false)
    }
}
#endif
