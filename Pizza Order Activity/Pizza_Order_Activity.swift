//
//  Pizza_Order_Activity.swift
//  Pizza Order Activity
//
//  Created by Kathan Lunagariya on 14/11/22.
//

import WidgetKit
import SwiftUI
import ActivityKit

@main
struct PizzaOrderActivity:Widget{
    var body: some WidgetConfiguration{
        ActivityConfiguration(for: OrderAttributes.self) { context in
            
            //LiveActivity View...
            PizzaActivityView(context: context)
            
        }
        dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text("PizzaDel")
                        .foregroundColor(Color.yellow)
                        .font(.system(size: 17))
                        .bold()
                }
                
                DynamicIslandExpandedRegion(.center){
                    Text("Your Order: " + context.attributes.noOfPizza.formatted() + " Pizza(s)")
                        .foregroundColor(Color.white)
                }
                
                DynamicIslandExpandedRegion(.trailing){
                    HStack{
                        if context.state.pizzaOrderState == .atDoorStep || context.state.pizzaOrderState == .delivered{
                            Text(context.attributes.expectedTime, style: .time)
                                .foregroundColor(.green)
                                .padding(.leading, 7)
                        }else{
                            Text(context.attributes.expectedTime, style: .timer)
                                .padding(.horizontal)
                        }
                    }
                }
                
                DynamicIslandExpandedRegion(.bottom){
                    Text("·" + context.state.pizzaOrderState.rawValue.components(separatedBy: " | ")[1])
                        .foregroundColor(Color.yellow)
                        .font(.subheadline)
                        .bold()
                }
            }
            compactLeading: {
                Image(systemName: context.state.pizzaOrderState.rawValue.components(separatedBy: " | ")[2])
                    .resizable()
                    .scaledToFit()
            }
            compactTrailing: {
                Image(systemName: "timer")
                    .resizable()
                    .scaledToFit()
            }
            minimal: {
                Image(systemName: "timer")
                    .resizable()
                    .scaledToFit()
            }
        }
    }
}
