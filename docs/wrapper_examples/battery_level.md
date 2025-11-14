
## Getting started

This tutorial demonstrates how to monitor iOS battery level and state changes from Python using PythonSwiftLink. You'll learn how to enable battery monitoring, read the current battery level, and receive notifications when the battery state changes. This is useful for apps that need to display battery indicators, detect power outages, or respond to low power conditions.

## BatteryMonitor Part 1

Call **Swift** from **Python** to read battery level:

Let's start with a basic Swift class that monitors the device's battery. iOS provides battery information through `UIDevice`, but we need to enable monitoring first.

```swift title="BatteryMonitor.swift"

import UIKit

public class BatteryMonitor {

    init() {
        UIDevice.current.isBatteryMonitoringEnabled = true
    }

    func get_battery_level() -> Float {
        return UIDevice.current.batteryLevel
    }

    func get_battery_state() -> String {
        switch UIDevice.current.batteryState {
        case .unknown:
            return "unknown"
        case .unplugged:
            return "unplugged"
        case .charging:
            return "charging"
        case .full:
            return "full"
        @unknown default:
            return "unknown"
        }
    }
}
```

To make this Swift class accessible from Python, we need to add PySwiftKit decorators. The `@PyClass` decorator marks the class as exportable to Python, `@PyInit` wraps the initializer, and `@PyMethod` exposes methods to Python. We also need to define a module structure using `@PyModule`.

Here's the same class with the necessary wrappers:

```swift title="BatteryMonitor.swift"
import UIKit
import PySwiftKit
import PySerializing
import PySwiftWrapper


@PyClass
class BatteryMonitor {

    @PyInit
    init() {
        UIDevice.current.isBatteryMonitoringEnabled = true
    }

    @PyMethod
    func get_battery_level() -> Float {
        return UIDevice.current.batteryLevel
    }

    @PyMethod
    func get_battery_state() -> String {
        switch UIDevice.current.batteryState {
        case .unknown:
            return "unknown"
        case .unplugged:
            return "unplugged"
        case .charging:
            return "charging"
        case .full:
            return "full"
        @unknown default:
            return "unknown"
        }
    }
}

@PyModule
struct battery_monitor: PyModuleProtocol {
    static var py_classes: [any (PyClassProtocol & AnyObject).Type] = [
        BatteryMonitor.self
    ]
}
```

The `@PyModule` struct defines a Python module named `battery_monitor` that contains our BatteryMonitor class. The `py_classes` array lists all classes that should be available in the module.

Once compiled, this creates a Python module that can be imported and used like any native Python class:

```py title="battery_monitor.py"

class BatteryMonitor:

    def __init__(self): ...

    def get_battery_level(self) -> float: ...

    def get_battery_state(self) -> str: ...

```

```py title="main.py"
from battery_monitor import BatteryMonitor

monitor = BatteryMonitor()

# Get battery level (0.0 to 1.0)
level = monitor.get_battery_level()
print(f"Battery level: {level * 100}%")

# Get battery state
state = monitor.get_battery_state()
print(f"Battery state: {state}")
```

## BatteryMonitor Part 2

Now let's implement battery level change notifications. iOS sends the `UIDeviceBatteryLevelDidChange` notification (up to once per minute) when the battery level changes. We'll register for this notification and call back to Python when changes occur.

Make callback from **Swift** to **Python** on battery changes:

```swift title="BatteryMonitor.swift"
import UIKit
import PySwiftKit
import PySerializing
import PySwiftWrapper


@PyClass
class BatteryMonitor {

    var _level_callback: PyPointer?
    var _state_callback: PyPointer?

    @PyInit
    init(level_callback: PyPointer? = nil, state_callback: PyPointer? = nil) {
        _level_callback = level_callback
        _state_callback = state_callback
        
        UIDevice.current.isBatteryMonitoringEnabled = true
        
        // Register for battery level changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(batteryLevelChanged),
            name: UIDevice.batteryLevelDidChangeNotification,
            object: nil
        )
        
        // Register for battery state changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(batteryStateChanged),
            name: UIDevice.batteryStateDidChangeNotification,
            object: nil
        )
    }

    @PyMethod
    func get_battery_level() -> Float {
        return UIDevice.current.batteryLevel
    }

    @PyMethod
    func get_battery_state() -> String {
        switch UIDevice.current.batteryState {
        case .unknown:
            return "unknown"
        case .unplugged:
            return "unplugged"
        case .charging:
            return "charging"
        case .full:
            return "full"
        @unknown default:
            return "unknown"
        }
    }

    @objc func batteryLevelChanged(notification: NSNotification) {
        level_changed_callback(level: UIDevice.current.batteryLevel)
    }

    @objc func batteryStateChanged(notification: NSNotification) {
        state_changed_callback(state: get_battery_state())
    }

    /* 
    @PyCall will automatically fill out the function body.
    By default, it targets a variable with an underscore prefix (_level_callback).
    You can specify a different variable name using the name: parameter.
    */
    @PyCall
    func level_changed_callback(level: Float)

    @PyCall
    func state_changed_callback(state: String)
}

@PyModule
struct battery_monitor: PyModuleProtocol {
    static var py_classes: [any (PyClassProtocol & AnyObject).Type] = [
        BatteryMonitor.self
    ]
}
```

