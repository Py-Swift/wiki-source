# Cythonized Project

This guide shows how to create a **cythonized** project where Python files are automatically converted to Cython (`.pyx`) and compiled to native code for better performance.

## What is a Cythonized Project?

A cythonized project automatically:
- Converts all `.py` files to `.pyx` (Cython source files)
- Compiles them to native C extensions
- Generates local wheel packages for all target platforms
- Serves them via a local simple package index

This provides significant performance improvements while maintaining Python compatibility.

## Creating a Cythonized Project

!!! info "Initialize a new cythonized project"
    ```sh
    psproject init MyCythonApp --cythonized
    ```
    
    This creates a new project with the `cythonized` key set to `true` in `pyproject.toml`.

!!! info "Navigate to the project directory"
    ```sh
    cd MyCythonApp
    ```

!!! info "Or open in VS Code"
    ```sh
    code MyCythonApp
    ```

## Project Structure

!!! info "Your pyproject.toml will include the cythonized setting:"
    ```toml
    [tool.psproject]
    cythonized = true
    version = "0.1.0"
    # ... other settings
    ```

When `cythonized = true`, the build system will:

1. **Convert** all `.py` files to `.pyx` files
2. **Compile** them using Cython for each target platform
3. **Package** them as wheel files
4. **Index** them in a local simple package repository

## Build Workflow

### Step 1: Update the App Package

After making changes to your Python code:

!!! info "Build and package the app as a wheel"
    ```sh
    psproject update app
    ```
    
    This command:
    - Converts `.py` → `.pyx` files
    - Cythonizes the code for all platforms (iOS arm64, simulator x86_64/arm64, etc.)
    - Generates wheel files (.whl) for each platform
    - Places them in the local package repository

### Step 2: Update the Simple Index

!!! info "Generate/update the local package index"
    ```sh
    psproject update simple
    ```
    
    This command:
    - Scans all wheel files in the local repository
    - Generates a PEP 503 simple repository index
    - Makes packages available for pip installation

### Step 3: Create Xcode Project

!!! info "Generate the Xcode project"
    ```sh
    psproject create xcode
    ```
    
    The Xcode project will be configured to automatically install the latest wheel during build.

### Step 4: Build in Xcode

When you build in Xcode:

1. **Pre-build script** runs `pip install` from the local simple index
2. **Latest wheel** of your cythonized app is installed into site-packages
3. **Native compiled code** runs on the device/simulator

## Complete Example

```sh
# Create a new cythonized project
psproject init MyFastApp --cythonized

# Navigate to the project
cd MyFastApp
```
# Add your Python code
```py
def calculate_fibonacci(n: int) -> int:
    """Calculate fibonacci number - will be cythonized for speed."""
    if n <= 1:
        return n
    return calculate_fibonacci(n - 1) + calculate_fibonacci(n - 2)

def main():
    result = calculate_fibonacci(30)
    print(f"Fibonacci(30) = {result}")

if __name__ == "__main__":
    main()
```

# Build the cythonized wheel
```sh
psproject update app
```

# Update the package index
```sh
psproject update simple
```

# Create Xcode project
```sh
psproject create xcode
```

## Development Workflow

### Making Code Changes

When you modify your Python code:

```sh
# 1. Edit your .py files
vim my_module.py

# 2. Rebuild the cythonized package
psproject update app

# 3. Update the index
psproject update simple

# 4. Rebuild in Xcode (or clean build)
# The new wheel will be automatically installed
```

### Platform-Specific Builds

The cythonization process creates wheels for:

- **iOS Device** (arm64)
- **iOS Simulator** (arm64 for M1+ Macs)
- **iOS Simulator** (x86_64 for Intel Macs)

Each platform gets optimized native code.

## Configuration Options

