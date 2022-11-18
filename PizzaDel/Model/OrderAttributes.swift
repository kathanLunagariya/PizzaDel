//
//  OrderAttributes.swift
//  PizzaDel
//
//  Created by Kathan Lunagariya on 14/11/22.
//

import ActivityKit
import Foundation

struct OrderAttributes:ActivityAttributes{
    
    //Dynamic values...
    struct ContentState:Codable, Hashable{
        var deliveryBoyState:DeliveryBoyState
        var pizzaOrderState:OrderState
    }
    
    //Static values...
    var noOfPizza:Int
    var address:String
    var expectedTime:Date
}
