# Opening URLs in Safari

## Getting started

This tutorial demonstrates how to open URLs in Safari from Python using PythonSwiftLink. You'll learn how to launch Safari with a URL, check if a URL can be opened, and handle different URL schemes. This is useful for opening web pages, launching other apps via URL schemes, or providing external links from your Python application.

## URLOpener Part 1

Call **Swift** from **Python** to open URLs:

Let's start with a basic Swift class that opens URLs using `UIApplication`. iOS provides the `open(_:options:completionHandler:)` method to open URLs in Safari or other appropriate apps.

```swift title="URLOpener.swift"

import UIKit

public class URLOpener {

    init() {
        
    }

    func open_url(url_string: String) -> Bool {
        guard let url = URL(string: url_string) else {
            return false
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
            return true
        }
        return false
    }

    func can_open_url(url_string: String) -> Bool {
        guard let url = URL(string: url_string) else {
            return false
        }
        return UIApplication.shared.canOpenURL(url)
    }
}
```

To make this Swift class accessible from Python, we need to add PySwiftKit decorators:

```swift title="URLOpener.swift"
import UIKit
import PySwiftKit
import PySerializing
import PySwiftWrapper


@PyClass
class URLOpener {

    @PyInit
    init() {
        
    }

    @PyMethod
    func open_url(url_string: String) -> Bool {
        guard let url = URL(string: url_string) else {
            return false
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
            return true
        }
        return false
    }

    @PyMethod
    func can_open_url(url_string: String) -> Bool {
        guard let url = URL(string: url_string) else {
            return false
        }
        return UIApplication.shared.canOpenURL(url)
    }
}

@PyModule
struct url_opener: PyModuleProtocol {
    static var py_classes: [any (PyClassProtocol & AnyObject).Type] = [
        URLOpener.self
    ]
}
```

The `@PyModule` struct defines a Python module named `url_opener` that contains our URLOpener class.

Once compiled, this creates a Python module:

```py title="url_opener.py"

class URLOpener:

    def __init__(self): ...

    def open_url(self, url_string: str) -> bool: ...

    def can_open_url(self, url_string: str) -> bool: ...

```

## Usage Examples

### Basic URL Opening

```py title="main.py"
from url_opener import URLOpener

opener = URLOpener()

# Open a website in Safari
if opener.open_url("https://www.apple.com"):
    print("✓ Opened Apple website")
else:
    print("✗ Failed to open URL")

# Check if a URL can be opened before trying
url = "https://github.com"
if opener.can_open_url(url):
    print(f"Can open {url}")
    opener.open_url(url)
else:
    print(f"Cannot open {url}")
```

### Opening Different URL Schemes

```py title="url_schemes.py"
from url_opener import URLOpener

opener = URLOpener()

# Open various URL schemes
urls = {
    "Website": "https://www.python.org",
    "Email": "mailto:someone@example.com",
    "Phone": "tel:1-234-567-8900",
    "SMS": "sms:1-234-567-8900",
    "Maps": "maps://?q=Apple+Park",
    "Settings": "app-settings:",
}

for name, url in urls.items():
    if opener.can_open_url(url):
        print(f"✓ {name}: Can open {url}")
    else:
        print(f"✗ {name}: Cannot open {url}")
```

### URL Validator

```py title="url_validator.py"
from url_opener import URLOpener

class URLValidator:
    def __init__(self):
        self.opener = URLOpener()
    
    def validate_and_open(self, url: str) -> tuple[bool, str]:
        """
        Validate and open a URL.
        Returns (success, message)
        """
        # Basic validation
        if not url:
            return (False, "URL is empty")
        
        if not url.startswith(("http://", "https://")):
            return (False, "URL must start with http:// or https://")
        
        # Check if iOS can open it
        if not self.opener.can_open_url(url):
            return (False, "URL scheme not supported")
        
        # Try to open
        if self.opener.open_url(url):
            return (True, "URL opened successfully")
        else:
            return (False, "Failed to open URL")

# Usage
validator = URLValidator()

test_urls = [
    "https://www.apple.com",
    "http://example.com",
    "invalid-url",
    "ftp://files.example.com",  # FTP might not be supported
]

for url in test_urls:
    success, message = validator.validate_and_open(url)
    print(f"{url}: {message}")
```

## URLOpener Part 2

Make callback from **Swift** to **Python** with completion handler:

Now let's add a callback to notify Python when the URL has been opened (or failed to open). This is useful for showing loading indicators or handling errors.

```swift title="URLOpener.swift"
import UIKit
import PySwiftKit
import PySerializing
import PySwiftWrapper


@PyClass
class URLOpener {

    var _completion_callback: PyPointer?

    @PyInit
    init(completion_callback: PyPointer? = nil) {
        _completion_callback = completion_callback
    }

    @PyMethod
    func open_url(url_string: String) -> Bool {
        guard let url = URL(string: url_string) else {
            return false
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url) { success in
                self.on_url_opened(url: url_string, success: success)
            }
            return true
        }
        return false
    }

    @PyMethod
    func can_open_url(url_string: String) -> Bool {
        guard let url = URL(string: url_string) else {
            return false
        }
        return UIApplication.shared.canOpenURL(url)
    }

    @PyCall
    func on_url_opened(url: String, success: Bool)
}

@PyModule
struct url_opener: PyModuleProtocol {
    static var py_classes: [any (PyClassProtocol & AnyObject).Type] = [
        URLOpener.self
    ]
}
```

```py title="main.py"
from url_opener import URLOpener

def on_completion(url: str, success: bool):
    if success:
        print(f"✓ Successfully opened: {url}")
    else:
        print(f"✗ Failed to open: {url}")

opener = URLOpener(completion_callback=on_completion)

# Open URL with callback
opener.open_url("https://www.apple.com")

# Or with lambda
opener = URLOpener(
    completion_callback=lambda url, success: print(f"Opened {url}: {success}")
)
opener.open_url("https://github.com")
```