!!! info "Example pyproject.toml for a cythonized Kivy app:"
    ```toml
    [project]
    name = "MyFastApp"
    version = "0.1.0"
    requires-python = ">=3.10"
    dependencies = [
        "kivy>=2.3.1",
    ]

    [build-system]
    requires = ["uv>=0.9.2,<0.10.0"]
    build-backend = "uv"

    [tool.psproject]
    version = "0.1.0"
    cythonized = true  # Enable Cython compilation

    [tool.psproject.app]
    main_script = "main.py"
    requirements = []

    [tool.psproject.ios]
    bundle_identifier = "com.example.myfastapp"
    deployment_target = "13.0"

    [tool.psproject.swift_packages.PythonSwiftLink]
    exact = "0.1.102"
    ```

## Performance Benefits

Cythonized code typically provides:

- **2-10x faster** execution for computational code
- **Reduced memory** overhead
- **Native C performance** for tight loops and calculations
- **Type safety** when using type hints

Example performance comparison:

```python
# Pure Python (main.py)
def calculate_sum(n: int) -> int:
    total = 0
    for i in range(n):
        total += i
    return total

# After cythonization → native C code
# Runs 5-10x faster on device!
```

## Automatic Build Integration

The Xcode project includes a build phase that:

```bash
# Pre-build script (automatically added)
pip install --index-url file:///path/to/simple MyFastApp
```

This ensures:
- ✅ Latest cythonized wheel is always installed
- ✅ No manual site-packages management needed
- ✅ Platform-specific optimized code is used

## Troubleshooting

### Wheel Not Found

If `pip install` can't find your wheel:

```sh
# Rebuild the wheel
psproject update app

# Regenerate the index
psproject update simple

# Verify the index exists
ls -la simple/
```

### Cython Compilation Errors

If you get Cython errors:

```sh
# Check Python syntax is valid
python -m py_compile main.py

# Try disabling cythonized temporarily
# Edit pyproject.toml: cythonized = false

# Then re-enable after fixing issues
```

### Platform Mismatch

Make sure you're building for the right platform:

```sh
# Check current platform wheels
ls *.whl

# Should see files like:
# MyApp-0.1.0-cp313-cp313-ios_13_0_iphoneos_arm64.whl
# MyApp-0.1.0-cp313-cp313-ios_13_0_iphonesimulator_arm64.whl
# MyApp-0.1.0-cp313-cp313-ios_13_0_iphonesimulator_x86_64.whl
```

## Advanced: Type Hints for Performance

Use Python type hints to get maximum Cython performance:

```python
# my_fast_module.py
def process_data(data: list[int]) -> int:
    """Cython will optimize this with type information."""
    total: int = 0
    value: int
    
    for value in data:
        total += value * 2
    
    return total
```

After cythonization, this becomes highly optimized C code!

## Pure Python Mode

Cython supports **Pure Python Mode**, which allows you to write Python code that remains valid Python but includes type annotations and hints that Cython uses for optimization. This is ideal for projects that need to run both as interpreted Python and as compiled extensions.

### Three Approaches to Pure Python Mode

#### 1. Using the `cython` Module (Decorators and Magic Attributes)

Import the `cython` module and use decorators to add type information:

```python
import cython

# Declare typed variables
@cython.locals(x=cython.int, y=cython.int)
def add_numbers(x, y):
    return x + y

# Create a cdef class (extension type)
@cython.cclass
class FastCalculator:
    # Declare attributes
    value: cython.int
    
    def __init__(self, initial_value: int):
        self.value = initial_value
    
    @cython.cfunc  # C function (internal use)
    @cython.returns(cython.int)
    def _internal_calc(self, n: cython.int) -> cython.int:
        return self.value * n
    
    @cython.ccall  # cpdef function (callable from Python and C)
    def calculate(self, n: cython.int) -> cython.int:
        return self._internal_calc(n) + self.value

# Check if code is compiled
if cython.compiled:
    print("Running as compiled extension!")
else:
    print("Running as interpreted Python")
```

When run as Python, this code uses the fake `cython` module (from `Cython.Shadow`). When compiled, it becomes optimized C code.

#### 2. Using PEP-484 Type Annotations

Use standard Python type hints with `cython` types:

