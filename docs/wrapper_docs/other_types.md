# Other Types and Advanced Conversions

This document covers additional type conversions and advanced usage patterns for PythonSwiftLink / Swiftonize.

## Numeric Types

!!! info "Integer Types"
    Python `int` automatically converts to various Swift integer types:
    
    | Python Type | Swift Type | Notes |
    |------------|------------|-------|
    | `int` | `Int` | Platform-native signed integer |
    | `int` | `Int32` | 32-bit signed integer |
    | `int` | `Int16` | 16-bit signed integer |
    | `int` | `Int8` | 8-bit signed integer |

!!! info "Unsigned Integer Types"
    Python `int` also converts to Swift unsigned integer types:
    
    | Python Type | Swift Type | Notes |
    |------------|------------|-------|
    | `int` | `UInt` | Platform-native unsigned integer |
    | `int` | `UInt32` | 32-bit unsigned integer |
    | `int` | `UInt16` | 16-bit unsigned integer |
    | `int` | `UInt8` | 8-bit unsigned integer |

!!! info "Floating Point Types"
    Python `float` converts to Swift floating-point types:
    
    | Python Type | Swift Type | Notes |
    |------------|------------|-------|
    | `float` | `Double` | 64-bit floating point (default) |
    | `float` | `Float` | 32-bit floating point |
    | `float` | `Float16` | 16-bit floating point |

## String and Data Types

!!! info "String Types"
    | Python Type | Swift Type | Description |
    |------------|------------|-------------|
    | `str` | `String` | Unicode text strings |
    | `object` | `PyPointer` | Raw Python object pointer |

!!! info "Binary Data Types"
    Python binary types convert to Swift data structures:
    
    **bytes conversions:**
    
    | Python Type | Swift Type | Description |
    |------------|------------|-------------|
    | `bytes` | `Data` | Swift Data type |
    | `bytes` | `[UInt8]` | Array of bytes |
    
    **bytearray conversions:**
    
    | Python Type | Swift Type | Description |
    |------------|------------|-------------|
    | `bytearray` | `Data` | Mutable byte sequence as Data |
    | `bytearray` | `[UInt8]` | Mutable byte sequence as array |
    
    **memoryview conversions:**
    
    | Python Type | Swift Type | Description |
    |------------|------------|-------------|
    | `memoryview` | `Data` | Memory view as Data |
    | `memoryview` | `[UInt8]` | Memory view as byte array |

## Collection Types

!!! info "Integer Lists"
    Python lists of integers convert to Swift arrays:
    
    **Signed integer arrays:**
    
    | Python Type | Swift Type |
    |------------|------------|
    | `list[int]` | `[Int]` |
    | `list[int]` | `[Int32]` |
    | `list[int]` | `[Int16]` |
    | `list[int]` | `[Int8]` |
    
    **Unsigned integer arrays:**
    
    | Python Type | Swift Type |
    |------------|------------|
    | `list[int]` | `[UInt]` |
    | `list[int]` | `[UInt32]` |
    | `list[int]` | `[UInt16]` |
    | `list[int]` | `[UInt8]` |

!!! info "Float Lists"
    Python lists of floats convert to Swift floating-point arrays:
    
    | Python Type | Swift Type |
    |------------|------------|
    | `list[float]` | `[Double]` |
    | `list[float]` | `[Float]` |
    | `list[float]` | `[Float16]` |

!!! info "Object and String Lists"
    | Python Type | Swift Type | Description |
    |------------|------------|-------------|
    | `list[object]` | `[PyPointer]` | Array of Python object pointers |
    | `list[str]` | `[String]` | Array of strings |

!!! info "Binary Data Lists"
    **Lists of bytes:**
    
    | Python Type | Swift Type |
    |------------|------------|
    | `list[bytes]` | `[Data]` |
    | `list[bytes]` | `[[UInt8]]` |
    
    **Lists of bytearray:**
    
    | Python Type | Swift Type |
    |------------|------------|
    | `list[bytearray]` | `[Data]` |
    | `list[bytearray]` | `[[UInt8]]` |
    
    **Lists of memoryview:**
    
    | Python Type | Swift Type |
    |------------|------------|
    | `list[memoryview]` | `[Data]` |
    | `list[memoryview]` | `[[UInt8]]` |

## Type Conversion Notes

!!! warning "Automatic Conversion"
    All these conversions happen automatically when calling Swift functions from Python or vice versa. The bridge will handle the conversion based on the Swift function signature.

!!! tip "Choosing the Right Type"
    - Use `Int`/`UInt` for general-purpose integers (platform-optimized)
    - Use specific sized types (`Int32`, `UInt16`, etc.) when interfacing with APIs that require them
    - Use `Double` for most floating-point operations (better precision)
    - Use `Float` or `Float16` when memory/performance is critical
    - Use `Data` for binary data when you need Foundation support
    - Use `[UInt8]` for raw byte manipulation

!!! example "Usage Example"
    ```python
    # Python side
    my_int = 42
    my_floats = [3.14, 2.71, 1.41]
    my_data = b"Hello, Swift!"
    
    # These will automatically convert when passed to Swift functions
    swift_object.process_int(my_int)  # Converts to Swift Int
    swift_object.process_floats(my_floats)  # Converts to [Double]
    swift_object.process_data(my_data)  # Converts to Data or [UInt8]
    ```
    
    ```swift
    // Swift side
    class SwiftObject {
        func processInt(_ value: Int) {
            print("Received: \(value)")
        }
        
        func processFloats(_ values: [Double]) {
            print("Float array: \(values)")
        }
        
        func processData(_ data: Data) {
            print("Data size: \(data.count)")
        }
        
        // Swift to Python: Use .pyPointer()
        func returnToPython() -> PyPointer {
            let swiftValue = 42
            return swiftValue.pyPointer()
        }
        
        // Python to Swift: Use Type.casted(object:)
        func receiveFromPython(_ obj: PyPointer) {
            if let intValue = Int.casted(object: obj) {
                print("Received int from Python: \(intValue)")
            }
            if let strValue = String.casted(object: obj) {
                print("Received string from Python: \(strValue)")
            }
        }
    }
    ```

!!! note "Performance Considerations"
    - Direct numeric conversions are very fast
    - Collection conversions require copying data
    - For large datasets, consider using `memoryview` or `Data` to minimize copying
    - `PyPointer` allows passing Python objects without conversion overhead
