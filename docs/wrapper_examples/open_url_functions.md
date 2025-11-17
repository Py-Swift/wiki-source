# Opening URLs in Safari (Module Functions)

## Getting started

This tutorial demonstrates how to open URLs in Safari from Python using PythonSwiftLink with module-level functions instead of classes. Module functions are simpler when you don't need to maintain state or have multiple instances.

## URLOpener with Module Functions

Instead of using a class, we can expose Swift functions directly as Python module functions using `@PyFunction`:

```swift title="URLOpener.swift"
import UIKit
import PySwiftKit
import PySerializing
import PySwiftWrapper

@PyModule
struct UrlOpener: PyModuleProtocol {
    
    @PyFunction
    static func open_url(url_string: String) -> Bool {
        guard let url = URL(string: url_string) else {
            return false
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
            return true
        }
        return false
    }
    
    @PyFunction
    static func can_open_url(url_string: String) -> Bool {
        guard let url = URL(string: url_string) else {
            return false
        }
        return UIApplication.shared.canOpenURL(url)
    }
    
    @PyFunction
    static func open_settings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    @PyFunction
    static func get_scheme(url_string: String) -> String {
        guard let url = URL(string: url_string) else {
            return ""
        }
        return url.scheme ?? ""
    }
}
```

This creates a Python module with functions directly accessible:

```py title="url_opener.py"

def open_url(url_string: str) -> bool: ...

def can_open_url(url_string: str) -> bool: ...

def open_settings() -> None: ...

def get_scheme(url_string: str) -> str: ...

```

## Basic Usage

```py title="main.py"
from url_opener import open_url, can_open_url, get_scheme, open_settings

# Open a website in Safari
if open_url("https://www.apple.com"):
    print("✓ Opened Apple website")
else:
    print("✗ Failed to open URL")

# Check if a URL can be opened before trying
url = "https://github.com"
if can_open_url(url):
    print(f"Can open {url}")
    open_url(url)
else:
    print(f"Cannot open {url}")

# Get URL scheme
scheme = get_scheme("https://example.com")
print(f"Scheme: {scheme}")  # Output: https

# Open app settings
open_settings()
```

## URL Schemes Example

```py title="url_schemes.py"
from url_opener import open_url, can_open_url, get_scheme

# Test various URL schemes
urls = {
    "Website": "https://www.python.org",
    "Email": "mailto:someone@example.com",
    "Phone": "tel:1-234-567-8900",
    "SMS": "sms:1-234-567-8900",
    "Maps": "maps://?q=Apple+Park",
    "Settings": "app-settings:",
}

for name, url in urls.items():
    scheme = get_scheme(url)
    can_open = can_open_url(url)
    
    print(f"{name}:")
    print(f"  Scheme: {scheme}")
    print(f"  Can open: {can_open}")
    
    if can_open:
        open_url(url)
```

## URL Validator Helper

```py title="url_validator.py"
from url_opener import open_url, can_open_url

def validate_and_open(url: str) -> tuple[bool, str]:
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
    if not can_open_url(url):
        return (False, "URL scheme not supported")
    
    # Try to open
    if open_url(url):
        return (True, "URL opened successfully")
    else:
        return (False, "Failed to open URL")

# Usage
test_urls = [
    "https://www.apple.com",
    "http://example.com",
    "invalid-url",
    "ftp://files.example.com",
]

for url in test_urls:
    success, message = validate_and_open(url)
    print(f"{url}: {message}")
```

## With Completion Handler

Add a completion handler to the module function:

```swift title="URLOpener.swift"
import UIKit
import PySwiftKit
import PySerializing
import PySwiftWrapper

@PyModule
struct UrlOpener: PyModuleProtocol {
    
    @PyFunction
    static func open_url(url_string: String, completion: @escaping (String, Bool) -> Void) {
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
    
    @PyFunction
    static func can_open_url(url_string: String) -> Bool {
        guard let url = URL(string: url_string) else {
            return false
        }
        return UIApplication.shared.canOpenURL(url)
    }
    
    @PyFunction
    static func open_settings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    @PyFunction
    static func get_scheme(url_string: String) -> String {
        guard let url = URL(string: url_string) else {
            return ""
        }
        return url.scheme ?? ""
    }
}
```

Python usage with callbacks:

```py title="main_callback.py"
from url_opener import open_url

def on_completion(url: str, success: bool):
    if success:
        print(f"✓ Successfully opened: {url}")
    else:
        print(f"✗ Failed to open: {url}")

# Open URL with callback
open_url("https://www.apple.com", on_completion)

# Or with lambda
open_url(
    "https://github.com",
    lambda url, success: print(f"Opened {url}: {success}")
)
```

## URL History Tracker

```py title="url_tracker.py"
from url_opener import open_url, can_open_url, get_scheme
from datetime import datetime

class URLHistory:
    def __init__(self):
        self.history = []
    
    def open_with_tracking(self, url: str):
        """Open URL and track in history"""
        def on_complete(url: str, success: bool):
            entry = {
                "url": url,
                "success": success,
                "timestamp": datetime.now(),
                "scheme": get_scheme(url)
            }
            self.history.append(entry)
            
            if success:
                print(f"✓ Opened: {url}")
            else:
                print(f"✗ Failed: {url}")
            
            print(f"Total tracked: {len(self.history)}")
        
        # Check if URL can be opened
        if can_open_url(url):
            open_url(url, on_complete)
        else:
            print(f"Cannot open URL: {url}")
    
    def get_successful_urls(self):
        """Get list of successfully opened URLs"""
        return [entry["url"] for entry in self.history if entry["success"]]
    
    def get_failed_urls(self):
        """Get list of failed URLs"""
        return [entry["url"] for entry in self.history if not entry["success"]]
    
    def get_schemes_used(self):
        """Get unique schemes used"""
        return list(set(entry["scheme"] for entry in self.history))

# Usage
tracker = URLHistory()

# Track URL opens
tracker.open_with_tracking("https://www.python.org")
tracker.open_with_tracking("https://github.com")
tracker.open_with_tracking("invalid-url")

# Get statistics
print("\nSuccessful URLs:")
for url in tracker.get_successful_urls():
    print(f"  - {url}")

print("\nFailed URLs:")
for url in tracker.get_failed_urls():
    print(f"  - {url}")

print("\nSchemes used:")
for scheme in tracker.get_schemes_used():
    print(f"  - {scheme}")
```

