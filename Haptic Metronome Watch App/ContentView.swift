//
//  ContentView.swift
//  Haptic Metronome Watch App
//
//  Created by Wilgot Ulfstedt on 6/16/26.
//

import SwiftUI
import WatchKit

struct ContentView: View {
    @State private var bpm: Double = (UserDefaults.standard.double(forKey: "bpm") >= 40) ? UserDefaults.standard.double(forKey: "bpm") : 80
    
    @State private var isRunning = false
    @State private var timer: Timer?
    @State private var showSettingsView = false
    @State private var haptic: WKHapticType = .start
    
    var body: some View {
        
        NavigationStack {
            
            
            
            VStack {
                HStack {
                    
                    Text("\(Int(bpm)) BPM")
                        .font(.title2)
                        .bold()
                        .padding(7)
                    
                    Button("", systemImage: "gear") {
                        showSettingsView = true
                        stop()
                    }
                    .buttonBorderShape(.circle)
                    .frame(width: 40, height: 40)
                    .glassEffect(.regular.interactive(true))
                }

                Slider(value: Binding(get: {
                    self.bpm
                }, set: { (newVal) in
                    self.bpm = newVal
                    self.sliderChanged()
                }), in: 40...240, step: 5)
                .glassEffect(.regular.interactive(true), in: .rect(cornerRadius: 10))
                .padding(4)
                .buttonRepeatBehavior(.enabled)
                
                
                Button(isRunning ? "Stop" : "Start") {
                    isRunning ? stop() : start()
                }
                .buttonStyle(.glass)
                .tint(isRunning ? .red : .green)
                .padding(7)
            }
            .navigationDestination(isPresented: $showSettingsView) {
                SettingsView()
            }
        }
    }
    
    var metronome: some View {
        VStack {
            Text("metronome")
        }
    }
    
    func sliderChanged() {
        isRunning ? restart() : ()
        UserDefaults.standard.set(bpm, forKey: "bpm")
    }
    
    func update() {
        let stringHapticType = UserDefaults.standard.string(forKey: "haptic")
        
        switch stringHapticType {
        case "start":
            haptic = .start
        case "click":
            haptic = .click
        case "direction up":
            haptic = .directionUp
        default:
            haptic = .start
        }
    }
    
    func start() {
        update()
        isRunning = true
        let interval = 60.0 / bpm
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            WKInterfaceDevice.current().play(haptic)
        }
    }
    
    func stop() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    func restart() {
        stop()
        start()
    }
    
}

struct SettingsView: View {
    @State private var selectedHapticType: String = read(key: "haptic")
            
    let hapticTypes = ["start", "click", "direction up"]
    
    var body: some View {
        ScrollView {
            
            Text("Haptic Types")
                .font(.system(size: 17))
                .padding(4)
                        
            ForEach(hapticTypes, id: \.self) { hapticType in
                Button(hapticType, systemImage: (hapticType == selectedHapticType) ? "checkmark" : "") {
                    save(key: "haptic", value: hapticType)
                    selectedHapticType = hapticType
                }
                .glassEffect()
                .tint((hapticType == selectedHapticType) ? .green : .white)
                .padding(2)
            }
            .onAppear{
                selectedHapticType = read(key: "haptic")
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
    }
    
    func update() {
        selectedHapticType = read(key: "haptic")
    }
}

func read(key: String) -> String {
    let stored = UserDefaults.standard.string(forKey: key) ?? "start"
    return stored
}

func save(key: String, value: String) {
    UserDefaults.standard.set(value, forKey: key)
}

#Preview {
    ContentView()
}
