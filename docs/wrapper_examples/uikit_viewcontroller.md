# UIKit ViewController

This example demonstrates how to wrap UIKit ViewControllers and present them from Python. It shows how to create custom view controllers, configure their UI, and handle presentation/dismissal with callbacks.

## Getting Started

UIKit is Apple's primary framework for building user interfaces on iOS. This example covers:

- **UIViewController** - The base class for managing view hierarchies
- **UILabel, UIButton** - Basic UI components
- **Modal Presentation** - Showing view controllers
- **Delegates/Callbacks** - Handling user interactions and dismissal

## Part 1: Basic Swift Implementation

First, here's a basic Swift implementation without PySwiftKit:

```swift
import UIKit

class CustomViewController: UIViewController {
    var messageLabel: UILabel!
    var closeButton: UIButton!
    
    var message: String = "Hello from Swift!"
    var onDismiss: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        // Create and configure label
        messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.textAlignment = .center
        messageLabel.font = .systemFont(ofSize: 24, weight: .bold)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(messageLabel)
        
        // Create and configure button
        closeButton = UIButton(type: .system)
        closeButton.setTitle("Close", for: .normal)
        closeButton.titleLabel?.font = .systemFont(ofSize: 18)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            messageLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
            
            closeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            closeButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 30),
            closeButton.widthAnchor.constraint(equalToConstant: 100),
            closeButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc func closeButtonTapped() {
        dismiss(animated: true) {
            self.onDismiss?()
        }
    }
}

// Helper to present the view controller
class ViewControllerPresenter {
    static func present(_ viewController: UIViewController, animated: Bool = true) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(viewController, animated: animated)
        }
    }
}
```

This creates a simple view controller with a label and close button, and provides a way to present it.

## Part 2: Swift with PySwiftKit

Now let's wrap it with PySwiftKit decorators:

```swift
import UIKit
import PythonSwiftLink

@PyClass
class CustomViewController: UIViewController {
    private var messageLabel: UILabel!
    private var closeButton: UIButton!
    
    private var message: String = "Hello from Swift!"
    private var dismissCallback: PyPointer?
    
    @PyInit
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    @PyMethod
    func set_message(_ newMessage: String) {
        message = newMessage
        if isViewLoaded {
            messageLabel.text = newMessage
        }
    }
    
    @PyMethod
    func get_message() -> String {
        return message
    }
    
    @PyMethod
    func set_dismiss_callback(_ callback: PyPointer) {
        dismissCallback = callback
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        // Create and configure label
        messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.textAlignment = .center
        messageLabel.font = .systemFont(ofSize: 24, weight: .bold)
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(messageLabel)
        
        // Create and configure button
        closeButton = UIButton(type: .system)
        closeButton.setTitle("Close", for: .normal)
        closeButton.titleLabel?.font = .systemFont(ofSize: 18)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            closeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            closeButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 30),
            closeButton.widthAnchor.constraint(equalToConstant: 100),
            closeButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true) { [weak self] in
            guard let self = self, let callback = self.dismissCallback else { return }
            callback.call()
        }
    }
}

@PyClass
class ViewControllerPresenter {
    
    @PyInit
    init() {}
    
    @PyMethod
    func present_view_controller(_ viewController: UIViewController, animated: Bool = true) {
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                rootViewController.present(viewController, animated: animated)
            }
        }
    }
    
    @PyMethod
    func present_custom_view_controller(_ message: String, animated: Bool = true, callback: PyPointer?) -> CustomViewController {
        let vc = CustomViewController()
        vc.set_message(message)
        if let cb = callback {
            vc.set_dismiss_callback(cb)
        }
        
        DispatchQueue.main.async {
            self.present_view_controller(vc, animated: animated)
        }
        
        return vc
    }
    
    @PyMethod
    func dismiss_view_controller(animated: Bool = true, completion: PyPointer?) {
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                rootViewController.dismiss(animated: animated) {
                    completion?.call()
                }
            }
        }
    }
    
    @PyMethod
    static func get_root_view_controller() -> UIViewController? {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            return windowScene.windows.first?.rootViewController
        }
        return nil
    }
}

@PyModule
class UIKitModule {
    static func registerTypes() {
        CustomViewController.register()
        ViewControllerPresenter.register()
    }
}
```

!!! note "UIKit Thread Safety"
    All UI operations in UIKit must happen on the main thread. This is why we wrap presentation calls in `DispatchQueue.main.async`. PySwiftKit handles this automatically for most operations, but it's good practice to be explicit.

## Part 3: Python Interface

Define the Python interface for presenting view controllers:

