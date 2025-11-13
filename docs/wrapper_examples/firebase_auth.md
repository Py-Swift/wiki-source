# Firebase Authentication & Database

## Getting started

This tutorial demonstrates how to integrate Firebase Authentication and Realtime Database from Python using PythonSwiftLink. You'll learn how to implement user sign-in, sign-up, and save user data to Firebase. This is essential for building apps that require user authentication and data persistence in the cloud.

## Prerequisites

Before starting, ensure you have:

1. Firebase configured in your Xcode project
2. Firebase SDK installed via Swift Package Manager or CocoaPods
3. `GoogleService-Info.plist` added to your project

## FirebaseAuth Part 1

Basic Firebase authentication with email and password:

Let's start with a Swift class that handles Firebase authentication. This class will manage user sign-in, sign-up, and user profile creation in the Firebase Realtime Database.

```swift title="FirebaseAuthManager.swift"

import UIKit
import FirebaseAuth
import FirebaseDatabase

public class FirebaseAuthManager {
    
    var ref: DatabaseReference!
    
    init() {
        ref = Database.database().reference()
    }
    
    func sign_in(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            guard let user = authResult?.user, error == nil else {
                completion(false, error?.localizedDescription)
                return
            }
            completion(true, user.uid)
        }
    }
    
    func sign_up(email: String, password: String, username: String, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            guard let user = authResult?.user, error == nil else {
                completion(false, error?.localizedDescription)
                return
            }
            
            // Save username to database
            self.save_user_info(user: user, username: username) { success in
                completion(success, user.uid)
            }
        }
    }
    
    func save_user_info(user: User, username: String, completion: @escaping (Bool) -> Void) {
        // Set display name
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = username
        
        changeRequest.commitChanges { error in
            if let error = error {
                print("Error updating profile: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            // Save to database
            self.ref.child("users").child(user.uid).setValue(["username": username])
            completion(true)
        }
    }
    
    func sign_out() -> Bool {
        do {
            try Auth.auth().signOut()
            return true
        } catch let error {
            print("Error signing out: \(error.localizedDescription)")
            return false
        }
    }
    
    func get_current_user_id() -> String? {
        return Auth.auth().currentUser?.uid
    }
    
    func get_current_user_email() -> String? {
        return Auth.auth().currentUser?.email
    }
    
    func get_current_user_display_name() -> String? {
        return Auth.auth().currentUser?.displayName
    }
}
```

To make this accessible from Python, add PySwiftKit decorators:

