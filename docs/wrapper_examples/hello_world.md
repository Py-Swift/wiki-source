
## Getting started

<!-- Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
 -->



## HelloWorld Part 1

Call **Swift** from **Python**:

<!-- Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. -->

```swift title="HelloWorld.swift"

public class HelloWorld {

    init() {

    }

    func send_string(text: String) {
        print(text)
    }

}
```
<!-- Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. -->


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

==

```py title="hello_world.py"

class HelloWorld:

    def __init__(self)...

    def send_string(self, text: str): ...

```

## HelloWorld Part 2

<!-- Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. -->


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