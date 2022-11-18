//
//  AttributeModel.swift
//  PizzaDel
//
//  Created by Kathan Lunagariya on 17/11/22.
//

import Foundation

enum OrderState:String, CaseIterable, Codable, Equatable{
    case received = "Received | Your order has been received. | doc.badge.plus"
    case cooking = "Cooking | Started cooking regarding your order. | microwave"
    case dispatched = "Dispatched | Your order is on the way. | shippingbox.and.arrow.backward.fill"
    case atDoorStep = "DoorStep | Order is arriving at your doorstep. | door.left.hand.closed"
    case delivered = "Delivered | Your order is delivered! | checkmark.circle.fill"
}

enum DeliveryBoyState:String, CaseIterable, Codable, Equatable{
    case finding = "finding nearby 🛵"
    case found = "🛵: Vanakr Bhai"
}

extension CaseIterable where Self: Equatable {
    var index: Self.AllCases.Index? {
        return Self.allCases.firstIndex { self == $0 }
    }
}
