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

# Add your Python code
cat > main.py << 'EOF'
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
EOF

# Build the cythonized wheel
psproject update app

# Update the package index
psproject update simple

# Create Xcode project
psproject create xcode

# Open in Xcode
open *.xcodeproj
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
# MyApp-0.1.0-cp310-cp310-macosx_13_0_arm64.whl
# MyApp-0.1.0-cp310-cp310-macosx_13_0_x86_64.whl
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
