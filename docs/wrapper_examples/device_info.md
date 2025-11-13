
## Getting started

This tutorial demonstrates how to access iOS device information from Python using PythonSwiftLink. You'll learn how to retrieve device details such as the device name, model, system version, and unique identifier. This is useful for apps that need to display device information, perform device-specific logic, or collect analytics data.

## DeviceInfo Part 1

Call **Swift** from **Python** to read device information:

Let's start with a basic Swift class that accesses device information. iOS provides device details through `UIDevice.current`, which gives us access to various properties about the running device.

```swift title="DeviceInfo.swift"

import UIKit

public class DeviceInfo {

    init() {

    }

    func get_device_name() -> String {
        return UIDevice.current.name
    }

    func get_device_model() -> String {
        return UIDevice.current.model
    }

    func get_system_name() -> String {
        return UIDevice.current.systemName
    }

    func get_system_version() -> String {
        return UIDevice.current.systemVersion
    }

    func get_device_identifier() -> String {
        return UIDevice.current.identifierForVendor?.uuidString ?? "N/A"
    }

    func get_device_type() -> String {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            return "iPhone"
        case .pad:
            return "iPad"
        case .tv:
            return "Apple TV"
        case .carPlay:
            return "CarPlay"
        case .mac:
            return "Mac"
        case .vision:
            return "Vision Pro"
        @unknown default:
            return "Unknown"
        }
    }

    func get_all_info() -> [String: String] {
        return [
            "name": get_device_name(),
            "model": get_device_model(),
            "system_name": get_system_name(),
            "system_version": get_system_version(),
            "identifier": get_device_identifier(),
            "device_type": get_device_type()
        ]
    }
}
```

To make this Swift class accessible from Python, we need to add PySwiftKit decorators. The `@PyClass` decorator marks the class as exportable to Python, `@PyInit` wraps the initializer, and `@PyMethod` exposes methods to Python.

Here's the same class with the necessary wrappers:

```swift title="DeviceInfo.swift"
import UIKit
import PySwiftKit
import PySerializing
import PySwiftObject
import PySwiftWrapper


@PyClass
class DeviceInfo {

    @PyInit
    init() {

    }

    @PyMethod
    func get_device_name() -> String {
        return UIDevice.current.name
    }

    @PyMethod
    func get_device_model() -> String {
        return UIDevice.current.model
    }

    @PyMethod
    func get_system_name() -> String {
        return UIDevice.current.systemName
    }

    @PyMethod
    func get_system_version() -> String {
        return UIDevice.current.systemVersion
    }

    @PyMethod
    func get_device_identifier() -> String {
        return UIDevice.current.identifierForVendor?.uuidString ?? "N/A"
    }

    @PyMethod
    func get_device_type() -> String {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            return "iPhone"
        case .pad:
            return "iPad"
        case .tv:
            return "Apple TV"
        case .carPlay:
            return "CarPlay"
        case .mac:
            return "Mac"
        case .vision:
            return "Vision Pro"
        @unknown default:
            return "Unknown"
        }
    }

    @PyMethod
    func get_all_info() -> [String: String] {
        return [
            "name": get_device_name(),
            "model": get_device_model(),
            "system_name": get_system_name(),
            "system_version": get_system_version(),
            "identifier": get_device_identifier(),
            "device_type": get_device_type()
        ]
    }
}

@PyModule
struct device_info: PyModuleProtocol {
    static var py_classes: [any (PyClassProtocol & AnyObject).Type] = [
        DeviceInfo.self
    ]
}
```

The `@PyModule` struct defines a Python module named `device_info` that contains our DeviceInfo class. The `py_classes` array lists all classes that should be available in the module.

Once compiled, this creates a Python module that can be imported and used like any native Python class:

```py title="device_info.py"

class DeviceInfo:

    def __init__(self): ...

    def get_device_name(self) -> str: ...

    def get_device_model(self) -> str: ...

    def get_system_name(self) -> str: ...

    def get_system_version(self) -> str: ...

    def get_device_identifier(self) -> str: ...

    def get_device_type(self) -> str: ...

    def get_all_info(self) -> dict[str, str]: ...

```

