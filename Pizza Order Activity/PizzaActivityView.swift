//
//  PizzaActivityView.swift
//  Pizza Order ActivityExtension
//
//  Created by Kathan Lunagariya on 14/11/22.
//

import SwiftUI
import WidgetKit
import ActivityKit

struct PizzaActivityView: View {
    let context:ActivityViewContext<OrderAttributes>
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.gradient)
            
            VStack{
                HStack{
                    VStack(alignment: .leading, spacing: 5){
                        Text("PizzaDel")
                            .foregroundColor(Color.yellow)
                            .font(.system(size: 20))
                            .bold()
                        Text("Your Order: " + context.attributes.noOfPizza.formatted() + " Pizza(s)")
                            .foregroundColor(Color.gray)
                            .font(.system(size: 13))
                        Text("-" + context.state.pizzaOrderState.rawValue.components(separatedBy: " | ")[1])
                            .foregroundColor(Color.black)
                            .font(.subheadline)
                            .bold()
                    }
                    .padding(.trailing, 10)
                    
                    Spacer()
                    Divider()
                    
                    VStack(alignment: .center){
                        HStack{
                            Image(systemName: "timer")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.gray)
                                .frame(width: 30, height: 30)
                            
                            if context.state.pizzaOrderState == .atDoorStep || context.state.pizzaOrderState == .delivered{
                                Text(context.attributes.expectedTime, style: .time)
                                    .foregroundColor(.green)
                            }else{
                                Text(context.attributes.expectedTime, style: .timer)
                            }
                        }
                        
                        Text(context.state.deliveryBoyState.rawValue)
                            .foregroundColor(Color.gray)
                            .font(.system(size: 13))
                    }
                    .frame(width: 110)
                    .padding(.leading, 10)
                }
                .padding(.horizontal)
                
                //order-tracking status view
                HStack(spacing: 25){
                    ForEach(OrderState.allCases, id: \.self){state in
                        OrderStatusView(orderState: state, context: context)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top, 10)
            .padding(.bottom, 10)
        }
    }
}


struct OrderStatusView:View{
    let orderState:OrderState
    let context:ActivityViewContext<OrderAttributes>
    
    var body: some View{
        VStack{
            Text(orderState.rawValue.components(separatedBy: " | ")[0])
                .foregroundColor(.black)
                .font(.system(size: 10))
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .scaledToFit()
            
            Image(systemName: isStatusCompleted() ? "checkmark.circle.fill" : "circle.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(.gray)
                .frame(width: 25, height: 25)
        }
    }
    
    func isStatusCompleted() -> Bool{
        guard let stateIndex = orderState.index, let orderStateIndex = context.state.pizzaOrderState.index else{ return false }
        return stateIndex <= orderStateIndex
    }
}
