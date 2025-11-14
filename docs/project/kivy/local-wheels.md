# Local Wheels Guide

This guide explains how to create and use **local wheel packages** when PyPI packages have issues or when you need custom versions for your iOS app.

## Why Local Wheels?

Local wheels are useful when:

- 🔧 PyPI and GitHub versions are out of sync
- 🐛 A package has iOS-specific issues that need patching
- 📦 You need a specific version not available on PyPI
- ⚡ You want to host custom-built wheels for faster builds
- 🔒 You need to use private or modified packages

## Common Use Case: KivyMD Version Mismatch

A typical example is **KivyMD 1.2.0**, where the PyPI and GitHub versions aren't in sync, causing pip installation issues in app site-packages.

### The Problem

When you specify:
```toml
dependencies = [
    "kivymd==1.2.0"
]
```

You may encounter version conflicts or missing dependencies during iOS builds.

### The Solution

Create a local wheel from the source distribution and host it in a local simple index.

## Step-by-Step Guide

### Step 1: Create Wheel Sources Directory

From your app's root folder:

```sh
# Create directory for source distributions
mkdir wheel_sources
cd wheel_sources
```

### Step 2: Download the Source Distribution

Download the specific version you need (without dependencies):

```sh
# Download source distribution for the package
pip3 download kivymd==1.2.0 --no-deps -o .
```

This downloads `kivymd-1.2.0.tar.gz` to the current directory.

!!! tip "Why --no-deps?"
    The `--no-deps` flag ensures only the package itself is downloaded, not its dependencies. This gives you control over what gets built.

### Step 3: Build the Wheel

Build a wheel from the source distribution:

```sh
# Build wheel and output to ../wheels directory
uv build kivymd-1.2.0.tar.gz --wheel -o ../wheels
```

This creates:
- `../wheels/kivymd-1.2.0-py3-none-any.whl`

!!! info "Universal Wheels"
    Pure Python packages create universal wheels (`py3-none-any`) that work on all platforms, including iOS.

### Step 4: Update Simple Index

Generate the PEP 503 simple package index:

```sh
# Return to app root
cd ..

# Generate/update the simple index
psproject update simple
```

This scans the `wheels/` directory and creates `wheels/simple/` with the package index.

### Step 5: Configure Local Backend

Edit your `pyproject.toml` to add the local wheels as a backend:

```toml
[tool.psproject]
backends = [
    "./wheels/simple"
]
```

!!! success "Done!"
    Your app will now use the local wheel for `kivymd==1.2.0` instead of trying to fetch it from PyPI!

## Complete Example

Here's the full workflow in one script:

```sh
#!/bin/bash
# Setup local wheels for KivyMD

# Create structure
mkdir -p wheel_sources
cd wheel_sources

# Download source
pip3 download kivymd==1.2.0 --no-deps -o .

# Build wheel
uv build kivymd-1.2.0.tar.gz --wheel -o ../wheels

# Return to root
cd ..

# Update index
psproject update simple

echo "✅ Local wheel created for kivymd==1.2.0"
echo "📝 Add './wheels/simple' to [tool.psproject] backends in pyproject.toml"
```

## Project Structure

After setup, your project should look like:

```
MyApp/
├── pyproject.toml
├── main.py
├── wheel_sources/
│   └── kivymd-1.2.0.tar.gz
└── wheels/
    ├── kivymd-1.2.0-py3-none-any.whl
    └── simple/
        ├── index.html
        └── kivymd/
            └── index.html
```

## Configuration Reference

### Basic Configuration

```toml
[tool.psproject]
backends = [
    "./wheels/simple"
]
```

Pip will search these in order, falling back to PyPI if not found.

## Advanced: Custom Modified Wheels

You can also modify a package and build a custom wheel:

### Step 1: Extract Source

```sh
cd wheel_sources

# Extract the tarball
tar -xzf kivymd-1.2.0.tar.gz

# Make your modifications
cd kivymd-1.2.0
# Edit files as needed...
```

### Step 2: Modify Version (Optional)

To avoid conflicts, you can bump the version:

```python
# In setup.py or pyproject.toml
version = "1.2.0+custom"
```

### Step 3: Build Custom Wheel

```sh
# Build from the modified source directory
cd ..
uv build kivymd-1.2.0/ --wheel -o ../wheels
```

### Step 4: Update and Use

```sh
cd ..
psproject update simple
```

In your `pyproject.toml`:

```toml
dependencies = [
    "kivymd==1.2.0+custom"
]

[tool.psproject]
backends = [
    "./wheels/simple"
]
```

## Managing Multiple Packages

You can build wheels for multiple packages:

```sh
# Download multiple packages
cd wheel_sources
pip3 download package1==1.0.0 --no-deps -o .
pip3 download package2==2.0.0 --no-deps -o .
pip3 download package3==3.0.0 --no-deps -o .

# Build all wheels
for file in *.tar.gz; do
    uv build "$file" --wheel -o ../wheels
done

cd ..
psproject update simple
```

## Troubleshooting

### Wheel Not Found

If pip can't find your local wheel:

```sh
# Verify the wheel exists
ls wheels/*.whl

# Verify the simple index was generated
ls wheels/simple/

# Regenerate index
psproject update simple

# Check pyproject.toml has correct path
grep -A 2 "backends" pyproject.toml
```

### Version Conflicts

If you get version conflicts:

```sh
# Check what version you built
ls wheels/*.whl

# Make sure pyproject.toml matches
grep "kivymd" pyproject.toml
```

### Build Errors

If `uv build` fails:

```sh
# Try with pip instead
cd wheel_sources
pip3 wheel kivymd-1.2.0.tar.gz -w ../wheels --no-deps

cd ..
psproject update simple
```

## Use Cases

### 1. Beta/Pre-release Testing

```sh
# Download pre-release
pip3 download kivymd==2.0.0.dev0 --pre --no-deps -o wheel_sources/

# Build and use
uv build wheel_sources/kivymd-2.0.0.dev0.tar.gz --wheel -o wheels/
psproject update simple
```

### 2. Patched Dependencies

```sh
# Extract, patch, and rebuild
cd wheel_sources
tar -xzf problematic-package-1.0.0.tar.gz
cd problematic-package-1.0.0

# Apply your patch
patch -p1 < ../../fix.patch

# Build with custom version
sed -i '' 's/1.0.0/1.0.0+patched/' setup.py
cd ..
uv build problematic-package-1.0.0/ --wheel -o ../wheels

cd ..
psproject update simple
```

### 3. Private Internal Packages

```sh
# Build wheels from your internal packages
cd my-internal-lib/
uv build --wheel -o ../MyApp/wheels/

cd ../MyApp
psproject update simple
```

## Integration with Cythonized Projects

Local wheels work seamlessly with cythonized projects:

```toml
[tool.psproject]
cythonized = true
backends = [
    "./wheels/simple"  # Local wheels
]

[project]
dependencies = [
    "kivymd==1.2.0",      # From local wheels
    "requests>=2.31.0"     # From PyPI
]
```

When you run `psproject update app`, your app becomes a local wheel too, living alongside your other custom wheels!

## Quick Reference

```sh
# Setup local wheels
mkdir wheel_sources && cd wheel_sources
pip3 download PACKAGE==VERSION --no-deps -o .
uv build PACKAGE-VERSION.tar.gz --wheel -o ../wheels
cd .. && psproject update simple

# Add to pyproject.toml
[tool.psproject]
backends = ["./wheels/simple"]

# Rebuild index after changes
psproject update simple

# Clean and rebuild everything
rm -rf wheels/simple/
psproject update simple
```