```py title="main.py"
from battery_monitor import BatteryMonitor

def on_level_change(level: float):
    print(f"Battery level changed: {level * 100}%")

def on_state_change(state: str):
    print(f"Battery state changed: {state}")

# Create monitor with callbacks
monitor = BatteryMonitor(
    level_callback=on_level_change,
    state_callback=on_state_change
)

# Callbacks will be triggered automatically when battery changes
# (up to once per minute for level changes)

# You can also use lambda functions
monitor = BatteryMonitor(
    level_callback=lambda level: print(f"Level: {level * 100}%"),
    state_callback=lambda state: print(f"State: {state}")
)
```

## BatteryMonitor Part 3

Make callback from **Swift** to **Python** by converting a Py-Function/Method into a Swift Function Closure:

* Pros
    * No need for storing a variable to call, that happens inside the closure.
    * Cleaner API - callbacks are passed when needed rather than at initialization.
* Cons
   * By default the Swift closure can't keep a strong ref to the temporary object of the passed pyfunction, so it's important that one of the following conditions are met:
        1. The callback should happen within the life cycle of the function that was passed to it.
        2. If the callback is meant to be called later on, then it's important the pyfunction should be stored in Python as a strong ref that will keep the temporary object to the pyfunction alive while the callback is happening.

```swift title="BatteryMonitor.swift"
import UIKit
import PySwiftKit
import PySerializing
import PySwiftWrapper


@PyClass
class BatteryMonitor {

    @PyInit
    init() {
        UIDevice.current.isBatteryMonitoringEnabled = true
    }

    @PyMethod
    func get_battery_level() -> Float {
        return UIDevice.current.batteryLevel
    }

    @PyMethod
    func get_battery_state() -> String {
        switch UIDevice.current.batteryState {
        case .unknown:
            return "unknown"
        case .unplugged:
            return "unplugged"
        case .charging:
            return "charging"
        case .full:
            return "full"
        @unknown default:
            return "unknown"
        }
    }

    @PyMethod
    func monitor_changes(
        level_callback: @escaping (Float) -> Void,
        state_callback: @escaping (String) -> Void
    ) {
        // Register for battery level changes
        NotificationCenter.default.addObserver(
            forName: UIDevice.batteryLevelDidChangeNotification,
            object: nil,
            queue: .main
        ) { _ in
            // This matches condition 1 - callback happens within the notification handler
            level_callback(UIDevice.current.batteryLevel)
        }
        
        // Register for battery state changes
        NotificationCenter.default.addObserver(
            forName: UIDevice.batteryStateDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            // This matches condition 1 - callback happens within the notification handler
            state_callback(self.get_battery_state())
        }
    }
}

@PyModule
struct battery_monitor: PyModuleProtocol {
    static var py_classes: [any (PyClassProtocol & AnyObject).Type] = [
        BatteryMonitor.self
    ]
}
```

```py title="main.py"
from battery_monitor import BatteryMonitor

def on_level_change(level: float):
    print(f"Battery level changed: {level * 100}%")

def on_state_change(state: str):
    print(f"Battery state changed: {state}")

monitor = BatteryMonitor()

# Start monitoring with callbacks
monitor.monitor_changes(on_level_change, on_state_change)

# Or with lambda functions
monitor.monitor_changes(
    lambda level: print(f"Level: {level * 100}%"),
    lambda state: print(f"State: {state}")
)

# Get current status anytime
print(f"Current level: {monitor.get_battery_level() * 100}%")
print(f"Current state: {monitor.get_battery_state()}")
```

## Use Case: Power Outage Detector

A practical example of using this battery monitor to detect power outages:

```py title="power_outage_detector.py"
from battery_monitor import BatteryMonitor
import time

class PowerOutageDetector:
    def __init__(self):
        self.monitor = BatteryMonitor()
        self.was_charging = self.monitor.get_battery_state() == "charging"
        
    def start_monitoring(self):
        def on_state_change(state: str):
            if self.was_charging and state == "unplugged":
                print("⚠️ POWER OUTAGE DETECTED!")
                # Send notification, save data, etc.
            elif not self.was_charging and state == "charging":
                print("✓ Power restored")
            
            self.was_charging = (state == "charging")
        
        self.monitor.monitor_changes(
            level_callback=lambda level: None,  # We don't need level updates
            state_callback=on_state_change
        )

# Usage: Keep a spare phone plugged in running this script
detector = PowerOutageDetector()
detector.start_monitoring()

print("Monitoring for power outages...")
print(f"Current state: {detector.monitor.get_battery_state()}")
```
