// MARK: - PedometerManager.swift (5번 기능: 신규 파일)

import CoreMotion
import Foundation

class PedometerManager: ObservableObject {
    private let pedometer = CMPedometer()
    private var startDate: Date?
    
    @Published var currentSteps: Int = 0
    @Published var isTracking: Bool = false
    
    func startTracking() {
        guard CMPedometer.isStepCountingAvailable() else {
            print("Pedometer not available")
            return
        }
        
        isTracking = true
        startDate = Date()
        currentSteps = 0
        
        pedometer.startUpdates(from: Date()) { [weak self] data, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async {
                self?.currentSteps = data.numberOfSteps.intValue
            }
        }
    }
    
    func stopTracking() -> Int {
        isTracking = false
        pedometer.stopUpdates()
        let steps = currentSteps
        currentSteps = 0
        startDate = nil
        return steps
    }
}
