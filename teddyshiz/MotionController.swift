import CoreMotion
import Foundation

class MotionController {
  static let shared = MotionController()
  private let motionManager = CMMotionManager()

  // Config
  private let shakeThreshold = 2.5
  private let rockThreshold = 0.5

  // Status
  private var lastShakeTime = Date.distantPast

  init() {}

  func startMonitoring(appState: TeddyAppState) {
    guard motionManager.isDeviceMotionAvailable else { return }

    motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
    motionManager.startDeviceMotionUpdates(to: .main) { [weak self] (data, error) in
      guard let self = self, let data = data else { return }

      // Check for shake (sudden acceleration)
      let accel = data.userAcceleration
      let magnitude = sqrt(accel.x * accel.x + accel.y * accel.y + accel.z * accel.z)

      if magnitude > self.shakeThreshold {
        let now = Date()
        if now.timeIntervalSince(self.lastShakeTime) > 3.0 {
          self.lastShakeTime = now
          appState.shake()
        }
      }

      // Check for rocking (slow smooth rotation around z or x axis)
      let rotation = data.rotationRate
      if abs(rotation.z) > self.rockThreshold || abs(rotation.x) > self.rockThreshold {
        // To keep it simple, if they rock while already in deep sleep it maintains it
        // We'll leave the deeper logic based on continuous rocking detection, but for now
        // we'll just check if it's gentle
      }
    }
  }

  func stopMonitoring() {
    if motionManager.isDeviceMotionAvailable {
      motionManager.stopDeviceMotionUpdates()
    }
  }
}