## URLOpener Part 3

Advanced version with URL validation and multiple schemes:

```swift title="URLOpener.swift"
import UIKit
import PySwiftKit
import PySerializing
import PySwiftWrapper


@PyClass
class URLOpener {

    @PyInit
    init() {
        
    }

    @PyMethod
    func open_url(url_string: String, completion: @escaping (String, Bool) -> Void) {
        guard let url = URL(string: url_string) else {
            completion(url_string, false)
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url) { success in
                completion(url_string, success)
            }
        } else {
            completion(url_string, false)
        }
    }

    @PyMethod
    func can_open_url(url_string: String) -> Bool {
        guard let url = URL(string: url_string) else {
            return false
        }
        return UIApplication.shared.canOpenURL(url)
    }

    @PyMethod
    func open_settings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }

    @PyMethod
    func get_scheme(url_string: String) -> String {
        guard let url = URL(string: url_string) else {
            return ""
        }
        return url.scheme ?? ""
    }
}

@PyModule
struct url_opener: PyModuleProtocol {
    static var py_classes: [any (PyClassProtocol & AnyObject).Type] = [
        URLOpener.self
    ]
}
```

```py title="advanced_example.py"
from url_opener import URLOpener

class LinkManager:
    def __init__(self):
        self.opener = URLOpener()
        self.opened_urls = []
    
    def open_with_tracking(self, url: str):
        """Open URL and track in history"""
        def on_complete(url: str, success: bool):
            if success:
                self.opened_urls.append(url)
                print(f"✓ Opened: {url}")
                print(f"Total opened: {len(self.opened_urls)}")
            else:
                print(f"✗ Failed: {url}")
        
        # Check scheme
        scheme = self.opener.get_scheme(url)
        print(f"Scheme: {scheme}")
        
        # Open with completion
        self.opener.open_url(url, on_complete)
    
    def open_app_settings(self):
        """Open this app's settings page"""
        print("Opening app settings...")
        self.opener.open_settings()
    
    def get_history(self):
        """Get list of successfully opened URLs"""
        return self.opened_urls.copy()

# Usage
manager = LinkManager()

# Open various URLs
manager.open_with_tracking("https://www.python.org")
manager.open_with_tracking("https://github.com")

# Open app settings
manager.open_app_settings()

# Get history
print("\nURL History:")
for url in manager.get_history():
    print(f"  - {url}")
```

## Practical Example: Social Media Links

```py title="social_media.py"
from url_opener import URLOpener

class SocialMediaOpener:
    def __init__(self):
        self.opener = URLOpener()
        
        # Common social media URL schemes
        self.platforms = {
            "twitter": "https://twitter.com/{}",
            "instagram": "https://instagram.com/{}",
            "github": "https://github.com/{}",
            "linkedin": "https://linkedin.com/in/{}",
            "youtube": "https://youtube.com/@{}",
        }
    
    def open_profile(self, platform: str, username: str):
        """Open a social media profile"""
        if platform not in self.platforms:
            print(f"Unknown platform: {platform}")
            return False
        
        url = self.platforms[platform].format(username)
        
        def on_complete(url: str, success: bool):
            if success:
                print(f"✓ Opened {platform} profile: {username}")
            else:
                print(f"✗ Failed to open {platform} profile")
        
        self.opener.open_url(url, on_complete)
        return True
    
    def open_share_link(self, text: str, url: str = ""):
        """Open native share dialog"""
        # Note: This would need additional UIActivityViewController wrapper
        # For now, just open Twitter share
        share_url = f"https://twitter.com/intent/tweet?text={text}"
        if url:
            share_url += f"&url={url}"
        
        self.opener.open_url(
            share_url,
            lambda u, s: print(f"Share dialog: {'opened' if s else 'failed'}")
        )

# Usage
social = SocialMediaOpener()

# Open profiles
social.open_profile("github", "python")
social.open_profile("twitter", "github")
social.open_profile("youtube", "python")

# Share content
social.open_share_link("Check out this cool project!", "https://github.com")
```

## Important Notes

!!! warning "URL Schemes"
    Not all URL schemes are available by default. For iOS 9+, you need to declare schemes in your app's `Info.plist` under `LSApplicationQueriesSchemes` if you want to check if other apps can handle specific schemes.
    
    ```xml
    <key>LSApplicationQueriesSchemes</key>
    <array>
        <string>twitter</string>
        <string>instagram</string>
        <string>mailto</string>
        <string>tel</string>
        <string>sms</string>
    </array>
    ```

!!! note "URL Validation"
    `can_open_url()` checks if the device has an app that can handle the URL scheme. It returns `false` for invalid URLs or schemes that aren't registered.

!!! tip "Safari vs In-App Browser"
    The `open()` method always opens URLs in Safari (external). If you want an in-app browser, you would need to wrap `SFSafariViewController` instead.

!!! info "Universal Links"
    Universal Links (https:// URLs that open in your app) are handled automatically by iOS if configured. The `open_url()` method will respect this behavior.

## Common URL Schemes

| Scheme | Description | Example |
|--------|-------------|---------|
| `https://` | Web URL (Safari) | `https://www.apple.com` |
| `http://` | Web URL (Safari) | `http://example.com` |
| `mailto:` | Email | `mailto:user@example.com` |
| `tel:` | Phone call | `tel:1-234-567-8900` |
| `sms:` | Text message | `sms:1-234-567-8900` |
| `facetime:` | FaceTime | `facetime:user@example.com` |
| `maps://` | Apple Maps | `maps://?q=Coffee` |
| `app-settings:` | App Settings | `app-settings:` |