```swift title="FirebaseAuthManager.swift"
import UIKit
import FirebaseAuth
import FirebaseDatabase
import PySwiftKit
import PySerializing
import PySwiftObject
import PySwiftWrapper


@PyClass
class FirebaseAuthManager {
    
    var ref: DatabaseReference!
    var _sign_in_callback: PyPointer?
    var _sign_up_callback: PyPointer?
    
    @PyInit
    init(sign_in_callback: PyPointer? = nil, sign_up_callback: PyPointer? = nil) {
        ref = Database.database().reference()
        _sign_in_callback = sign_in_callback
        _sign_up_callback = sign_up_callback
    }
    
    @PyMethod
    func sign_in(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            guard let user = authResult?.user, error == nil else {
                self.on_sign_in_complete(success: false, user_id: nil, error: error?.localizedDescription ?? "Unknown error")
                return
            }
            
            // Check if user exists in database
            self.ref.child("users").child(user.uid).observeSingleEvent(of: .value) { snapshot in
                if snapshot.exists() {
                    self.on_sign_in_complete(success: true, user_id: user.uid, error: nil)
                } else {
                    self.on_sign_in_complete(success: false, user_id: nil, error: "User profile not found")
                }
            }
        }
    }
    
    @PyMethod
    func sign_up(email: String, password: String, username: String) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            guard let user = authResult?.user, error == nil else {
                self.on_sign_up_complete(success: false, user_id: nil, error: error?.localizedDescription ?? "Unknown error")
                return
            }
            
            // Save user info
            self.save_user_info(user: user, username: username)
        }
    }
    
    func save_user_info(user: User, username: String) {
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = username
        
        changeRequest.commitChanges { error in
            if let error = error {
                self.on_sign_up_complete(success: false, user_id: nil, error: error.localizedDescription)
                return
            }
            
            // Save to database
            self.ref.child("users").child(user.uid).setValue(["username": username])
            self.on_sign_up_complete(success: true, user_id: user.uid, error: nil)
        }
    }
    
    @PyMethod
    func sign_out() -> Bool {
        do {
            try Auth.auth().signOut()
            return true
        } catch let error {
            print("Error signing out: \(error.localizedDescription)")
            return false
        }
    }
    
    @PyMethod
    func get_current_user_id() -> String {
        return Auth.auth().currentUser?.uid ?? ""
    }
    
    @PyMethod
    func get_current_user_email() -> String {
        return Auth.auth().currentUser?.email ?? ""
    }
    
    @PyMethod
    func get_current_user_display_name() -> String {
        return Auth.auth().currentUser?.displayName ?? ""
    }
    
    @PyMethod
    func is_signed_in() -> Bool {
        return Auth.auth().currentUser != nil
    }
    
    // Callback methods
    @PyCall
    func on_sign_in_complete(success: Bool, user_id: String?, error: String?)
    
    @PyCall
    func on_sign_up_complete(success: Bool, user_id: String?, error: String?)
}

@PyModule
struct firebase_auth: PyModuleProtocol {
    static var py_classes: [any (PyClassProtocol & AnyObject).Type] = [
        FirebaseAuthManager.self
    ]
}
```

The `@PyModule` struct creates a Python module named `firebase_auth` containing the FirebaseAuthManager class.

Once compiled, this creates a Python module:

```py title="firebase_auth.py"

class FirebaseAuthManager:

    def __init__(self, sign_in_callback: object = None, sign_up_callback: object = None): ...

    def sign_in(self, email: str, password: str): ...

    def sign_up(self, email: str, password: str, username: str): ...

    def sign_out(self) -> bool: ...

    def get_current_user_id(self) -> str: ...

    def get_current_user_email(self) -> str: ...

    def get_current_user_display_name(self) -> str: ...

    def is_signed_in(self) -> bool: ...

```

## Usage Examples

### Basic Sign In/Sign Up

```py title="main.py"
from firebase_auth import FirebaseAuthManager

# Callback handlers
def on_sign_in(success: bool, user_id: str, error: str):
    if success:
        print(f"✓ Sign in successful! User ID: {user_id}")
    else:
        print(f"✗ Sign in failed: {error}")

def on_sign_up(success: bool, user_id: str, error: str):
    if success:
        print(f"✓ Sign up successful! User ID: {user_id}")
    else:
        print(f"✗ Sign up failed: {error}")

# Create auth manager with callbacks
auth = FirebaseAuthManager(
    sign_in_callback=on_sign_in,
    sign_up_callback=on_sign_up
)

# Sign up new user
auth.sign_up(
    email="user@example.com",
    password="secure_password123",
    username="john_doe"
)

# Sign in existing user
auth.sign_in(
    email="user@example.com",
    password="secure_password123"
)

# Check current user
if auth.is_signed_in():
    print(f"Current user: {auth.get_current_user_display_name()}")
    print(f"Email: {auth.get_current_user_email()}")
    print(f"ID: {auth.get_current_user_id()}")

# Sign out
if auth.sign_out():
    print("Successfully signed out")
```

### Login Screen Example

