
## Getting started

This tutorial demonstrates how to create a Swift class that can be called from Python using PythonSwiftLink. You'll learn how to wrap Swift code to make it accessible from Python, including passing data between the two languages and implementing callbacks. We'll build a simple HelloWorld class that showcases the fundamental patterns you'll use when bridging Swift and Python code.

## HelloWorld Part 1

Call **Swift** from **Python**:

Let's start with a basic Swift class that we want to use from Python. This class has a simple method that prints a string to the console.

```swift title="HelloWorld.swift"

public class HelloWorld {

    init() {

    }

    func send_string(text: String) {
        print(text)
    }

}
```

To make this Swift class accessible from Python, we need to add PySwiftKit decorators. The `@PyClass` decorator marks the class as exportable to Python, `@PyInit` wraps the initializer, and `@PyMethod` exposes methods to Python. We also need to define a module structure using `@PyModule` that lists all the classes we want to export.

Here's the same class with the necessary wrappers:

```swift title="HelloWorld.swift"
import PySwiftKit
import PySerializing
import PySwiftObject
import PySwiftWrapper


@PyClass
class HelloWorld {

    @PyInit
    init() {
        
    }

    @PyMethod
    func send_string(text: String) {
        print(text)
    }

}

@PyModule
struct hello_world: PyModuleProtocol {
    static var py_classes: [any (PyClassProtocol & AnyObject).Type] = [
        HelloWorld.self
    ]
}
```

The `@PyModule` struct defines a Python module named `hello_world` that contains our HelloWorld class. The `py_classes` array lists all classes that should be available in the module.

Once compiled, this creates a Python module that can be imported and used like any native Python class:

```py title="hello_world.py"

class HelloWorld:

    def __init__(self)...

    def send_string(self, text: str): ...

```

## HelloWorld Part 2

Now let's explore how to implement callbacks from Swift back to Python. This is useful when you want Swift code to notify Python about events or results. We'll pass a Python function to Swift and call it from within a Swift method.

Make callback from **Swift** to **Python**:


```swift title="HelloWorld.swift"
@PyClass
class HelloWorld {

    var _callback: PyPointer

    @PyInit
    init(callback: PyPointer) {
        _callback = callback
    }

    @PyMethod
    func send_string(text: String) {
        callback(
            text + " World"
        )
    }

    /* 
    {} is not needed, PyCall will automatic fill out the function body
    by default PyCall will target a variable that should be a underscored name
    of the function, this case _callback.
    but you can use the name: "another_name" in the argument input on @PyCall
    to target another name.
    */
    @PyCall 
    func callback(text: String)
    
}
```

```py title="main.py"
from hello_world import HelloWorld

def callback(text: str):
    print(text)

hw = HelloWorld(callback)
hw.send_string("Hello")

hw = HelloWorld(lambda text: print(text))
hw.send_string("Hello")
```

## HelloWorld Part 3


Make callback from **Swift** to **Python** by converting a Py-Function/Method into a Swift Function Closure:

* Pros
    * No need for storing a variable to call, that happens inside the closure.
* Cons
   * By default the swift closure can't keep a strong ref to the temporary
    object of passed pyfunction. so its important that one of the following conditions are meet
        1. The callback should happen within the life cycle of the function that was passed to it.
        2. If the callback is ment to be called later on, then its importamt the pyfunction should be stored in python as a strongref that will keep the temporary object to the pyfunction alive, while callback is happening.

```swift title="HelloWorld.swift"
@PyClass
class HelloWorld2 {

    @PyInit
    init() {

    }

    @PyMethod
    func send_string(text: String, callback: @escaping (String)->Void) {
        // this matches condition 1
        callback(
            text + " World"
        )
    }

}
```


```py title="main.py"
from hello_world import HelloWorld

def callback(text: str):
    print(text)

hw = HelloWorld()

hw.send_string("Hello", callback)

hw.send_string("Hello", lambda text: print(text))
```










<!-- 

```py
class HelloWorld:

    def __init__(self, callback: object)...

    def send_string(self, text: str): ...

    class Callbacks:
        def get_string(self, text: str)

```

Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.



```swift title="HelloWorld.swift"

public class HelloWorld {

    var callback: PyCallback?

    func send_string(text: String) {
        callback?.get_string(
            text + " World"
        )
    }

}
``` -->