```python
from typing import Optional, Callable

class CustomViewController:
    """A custom UIViewController with a message and close button."""
    
    def __init__(self) -> None:
        """Initialize a new CustomViewController."""
        ...
    
    def set_message(self, message: str) -> None:
        """
        Set the message displayed in the view controller.
        
        Args:
            message: The text to display
        """
        ...
    
    def get_message(self) -> str:
        """
        Get the current message.
        
        Returns:
            The current message text
        """
        ...
    
    def set_dismiss_callback(self, callback: Callable[[], None]) -> None:
        """
        Set a callback to be called when the view controller is dismissed.
        
        Args:
            callback: Function to call on dismissal
        """
        ...


class ViewControllerPresenter:
    """Helper class for presenting UIKit view controllers."""
    
    def __init__(self) -> None:
        """Initialize the presenter."""
        ...
    
    def present_view_controller(
        self, 
        view_controller: 'UIViewController', 
        animated: bool = True
    ) -> None:
        """
        Present any UIViewController.
        
        Args:
            view_controller: The view controller to present
            animated: Whether to animate the presentation
        """
        ...
    
    def present_custom_view_controller(
        self,
        message: str,
        animated: bool = True,
        callback: Optional[Callable[[], None]] = None
    ) -> CustomViewController:
        """
        Create and present a CustomViewController.
        
        Args:
            message: The message to display
            animated: Whether to animate the presentation
            callback: Optional callback for when dismissed
            
        Returns:
            The created view controller instance
        """
        ...
    
    def dismiss_view_controller(
        self,
        animated: bool = True,
        completion: Optional[Callable[[], None]] = None
    ) -> None:
        """
        Dismiss the currently presented view controller.
        
        Args:
            animated: Whether to animate the dismissal
            completion: Optional callback after dismissal
        """
        ...
    
    @staticmethod
    def get_root_view_controller() -> Optional['UIViewController']:
        """
        Get the root view controller of the application.
        
        Returns:
            The root view controller or None
        """
        ...
```

## Usage Example

```python
from uikit_wrapper import ViewControllerPresenter, CustomViewController
import time

# Create a presenter
presenter = ViewControllerPresenter()

# Example 1: Present a simple view controller
def on_dismiss():
    print("View controller was dismissed!")

vc = presenter.present_custom_view_controller(
    message="Hello from Python!",
    animated=True,
    callback=on_dismiss
)

# Wait a bit, then update the message
time.sleep(2)
vc.set_message("Message updated from Python!")

# Example 2: Create view controller first, configure, then present
vc2 = CustomViewController()
vc2.set_message("Pre-configured message")
vc2.set_dismiss_callback(lambda: print("VC2 dismissed"))

presenter.present_view_controller(vc2, animated=True)

# Example 3: Dismiss programmatically
time.sleep(3)
presenter.dismiss_view_controller(
    animated=True,
    completion=lambda: print("Dismissal complete")
)
```

## Advanced Usage: Alert Dialog Wrapper

```python
from uikit_wrapper import ViewControllerPresenter

class AlertDialog:
    """Wrapper for presenting UIAlertController-style dialogs."""
    
    def __init__(self):
        self.presenter = ViewControllerPresenter()
    
    def show_message(
        self,
        title: str,
        message: str,
        button_text: str = "OK",
        callback: callable = None
    ):
        """Show a simple message dialog."""
        def on_dismiss():
            print(f"Alert dismissed: {title}")
            if callback:
                callback()
        
        vc = self.presenter.present_custom_view_controller(
            message=f"{title}\n\n{message}",
            animated=True,
            callback=on_dismiss
        )
        return vc
    
    def show_confirmation(
        self,
        title: str,
        message: str,
        on_confirm: callable = None,
        on_cancel: callable = None
    ):
        """Show a confirmation dialog (simplified example)."""
        # In a real implementation, you'd create a custom VC with two buttons
        def on_dismiss():
            print(f"Confirmation dialog dismissed: {title}")
            if on_confirm:
                on_confirm()
        
        vc = self.presenter.present_custom_view_controller(
            message=f"{title}\n\n{message}\n\nTap Close to confirm",
            animated=True,
            callback=on_dismiss
        )
        return vc

# Usage
alert = AlertDialog()

# Simple message
alert.show_message(
    title="Success",
    message="Your operation completed successfully!",
    callback=lambda: print("User acknowledged success")
)

# Confirmation
time.sleep(3)
alert.show_confirmation(
    title="Delete Item",
    message="Are you sure you want to delete this item?",
    on_confirm=lambda: print("User confirmed deletion"),
    on_cancel=lambda: print("User cancelled")
)
```

## Advanced Usage: Custom Form View Controller