## Social Media Links

```py title="social_media.py"
from url_opener import open_url, can_open_url

SOCIAL_PLATFORMS = {
    "twitter": "https://twitter.com/{}",
    "instagram": "https://instagram.com/{}",
    "github": "https://github.com/{}",
    "linkedin": "https://linkedin.com/in/{}",
    "youtube": "https://youtube.com/@{}",
}

def open_profile(platform: str, username: str):
    """Open a social media profile"""
    if platform not in SOCIAL_PLATFORMS:
        print(f"Unknown platform: {platform}")
        return False
    
    url = SOCIAL_PLATFORMS[platform].format(username)
    
    def on_complete(url: str, success: bool):
        if success:
            print(f"✓ Opened {platform} profile: {username}")
        else:
            print(f"✗ Failed to open {platform} profile")
    
    if can_open_url(url):
        open_url(url, on_complete)
        return True
    else:
        print(f"Cannot open {platform} URLs")
        return False

def open_share_link(text: str, url: str = ""):
    """Open Twitter share dialog"""
    share_url = f"https://twitter.com/intent/tweet?text={text}"
    if url:
        share_url += f"&url={url}"
    
    open_url(
        share_url,
        lambda u, s: print(f"Share dialog: {'opened' if s else 'failed'}")
    )

# Usage
open_profile("github", "python")
open_profile("twitter", "github")
open_profile("youtube", "python")

# Share content
open_share_link("Check out this cool project!", "https://github.com")
```

## Bulk URL Opener

```py title="bulk_opener.py"
from url_opener import open_url, can_open_url, get_scheme
import time

def open_urls_sequentially(urls: list[str], delay: float = 1.0):
    """Open multiple URLs with a delay between each"""
    results = []
    
    for i, url in enumerate(urls, 1):
        print(f"\n[{i}/{len(urls)}] Processing: {url}")
        
        # Check scheme
        scheme = get_scheme(url)
        print(f"  Scheme: {scheme}")
        
        # Check if can open
        if not can_open_url(url):
            print(f"  ✗ Cannot open this URL")
            results.append((url, False))
            continue
        
        # Open with callback
        def make_callback(url):
            def callback(u, success):
                results.append((u, success))
                status = "✓ Success" if success else "✗ Failed"
                print(f"  {status}")
            return callback
        
        open_url(url, make_callback(url))
        
        # Delay before next URL
        if i < len(urls):
            time.sleep(delay)
    
    return results

def summarize_results(results: list[tuple[str, bool]]):
    """Print summary of URL opening results"""
    total = len(results)
    successful = sum(1 for _, success in results if success)
    failed = total - successful
    
    print(f"\n{'='*50}")
    print(f"Summary:")
    print(f"  Total URLs: {total}")
    print(f"  Successful: {successful}")
    print(f"  Failed: {failed}")
    print(f"  Success rate: {(successful/total*100):.1f}%")

# Usage
urls = [
    "https://www.apple.com",
    "https://www.python.org",
    "https://github.com",
    "invalid-url",
    "ftp://example.com",
]

results = open_urls_sequentially(urls, delay=0.5)
summarize_results(results)
```

## Comparison: Module Functions vs Classes

### Module Functions (This Guide)
**Pros:**
- Simpler, more straightforward
- No need to instantiate objects
- Direct function calls
- Good for stateless operations

**Cons:**
- Cannot maintain instance state
- No inheritance or polymorphism
- Less suitable for complex scenarios

```py
from url_opener import open_url
opener.open_url("https://example.com")
```

### Classes ([Main Guide](open_url_classes.md))
**Pros:**
- Can maintain state (callbacks, history, etc.)
- Support inheritance and polymorphism
- Better for complex applications
- Can have multiple instances with different configurations

**Cons:**
- Requires instantiation
- Slightly more verbose

```py
from url_opener import URLOpener
opener = URLOpener()
opener.open_url("https://example.com")
```

## When to Use Module Functions

Choose module functions when:
- You need simple, stateless utilities
- You want a C-like functional API
- You don't need multiple instances
- You want the simplest possible interface

Choose classes when:
- You need to maintain state between calls
- You want callbacks stored in instances
- You need multiple configurations
- You want object-oriented design

## Important Notes

!!! warning "URL Schemes"
    Not all URL schemes are available by default. For iOS 9+, declare schemes in your app's `Info.plist` under `LSApplicationQueriesSchemes`:
    
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

!!! note "Static Functions"
    Module functions in PySwiftKit are static by nature. They don't have access to instance state, which makes them thread-safe and simple.

!!! tip "Mixing Approaches"
    You can mix both approaches in the same module:
    ```swift
    @PyModule
    struct url_opener: PyModuleProtocol {
        // Module functions
        @PyFunction
        static func open_url(url_string: String) -> Bool { ... }
        
        // Classes
        static var py_classes: [any (PyClassProtocol & AnyObject).Type] = [
            URLOpener.self
        ]
    }
    ```

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
