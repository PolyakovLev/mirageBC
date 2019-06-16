//
//  OrdersListView.swift
//  MirageBC_Client
//
//  Created by LEV POLYAKOV on 15.06.2019.
//  Copyright © 2019 Lev Polyakov. All rights reserved.
//

import SwiftUI
import Moya
import ObjectMapper
import Moya_ObjectMapper
import Combine

struct Identifier<Value>: Hashable {
    let string: String
}

struct UserInfo: Mappable, Identifiable {
    var id: Identifier<UserInfo> {
        return Identifier<UserInfo>(string: userName)
    }
    
    var userName: String!
    var phone: String!
    var discount: String?
    var orders: [Order] = []
    
    init(map: Map) {
        userName <- map["username"]
        phone <- map["phone"]
        orders <- map["orders"]
        discount <- map["discount"]
        
    }
    
    mutating func mapping(map: Map) {
        discount <- map["discount"]
        userName <- map["username"]
        phone <- map["phone"]
        orders <- map["orders"]
    }
}

struct Order: Mappable, Identifiable {
    var id: Identifier<Order> {
        return Identifier<Order>(string: orderId)
    }
    var orderId: String!
    var date: Date!
    var order: String!
    
    init?(map: Map) {
        orderId <- map["id"]
        date <- (map["date"], DateTransform())
        order <- map["order"]
    }
    
    mutating func mapping(map: Map) {
        orderId <- map["id"]
        date <- (map["date"], DateTransform())
        order <- map["order"]
    }
}


class OrderListViewModel: BindableObject {
    let provider = MoyaProvider<UserActions>()
    let didChange = PassthroughSubject<UserInfo?,Never>()
    var currentUser: User
    
    var userInfo: UserInfo?{
        didSet {
            didChange.send(userInfo)
        }
    }
    
    init(currentUser: User) {
        self.currentUser = currentUser
        update()
    }
    
    func update() {
        self.userInfo = nil
        provider.request(.userInfo(userId: currentUser.userId ?? "")) { (response) in
            switch response.result {
            case let .success(response):
                do {
                    self.userInfo = try response.mapObject(UserInfo.self)
                } catch let error {
                    let alertVC = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                    alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    UIApplication.shared.keyWindow?.rootViewController?.present(alertVC, animated: true, completion: nil)
                }
            case let .failure(error):
                let alertVC = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                UIApplication.shared.keyWindow?.rootViewController?.present(alertVC, animated: true, completion: nil)
            }
        }
    }
}

struct OrdersListView : View {
    @Binding var currentUser: User?
    @ObjectBinding var model: OrderListViewModel
    let dateFormatter = DateFormatter()
    
    init(currentUser: Binding<User?>) {
        $currentUser = currentUser
        model = OrderListViewModel(currentUser: currentUser.value!)
        dateFormatter.dateStyle = .short
    }
//
    var body: some View {
        List {
            
            Group {
                if self.model.userInfo != nil {
                    VStack(alignment: .leading) {
                        Text("Имя: \(model.userInfo!.userName)")
                        Text("Телефон: \(model.userInfo!.phone)")
                        Text("Скидка: \(model.userInfo!.discount ?? "") %")
                    }
                    ForEach(model.userInfo!.orders) { order in
                        HStack(spacing: 10) {
                            VStack(alignment: .leading) {
                                Text("Заказ #\(order.orderId)")
                                Text("От \(self.dateFormatter.string(from: order.date))")
                            }
                            Text(order.order)
                                .lineLimit(nil)
                        }
                    }
                } else {
                    Text("Loading")
                }
            }
        }
            .navigationBarTitle(Text("Ваши заказы"))
            .navigationBarItems(
                leading: Button(action: {
                    UserDefaults.standard.removeObject(forKey: "currentUser")
                    UserDefaults.standard.synchronize()
                    self.currentUser = nil
                }, label: {Text("Выход")}),
                trailing: Button(action: {
                    self.model.update()
                }) { Text("Обновить")} )
    }
}


#if DEBUG
struct OrdersListView_Previews : PreviewProvider {
    @State static var user: User? = User(JSON: ["userId": "1"])
    
    static var previews: some View {
        OrdersListView(currentUser: $user)
    }
}
#endif