```swift
import UIKit
import PythonSwiftLink

@PyClass
class FormViewController: UIViewController {
    private var nameTextField: UITextField!
    private var emailTextField: UITextField!
    private var submitButton: UIButton!
    
    private var submitCallback: PyPointer?
    
    @PyInit
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    @PyMethod
    func set_submit_callback(_ callback: PyPointer) {
        submitCallback = callback
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        // Title label
        let titleLabel = UILabel()
        titleLabel.text = "User Information"
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // Name field
        nameTextField = UITextField()
        nameTextField.placeholder = "Name"
        nameTextField.borderStyle = .roundedRect
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameTextField)
        
        // Email field
        emailTextField = UITextField()
        emailTextField.placeholder = "Email"
        emailTextField.keyboardType = .emailAddress
        emailTextField.borderStyle = .roundedRect
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emailTextField)
        
        // Submit button
        submitButton = UIButton(type: .system)
        submitButton.setTitle("Submit", for: .normal)
        submitButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        submitButton.backgroundColor = .systemBlue
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.layer.cornerRadius = 8
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(submitButton)
        
        // Layout
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            nameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nameTextField.heightAnchor.constraint(equalToConstant: 44),
            
            emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 20),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 44),
            
            submitButton.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 40),
            submitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            submitButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func submitTapped() {
        guard let name = nameTextField.text, !name.isEmpty,
              let email = emailTextField.text, !email.isEmpty else {
            // Could show an alert here
            return
        }
        
        dismiss(animated: true) { [weak self] in
            guard let self = self, let callback = self.submitCallback else { return }
            callback.call(name, email)
        }
    }
}
```

```python
# Python interface for FormViewController
class FormViewController:
    def __init__(self) -> None: ...
    def set_submit_callback(self, callback: Callable[[str, str], None]) -> None: ...

# Usage
def handle_form_submission(name: str, email: str):
    print(f"Form submitted!")
    print(f"Name: {name}")
    print(f"Email: {email}")
    # Process the data...

presenter = ViewControllerPresenter()
form_vc = FormViewController()
form_vc.set_submit_callback(handle_form_submission)
presenter.present_view_controller(form_vc, animated=True)
```

!!! tip "Common UIKit Patterns"
    **Auto Layout**: Always set `translatesAutoresizingMaskIntoConstraints = false` when using constraints
    
    **Safe Area**: Use `view.safeAreaLayoutGuide` for top/bottom anchors to avoid notches
    
    **Button Actions**: Use `@objc` methods for target-action pattern
    
    **Keyboard**: Remember to handle keyboard show/hide in forms

!!! warning "Memory Management"
    Use `[weak self]` in closures to avoid retain cycles:
    
    ```swift
    dismiss(animated: true) { [weak self] in
        guard let self = self else { return }
        // Use self safely here
    }
    ```
    
    This is especially important with callbacks that capture view controllers.

!!! info "Presentation Styles"
    UIKit offers different presentation styles:
    
    ```swift
    // Full screen (default on iOS 13+)
    viewController.modalPresentationStyle = .fullScreen
    
    // Sheet (card style)
    viewController.modalPresentationStyle = .pageSheet
    
    // Form sheet (centered)
    viewController.modalPresentationStyle = .formSheet
    
    // Automatic (system chooses)
    viewController.modalPresentationStyle = .automatic
    ```
    
    You can expose these as methods in your wrapper.

## Use Cases

**User Onboarding**
```python
class OnboardingManager:
    def __init__(self):
        self.presenter = ViewControllerPresenter()
        self.current_page = 0
        self.pages = [
            "Welcome to the App!",
            "Here's how to get started...",
            "You're all set!"
        ]
    
    def show_onboarding(self):
        def on_page_complete():
            self.current_page += 1
            if self.current_page < len(self.pages):
                self.show_current_page()
            else:
                print("Onboarding complete!")
        
        self.show_current_page()
    
    def show_current_page(self):
        message = self.pages[self.current_page]
        self.presenter.present_custom_view_controller(
            message=message,
            callback=lambda: self.on_page_complete()
        )
```

**Settings/Preferences**
```python
class SettingsScreen:
    def __init__(self):
        self.presenter = ViewControllerPresenter()
    
    def show(self, on_save=None):
        def handle_save(settings_dict):
            print(f"Settings saved: {settings_dict}")
            if on_save:
                on_save(settings_dict)
        
        # Create custom settings VC with form fields
        settings_vc = CustomViewController()
        settings_vc.set_message("App Settings")
        settings_vc.set_dismiss_callback(handle_save)
        self.presenter.present_view_controller(settings_vc)
```

**Error/Success Messages**
```python
class MessagePresenter:
    def __init__(self):
        self.presenter = ViewControllerPresenter()
    
    def show_error(self, error: Exception):
        self.presenter.present_custom_view_controller(
            message=f"Error: {str(error)}",
            callback=lambda: print("Error acknowledged")
        )
    
    def show_success(self, message: str):
        self.presenter.present_custom_view_controller(
            message=f"✓ {message}",
            callback=lambda: print("Success acknowledged")
        )

# Usage
messenger = MessagePresenter()
try:
    # Some operation...
    messenger.show_success("Operation completed!")
except Exception as e:
    messenger.show_error(e)
```

!!! note "SwiftUI Alternative"
    While this example uses UIKit (the traditional iOS UI framework), modern iOS apps often use SwiftUI. PySwiftKit can wrap SwiftUI views as well, but the pattern is slightly different. UIKit is still widely used and important for:
    
    - Legacy app support
    - Complex custom UI requirements
    - Integration with existing UIKit codebases
    - Features not yet available in SwiftUI