```py title="login_screen.py"
from firebase_auth import FirebaseAuthManager

class LoginScreen:
    def __init__(self):
        self.auth = FirebaseAuthManager(
            sign_in_callback=self.handle_sign_in,
            sign_up_callback=self.handle_sign_up
        )
        self.current_user_id = None
    
    def handle_sign_in(self, success: bool, user_id: str, error: str):
        if success:
            self.current_user_id = user_id
            print(f"Welcome back, {self.auth.get_current_user_display_name()}!")
            self.navigate_to_home()
        else:
            self.show_error(f"Login failed: {error}")
    
    def handle_sign_up(self, success: bool, user_id: str, error: str):
        if success:
            self.current_user_id = user_id
            print(f"Account created for {self.auth.get_current_user_display_name()}")
            self.navigate_to_home()
        else:
            self.show_error(f"Sign up failed: {error}")
    
    def login(self, email: str, password: str):
        if not email or not password:
            self.show_error("Email and password cannot be empty")
            return
        self.auth.sign_in(email, password)
    
    def register(self, email: str, password: str, username: str):
        if not email or not password or not username:
            self.show_error("All fields are required")
            return
        self.auth.sign_up(email, password, username)
    
    def logout(self):
        if self.auth.sign_out():
            self.current_user_id = None
            print("Logged out successfully")
            self.navigate_to_login()
    
    def show_error(self, message: str):
        print(f"Error: {message}")
    
    def navigate_to_home(self):
        print("Navigating to home screen...")
    
    def navigate_to_login(self):
        print("Navigating to login screen...")

# Usage
login = LoginScreen()

# User tries to sign up
login.register(
    email="newuser@example.com",
    password="password123",
    username="new_user"
)

# User tries to login
login.login(
    email="newuser@example.com",
    password="password123"
)

# User logs out
login.logout()
```

### User Session Manager

```py title="session_manager.py"
from firebase_auth import FirebaseAuthManager

class SessionManager:
    _instance = None
    
    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
            cls._instance.auth = FirebaseAuthManager()
        return cls._instance
    
    def check_session(self) -> bool:
        """Check if user is currently logged in"""
        return self.auth.is_signed_in()
    
    def get_user_info(self) -> dict:
        """Get current user information"""
        if not self.check_session():
            return {}
        
        return {
            "user_id": self.auth.get_current_user_id(),
            "email": self.auth.get_current_user_email(),
            "display_name": self.auth.get_current_user_display_name()
        }
    
    def require_auth(self, func):
        """Decorator to require authentication"""
        def wrapper(*args, **kwargs):
            if not self.check_session():
                print("Authentication required")
                return None
            return func(*args, **kwargs)
        return wrapper

# Usage
session = SessionManager()

@session.require_auth
def get_protected_data():
    user_info = session.get_user_info()
    print(f"Fetching data for: {user_info['display_name']}")
    return {"data": "sensitive information"}

# Check session
if session.check_session():
    user = session.get_user_info()
    print(f"Logged in as: {user['display_name']} ({user['email']})")
else:
    print("No active session")

# Try to access protected function
result = get_protected_data()
```

## Important Notes

!!! warning "Firebase Configuration"
    Make sure to initialize Firebase in your app's `AppDelegate` or `@main` entry point:
    
    ```swift
    import FirebaseCore
    
    @main
    class AppDelegate: UIResponder, UIApplicationDelegate {
        func application(_ application: UIApplication,
                        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
            FirebaseApp.configure()
            return true
        }
    }
    ```

!!! note "Async Operations"
    Firebase authentication operations are asynchronous. Results are delivered through callbacks (`on_sign_in_complete`, `on_sign_up_complete`). Make sure to handle these callbacks appropriately in your Python code.

!!! tip "Error Handling"
    Always check the `success` parameter in callbacks before accessing `user_id`. The `error` parameter contains the error message when `success` is `false`.

!!! info "Database Structure"
    This example saves user data in the following structure:
    ```
    users/
      └── <user_id>/
            └── username: "user_display_name"
    ```
    
    You can extend this structure to include more user profile information.

!!! warning "Security Rules"
    Remember to configure Firebase Realtime Database security rules appropriately. For development, you might use:
    
    ```json
    {
      "rules": {
        "users": {
          "$uid": {
            ".read": "$uid === auth.uid",
            ".write": "$uid === auth.uid"
          }
        }
      }
    }
    ```
