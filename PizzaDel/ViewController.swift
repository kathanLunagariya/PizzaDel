//
//  ViewController.swift
//  PizzaDel
//
//  Created by Kathan Lunagariya on 14/11/22.
//

import UIKit
import ActivityKit

class ViewController: UIViewController {
    
    var activityId = ""
    var orderActivity:Activity<OrderAttributes>!
    
    let header:UILabel = {
        let lbl = UILabel()
        lbl.text = "PizzaDel"
        lbl.font = .boldSystemFont(ofSize: 30)
        lbl.textColor = .systemYellow
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    let orderHeader:UILabel = {
        let lbl = UILabel()
        lbl.text = "Order Pizza(s)"
        lbl.font = .systemFont(ofSize: 20, weight: .light)
        lbl.textColor = .darkGray
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    let orderCountLabel:UILabel = {
        let lbl = UILabel()
        lbl.text = "1"
        lbl.font = .systemFont(ofSize: 100, weight: .black, width: .condensed)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    let orderCounter:UIStepper = {
        let stepper = UIStepper()
        stepper.minimumValue = 1
        stepper.maximumValue = 10
        stepper.autorepeat = false
        stepper.translatesAutoresizingMaskIntoConstraints = false
        return stepper
    }()
    
    let orderButton:UIButton = {
        let btn = UIButton()
        btn.configuration = .gray()
        btn.configuration?.title = "Confirm Order"
        btn.configuration?.image = UIImage(systemName: "checkmark.circle.fill")
        btn.configuration?.imagePlacement = .trailing
        btn.configuration?.imagePadding = 8
        btn.configuration?.cornerStyle = .capsule
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(header)
        view.addSubview(orderHeader)
        view.addSubview(orderCountLabel)
        view.addSubview(orderCounter)
        view.addSubview(orderButton)
        
        orderCounter.addTarget(self, action: #selector(updatePizzaCount), for: .valueChanged)
        orderButton.addTarget(self, action: #selector(didTapConfirmOrder), for: .touchUpInside)
        
        NotificationCenter.default.addObserver(self, selector: #selector(modifyOrderButton), name: NSNotification.Name("Accept-Order-Button"), object: nil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            orderCountLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            orderCountLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            orderHeader.bottomAnchor.constraint(equalTo: orderCountLabel.topAnchor, constant: -25),
            orderHeader.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            orderCounter.topAnchor.constraint(equalTo: orderCountLabel.bottomAnchor, constant: 13),
            orderCounter.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            orderButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            orderButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15),
            orderButton.widthAnchor.constraint(equalToConstant: 200),
            orderButton.heightAnchor.constraint(equalToConstant: 45)
        ])
    }
    
    @objc func updatePizzaCount(_ counter:UIStepper){
        DispatchQueue.main.async {
            self.orderCountLabel.text = "\(Int(counter.value))"
        }
    }
    
    @objc func didTapConfirmOrder(){
        let orderAttributes = OrderAttributes(noOfPizza: Int(orderCounter.value), address: "Sai Archana, 11-Aryanagar, Rajkot-03.", expectedTime: .now.addingTimeInterval(60 * 5))
        let orderInitState = ActivityStateManager.fetchUpdateContentState(for: OrderState.allCases[0])
        
        do{
            let activity = try Activity<OrderAttributes>.request(attributes: orderAttributes, contentState: orderInitState, pushType: .none)
            self.orderButton.isUserInteractionEnabled = false
            
            ActivityStateManager.activity = activity
            self.orderActivity = activity
            self.activityId = activity.id
            
            self.executeOrderStatusUpdation()
        }catch{
            print("oops!", error)
        }
    }
    
    @objc func modifyOrderButton(_ notification:NSNotification){
        if let info = notification.userInfo, let asAcceptance = info["asAcceptance"] as? Bool{
            orderButton.removeTarget(self, action: asAcceptance ? #selector(didTapConfirmOrder) : #selector(evalAcceptMyOrder), for: .touchUpInside)
            orderButton.configuration?.title = asAcceptance ? "Accept Order" : "Confirm Order"
            orderButton.tintColor = asAcceptance ? .systemGreen : .systemBlue
            
            orderButton.addTarget(self, action: asAcceptance ? #selector(evalAcceptMyOrder) : #selector(didTapConfirmOrder), for: .touchUpInside)
            orderButton.isUserInteractionEnabled = true
            
            if !asAcceptance, orderActivity != nil{
                orderCounter.value = 1
                updatePizzaCount(orderCounter)
                
                Task{
                    await orderActivity!.end(using: orderActivity!.contentState, dismissalPolicy: .after(.now.addingTimeInterval(2)))
                    
                    ActivityStateManager.activity = nil
                    self.orderActivity = nil
                    self.activityId = ""
                }
            }
        }
    }
}


extension ViewController{
    
    func executeOrderStatusUpdation(){
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            let manager = ActivityRefreshManager.shared
            manager.setupSoundTimer()
        }
    }
    
    @objc func evalAcceptMyOrder(){
        guard orderActivity != nil else{ return }
        
        DispatchQueue.main.async{
            let updatedState = OrderAttributes.ContentState(deliveryBoyState: .found, pizzaOrderState: .delivered)
            Task{
                await self.orderActivity!.update(using: updatedState)
                NotificationCenter.default.post(name: NSNotification.Name("Accept-Order-Button"), object: nil, userInfo: ["asAcceptance" : false])
            }
        }
    }
}
