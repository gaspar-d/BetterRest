//
//  ContentView.swift
//  BetterRest
//
//  Created by Diogo Gaspar on 25/02/21.
//

import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }
    
    func calculateBedTime() {
        let model = SleepCalculator()
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
        let hour = (components.hour ?? 0) * 60 * 60
        let minute = (components.minute ?? 0) * 60
        
        do {
            let prediction = try
                model.prediction(wake: Double(hour + minute),
                                 estimatedSleep: sleepAmount,
                                 coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            
            alertMessage = formatter.string(from: sleepTime)
            alertTitle = "Your ideal bedtime is..."
            
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime"
        }
        
        showingAlert = true
    }
    
    var body: some View {
        NavigationView {
            Form {
                VStack(alignment: .leading) {
                    Text("When do you want to wake up?").font(.headline)
                    DatePicker("Please enter a time",
                               selection: $wakeUp,
                               displayedComponents: .hourAndMinute)
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                        .onChange(of: wakeUp, perform: { value in
                            calculateBedTime()
                        })
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Desired amount of sleep?").font(.headline)
                    Stepper(value: $sleepAmount, in: 4...12, step: 0.25) {
                        Text("\(sleepAmount, specifier: "%g") hours")
                    }
                    .onChange(of: sleepAmount, perform: { value in
                        calculateBedTime()
                    })
                    
                }
                
                VStack(alignment: .leading , spacing: 10) {
                    Text("Daily coffee intake")
                        .font(.headline)
                    Picker("Coffe intake", selection: $coffeeAmount) {
                        ForEach(1 ..< 20) {
                            Text("\($0)")
                        }
                    }
                    .onChange(of: coffeeAmount, perform: { value in
                                calculateBedTime()
                    })
                }
                .navigationBarTitle("BetterRest")
                .navigationBarItems(trailing:
                                        HStack {
                                            Text("Your ideal bedtime is: ")
                                            Text("\(alertMessage)").foregroundColor(.blue).font(.title2)
                                        }
                                    
                )
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