```python
import cython

def process_array(data: list[int], multiplier: cython.int) -> int:
    """Process array with Cython optimizations."""
    total: cython.int = 0
    value: cython.int
    
    for value in data:
        total += value * multiplier
    
    return total

@cython.cclass
class Point:
    x: cython.double
    y: cython.double
    
    def __init__(self, x: float, y: float):
        self.x = x
        self.y = y
    
    def distance(self) -> cython.double:
        return cython.sqrt(self.x * self.x + self.y * self.y)
```

!!! tip "Type Annotation Benefits"
    - Works with static type checkers (mypy, pyright)
    - Compatible with IDE autocomplete
    - Provides Cython optimizations when compiled
    - Remains valid Python when interpreted

#### 3. Using Augmenting `.pxd` Files

Keep your `.py` file as pure Python and create a matching `.pxd` file with type declarations:

**my_module.py** (pure Python):
```python
def calculate_distance(x1, y1, x2, y2):
    dx = x2 - x1
    dy = y2 - y1
    return (dx * dx + dy * dy) ** 0.5

class Point:
    def __init__(self, x, y):
        self.x = x
        self.y = y
    
    def move(self, dx, dy):
        self.x += dx
        self.y += dy
```

**my_module.pxd** (Cython type declarations):
```python
cpdef double calculate_distance(double x1, double y1, double x2, double y2)

cdef class Point:
    cdef public double x, y
    cpdef move(self, double dx, double dy)
```

When Cython compiles `my_module.py`, it reads `my_module.pxd` and applies the type declarations automatically!

### Practical Example: Optimized Math Module

Here's a complete example combining all approaches:

```python
# fast_math.py
import cython
from cython.cimports.libc import math

@cython.cfunc
@cython.returns(cython.double)
def _fast_sqrt(x: cython.double) -> cython.double:
    """Internal C function for square root."""
    if cython.compiled:
        return math.sqrt(x)
    else:
        import math as py_math
        return py_math.sqrt(x)

@cython.ccall
def euclidean_distance(
    x1: cython.double,
    y1: cython.double,
    x2: cython.double,
    y2: cython.double
) -> cython.double:
    """Calculate Euclidean distance - optimized when compiled."""
    dx: cython.double = x2 - x1
    dy: cython.double = y2 - y1
    return _fast_sqrt(dx * dx + dy * dy)

@cython.cclass
class Vector2D:
    """2D vector with Cython optimizations."""
    x: cython.double
    y: cython.double
    
    def __init__(self, x: float, y: float):
        self.x = x
        self.y = y
    
    @cython.ccall
    def magnitude(self) -> cython.double:
        """Calculate vector magnitude."""
        return _fast_sqrt(self.x * self.x + self.y * self.y)
    
    @cython.ccall
    def normalize(self) -> None:
        """Normalize the vector in-place."""
        mag: cython.double = self.magnitude()
        if mag > 0:
            self.x /= mag
            self.y /= mag
    
    def __repr__(self) -> str:
        return f"Vector2D({self.x}, {self.y})"

# This works in both interpreted and compiled mode!
if __name__ == "__main__":
    v = Vector2D(3.0, 4.0)
    print(f"Vector: {v}")
    print(f"Magnitude: {v.magnitude()}")
    
    v.normalize()
    print(f"Normalized: {v}")
    
    dist = euclidean_distance(0, 0, 3, 4)
    print(f"Distance: {dist}")
```

### Available Cython Types

When using pure Python mode, you can use these types:

```python
import cython

# Integer types
x: cython.int          # C int
y: cython.long         # C long
z: cython.longlong     # C long long

# Unsigned integers
ux: cython.uint        # unsigned int
uy: cython.ulong       # unsigned long

# Floating point
f: cython.float        # C float
d: cython.double       # C double

# Boolean
b: cython.bint         # C boolean (0/1)

# Python types (for clarity)
py_int: int            # Python int object
py_list: list          # Python list object
py_dict: dict          # Python dict object

# Pointers (advanced)
ptr: cython.p_int      # int*
pptr: cython.pp_int    # int**
```

### Managing the GIL (Global Interpreter Lock)