## Usage Examples

Here are various ways to use the DeviceInfo class in Python:

```py title="main.py"
from device_info import DeviceInfo

# Create device info instance
device = DeviceInfo()

# Get individual properties
device_name = device.get_device_name()
print(f"Device Name: {device_name}")

device_model = device.get_device_model()
print(f"Device Model: {device_model}")

system_name = device.get_system_name()
print(f"System Name: {system_name}")

system_version = device.get_system_version()
print(f"System Version: {system_version}")

identifier = device.get_device_identifier()
print(f"Device Identifier: {identifier}")

device_type = device.get_device_type()
print(f"Device Type: {device_type}")

# Get all information at once
all_info = device.get_all_info()
print("\nAll Device Information:")
for key, value in all_info.items():
    print(f"  {key}: {value}")
```

Example output:
```
Device Name: John's iPhone
Device Model: iPhone
System Name: iOS
System Version: 17.0
Device Identifier: 12345678-1234-1234-1234-123456789ABC
Device Type: iPhone

All Device Information:
  name: John's iPhone
  model: iPhone
  system_name: iOS
  system_version: 17.0
  identifier: 12345678-1234-1234-1234-123456789ABC
  device_type: iPhone
```

## Use Cases

### Device-Specific Logic

```py title="adaptive_ui.py"
from device_info import DeviceInfo

device = DeviceInfo()

# Adjust UI based on device type
device_type = device.get_device_type()

if device_type == "iPhone":
    # Use compact UI layout
    print("Using compact iPhone layout")
elif device_type == "iPad":
    # Use larger UI layout
    print("Using expanded iPad layout")
elif device_type == "Vision Pro":
    # Use spatial UI
    print("Using spatial Vision Pro layout")
```

### System Version Check

```py title="version_check.py"
from device_info import DeviceInfo

device = DeviceInfo()

# Check if device meets minimum requirements
system_version = device.get_system_version()
major_version = int(system_version.split('.')[0])

MIN_IOS_VERSION = 15

if major_version >= MIN_IOS_VERSION:
    print(f"✓ iOS {system_version} is supported")
else:
    print(f"✗ iOS {system_version} is not supported. Please upgrade to iOS {MIN_IOS_VERSION}+")
```

### Analytics and Logging

```py title="analytics.py"
from device_info import DeviceInfo
import json

device = DeviceInfo()

# Collect device info for analytics
def collect_analytics():
    info = device.get_all_info()
    
    analytics_data = {
        "device_info": info,
        "app_version": "1.0.0",
        "timestamp": "2025-11-13T12:00:00Z"
    }
    
    # Send to analytics service
    print("Analytics Data:")
    print(json.dumps(analytics_data, indent=2))

collect_analytics()
```

### Device Information Display

```py title="about_screen.py"
from device_info import DeviceInfo

class AboutScreen:
    def __init__(self):
        self.device = DeviceInfo()
    
    def display_info(self):
        info = self.device.get_all_info()
        
        print("=" * 40)
        print("DEVICE INFORMATION")
        print("=" * 40)
        print(f"Device:      {info['name']}")
        print(f"Model:       {info['model']}")
        print(f"Type:        {info['device_type']}")
        print(f"OS:          {info['system_name']} {info['system_version']}")
        print(f"Identifier:  {info['identifier']}")
        print("=" * 40)

# Usage
about = AboutScreen()
about.display_info()
```

## Important Notes

!!! note "Identifier for Vendor"
    The device identifier returned by `get_device_identifier()` is the `identifierForVendor`, which is unique to your app on this device. It will be the same across all apps from the same vendor, but different from other vendors' apps.

!!! warning "Privacy Considerations"
    - The device identifier can change if the user uninstalls all apps from your vendor and then reinstalls
    - Device identifiers should be handled according to privacy regulations
    - Never use device identifiers as the sole method for user authentication

!!! tip "Device Type Detection"
    The `get_device_type()` method returns a human-readable string that's perfect for display purposes or simple device-specific logic. For more complex device detection, you may want to extend this class with additional methods.