For performance-critical sections, you can release the GIL:

```python
import cython

@cython.cfunc
@cython.nogil  # This function can run without the GIL
def cpu_intensive_calculation(n: cython.int) -> cython.long:
    """Pure C calculation, no Python objects."""
    result: cython.long = 0
    i: cython.int
    
    for i in range(n):
        result += i * i
    
    return result

def process_data(data: list[int]) -> int:
    """Process data, releasing GIL for C operations."""
    result: cython.long
    
    # Release GIL for the intensive calculation
    with cython.nogil:
        result = cpu_intensive_calculation(len(data))
    
    # GIL automatically reacquired here
    return int(result)
```

### Using in Cythonized Projects

When using `psproject init MyApp --cythonized`, you can write pure Python mode code that:

1. **Runs normally** when testing in Python
2. **Gets optimized** during the cythonization process
3. **Maintains compatibility** with debugging tools

Example workflow:

```python
# my_app/calculations.py
import cython

@cython.cfunc
@cython.returns(cython.double)
def _calculate_tax(amount: cython.double, rate: cython.double) -> cython.double:
    return amount * rate

@cython.ccall
def process_transaction(amount: float, tax_rate: float) -> dict:
    """Process a transaction with tax calculation."""
    tax: cython.double = _calculate_tax(amount, tax_rate)
    total: cython.double = amount + tax
    
    return {
        'amount': amount,
        'tax': tax,
        'total': total,
        'compiled': cython.compiled
    }

# When you run: psproject update app
# This gets converted to .pyx and compiled to native code!
```

!!! tip "Pure Python Mode Advantages"
    - ✅ Code runs without Cython installed (uses fallback)
    - ✅ Easier debugging with standard Python tools
    - ✅ Compatible with code coverage tools
    - ✅ Type hints help with IDE autocomplete
    - ✅ Gradual optimization (add types where needed)
    - ✅ Same codebase for development and production

!!! warning "Limitations"
    Some Cython features require `.pyx` syntax:
    
    - C arrays: `cdef int arr[100]`
    - C structs and unions
    - Complex pointer arithmetic
    - Inline C code
    
    For these, you need to write `.pyx` files directly.

!!! info "Runtime Dependency"
    Pure Python mode code imports `cython`. To avoid the runtime dependency, add this to your files:
    
    ```python
    try:
        import cython
    except ImportError:
        class _FakeCython:
            compiled = False
            def __getattr__(self, name):
                return lambda *args, **kwargs: (lambda f: f) if callable(args[0] if args else None) else object
        cython = _FakeCython()
    ```

## Best Practices

1. **Always update both** app and simple index:
   ```sh
   psproject update app && psproject update simple
   ```

2. **Clean builds** after major changes:
   ```sh
   # In Xcode: Product → Clean Build Folder
   ```

3. **Version your wheels** using semantic versioning:
   ```toml
   [project]
   version = "0.2.0"  # Increment on changes
   ```

4. **Test on device** as Cython optimizations differ from simulator

5. **Use type hints** for better performance optimization

!!! tip "Quick Reference"
    ```sh
    # Create cythonized project
    psproject init MyApp --cythonized
    
    # Development cycle
    psproject update app      # Build cythonized wheels
    psproject update simple   # Update package index
    
    # Initial setup
    psproject create xcode    # Create Xcode project
    
    # Then just build in Xcode!
    ```

!!! warning "Platform Dependencies"
    Some packages may not support all iOS platforms. If you encounter issues with a dependency:
    
    - Check if it has pre-built wheels for iOS
    - Consider using pure Python alternatives
    - Report compatibility issues to the package maintainer

!!! note "Comparison: Standard vs Cythonized"
    **Standard Project:**
    - `.py` files copied directly to site-packages
    - Interpreted at runtime
    - Easy to debug
    - Slower performance
    
    **Cythonized Project:**
    - `.py` → `.pyx` → compiled C extensions
    - Native machine code execution
    - Better performance (2-10x faster)
    - Requires rebuild on code changes
