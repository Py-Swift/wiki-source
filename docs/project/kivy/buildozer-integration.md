# Buildozer Integration

## Overview

PSProject supports Android builds through Buildozer integration. This guide explains how to initialize a project with Buildozer configuration and manage dependencies across both iOS (via psproject) and Android (via Buildozer) platforms using a unified `pyproject.toml` file.

The `toml2spec` tool (explained in detail below) enables you to manage all configuration in `pyproject.toml` and export it to Buildozer's `buildozer.spec` format when needed.

## Getting Started

### Initialize Project with Buildozer Support

PSProject can initialize a project with Buildozer configuration included:

!!! info "Create a new project with Buildozer support with following option added"
    ```sh
    --buildozer path/to/existing/buildozer.spec
    ```

This creates a project structure with:
- Standard `pyproject.toml` for project metadata and dependencies
- Buildozer configuration sections under `[tool.buildozer]`
- Development dependencies including Buildozer

!!! tip "Import existing Buildozer spec"
    If you have an existing `buildozer.spec` file, you can import its configuration:
    ```sh
    psproject init MyApp --buildozer path/to/existing/buildozer.spec
    ```

### Project Structure

After initialization, your project structure will look like:

```
MyApp/
├── pyproject.toml          # Unified project configuration
├── main.py                 # Your application entry point
├── project_dist/
│   ├── android/
│   │   └── .buildozer/
│   │       └── buildozer.spec  # Generated Buildozer spec
│   └── xcode/              # iOS project (after xcode creation)
```

## Installing toml2spec Tool

The `toml2spec` tool bridges `pyproject.toml` and `buildozer.spec`, allowing you to manage configuration in TOML format and export to Buildozer's spec format.

!!! info "Install toml2spec as a uv tool"
    ```sh
    uv tool install toml2spec
    ```

!!! note "What is a uv tool?"
    UV tools are globally available command-line applications installed in an isolated environment. They're accessible from anywhere on your system without activating a virtual environment.

!!! tip "Alternative: Install in project environment"
    If you prefer to install it within your project's virtual environment:
    ```sh
    uv add --dev toml2spec
    uv run toml2spec --help
    ```

### Verify Installation

```sh
# Check if toml2spec is available
toml2spec --version

# View help
toml2spec --help
```

## Configuration Structure

### pyproject.toml with Buildozer Sections

When using `--buildozer`, your `pyproject.toml` will include Buildozer configuration under `[tool.buildozer]`:

```toml title="pyproject.toml"
[project]
name = "MyApp"
version = "0.1.0"
description = "My cross-platform Kivy application"
dependencies = [
    "kivy>=2.3.1",
    "pillow>=10.0.0",
    "requests>=2.31.0",
]

[project.optional-dependencies]
dev = [
    "buildozer>=1.5.0",
    "toml2spec>=0.1.0",
]

[build-system]
requires = ["uv>=0.5.9,<0.6.0"]
build-backend = "uv"

[tool.psproject]
py_version = "3.13"
stub_version = "313"

[tool.psproject.ios]
url_template = "https://github.com/PythonSwiftLink/KivySwiftPackages/releases/download/3.13.1/"
platforms = ["ios_13_0_iphoneos", "ios_13_0_iphonesimulator"]

# Buildozer configuration starts here
[tool.buildozer.app]
title = "MyApp"
package_name = "myapp"
package_domain = "org.example"

# Source configuration
source_dir = "."
source_include_exts = ["py", "png", "jpg", "kv", "atlas"]
source_exclude_dirs = ["tests", "bin", "venv", ".venv", "project_dist"]

# Version info
version = "0.1.0"
version_regex = "__version__ = ['\"](.+?)['\"]"
version_filename = "%(source_dir)s/main.py"

# Requirements for p4a/buildozer-specific needs
# Python dependencies should be in [project.dependencies] instead
requirements = python3,android

# Application settings
orientation = "portrait"
fullscreen = 0
presplash_filename = "%(source_dir)s/data/presplash.png"
icon_filename = "%(source_dir)s/data/icon.png"

[tool.buildozer.android]
# Android API configuration
api = 33
minapi = 21
ndk = 25b

# Build configuration
accept_sdk_license = true
archs = ["arm64-v8a", "armeabi-v7a"]

# Permissions
permissions = [
    "INTERNET",
    "ACCESS_NETWORK_STATE",
]

[tool.buildozer.android.gradle]
# Gradle dependencies (if needed)
dependencies = []

[tool.buildozer]
# Build output
log_level = 2
warn_on_root = 1
```

### Key Differences from Traditional buildozer.spec

!!! warning "Dependency Management Changes"
    **Traditional buildozer.spec:**
    ```ini
    [app]
    requirements = python3,kivy,pillow,requests
    ```
    
    **With pyproject.toml:**
    ```toml
    [project]
    dependencies = [
        "kivy>=2.3.1",
        "pillow>=10.0.0",
        "requests>=2.31.0",
    ]
    
    [tool.buildozer.app]
    # Only platform-specific requirements
    requirements = python3,android
    ```

!!! info "Section Naming Convention"
    Buildozer spec sections are converted to TOML tables:
    
    | buildozer.spec | pyproject.toml |
    |----------------|----------------|
    | `[app]` | `[tool.buildozer.app]` |
    | `[buildozer]` | `[tool.buildozer]` |
    | `[app:android]` | `[tool.buildozer.android]` |
    | `[app:android.gradle]` | `[tool.buildozer.android.gradle]` |

## Dependency Management

### Python Package Dependencies

All Python packages that can be installed via pip should be listed in `[project.dependencies]`:

```toml
[project]
dependencies = [
    "kivy>=2.3.1",
    "kivymd>=1.1.1",
    "pillow>=10.0.0",
    "requests>=2.31.0",
    "firebase-admin>=6.0.0",
]
```

### Platform-Specific Requirements

Keep only platform-specific requirements in `[tool.buildozer.app]`:

```toml
[tool.buildozer.app]
# Platform-specific or non-pip requirements
requirements = python3,android,openssl,libffi
```

!!! note "Common Platform Requirements"
    - `python3` - Python interpreter
    - `android` - Android support package
    - `hostpython3` - Build-time Python
    - `openssl` - SSL/TLS support
    - `libffi` - Foreign function interface
    - `sdl2` - Simple DirectMedia Layer
    
    These are p4a (python-for-android) recipes, not pip packages.

### Development Dependencies

Tools like Buildozer and toml2spec should be development dependencies:

```toml
[project.optional-dependencies]
dev = [
    "buildozer>=1.5.0",
    "toml2spec>=0.1.0",
    "cython>=3.0.0",
]
```

## Exporting to buildozer.spec

After modifying your `pyproject.toml`, export the configuration to `buildozer.spec`:

!!! info "Export configuration"
    ```sh
    cd MyApp
    uv run toml2spec pyproject.toml project_dist/android/.buildozer/buildozer.spec
    ```

### What toml2spec Does

1. **Reads** `pyproject.toml` configuration
2. **Merges** `[project.dependencies]` with `[tool.buildozer.app]` requirements
3. **Converts** TOML format to INI format
4. **Generates** a complete `buildozer.spec` file

!!! example "Dependency Merging"
    **Input (pyproject.toml):**
    ```toml
    [project]
    dependencies = ["kivy>=2.3.1", "pillow>=10.0.0"]
    
    [tool.buildozer.app]
    requirements = python3,android
    ```
    
    **Output (buildozer.spec):**
    ```ini
    [app]
    requirements = python3,android,kivy,pillow
    ```

## Workflow

### Typical Development Workflow

1. **Initialize project with Buildozer support:**
   ```sh
   psproject init MyApp --buildozer
   cd MyApp
   ```

2. **Install development tools:**
   ```sh
   uv tool install toml2spec
   uv sync --all-extras
   ```

3. **Develop your application:**
   ```py title="main.py"
   from kivy.app import App
   
   class MyApp(App):
       def build(self):
           return Label(text='Hello World')
   
   if __name__ == '__main__':
       MyApp().run()
   ```

4. **Add dependencies to pyproject.toml:**
   ```toml
   [project]
   dependencies = [
       "kivy>=2.3.1",
       "requests>=2.31.0",  # New dependency
   ]
   ```

5. **Export to buildozer.spec:**
   ```sh
   uv run toml2spec pyproject.toml project_dist/android/.buildozer/buildozer.spec
   ```

6. **Build for Android:**
   ```sh
   cd project_dist/android
   buildozer android debug
   ```

7. **Build for iOS:**
   ```sh
   psproject create xcode
   psproject update site-packages
   # Open Xcode and build
   ```

### Continuous Integration

For CI/CD pipelines, automate the export step:

```yaml title=".github/workflows/build.yml"
- name: Export buildozer configuration
  run: |
    uv tool install toml2spec
    uv run toml2spec pyproject.toml project_dist/android/.buildozer/buildozer.spec

- name: Build Android APK
  run: |
    cd project_dist/android
    buildozer android debug
```

## Complete Example

### Full pyproject.toml with Buildozer

```toml title="pyproject.toml"
[project]
name = "MyKivyApp"
version = "1.0.0"
description = "A cross-platform Kivy application"
readme = "README.md"
requires-python = ">=3.10"
dependencies = [
    "kivy>=2.3.1",
    "kivymd>=1.1.1",
    "pillow>=10.0.0",
    "requests>=2.31.0",
    "python-dotenv>=1.0.0",
]

[project.optional-dependencies]
dev = [
    "buildozer>=1.5.0",
    "toml2spec>=0.1.0",
    "pytest>=7.0.0",
]

[build-system]
requires = ["uv>=0.5.9,<0.6.0"]
build-backend = "uv"

[tool.psproject]
py_version = "3.13"
stub_version = "313"

[tool.psproject.ios]
url_template = "https://github.com/PythonSwiftLink/KivySwiftPackages/releases/download/3.13.1/"
platforms = ["ios_13_0_iphoneos", "ios_13_0_iphonesimulator"]

# Buildozer Configuration
[tool.buildozer.app]
title = "My Kivy App"
package_name = "mykivyapp"
package_domain = "com.example"

source_dir = "."
source_include_exts = ["py", "png", "jpg", "kv", "atlas", "ttf"]
source_exclude_dirs = ["tests", "bin", ".buildozer", "venv", ".venv", "project_dist"]
source_exclude_patterns = ["*.pyc", "*.pyo", "__pycache__/*"]

version = "1.0.0"
version_regex = "__version__ = ['\"](.+?)['\"]"
version_filename = "%(source_dir)s/main.py"

# Platform-specific requirements only
requirements = python3,android,openssl,libffi

orientation = "portrait"
fullscreen = 0

# Assets
presplash_filename = "%(source_dir)s/assets/presplash.png"
icon_filename = "%(source_dir)s/assets/icon.png"
presplash_color = "#FFFFFF"

[tool.buildozer.android]
# API levels
api = 33
minapi = 21
ndk = 25b

# Build settings
accept_sdk_license = true
archs = ["arm64-v8a", "armeabi-v7a"]

# Permissions
permissions = [
    "INTERNET",
    "ACCESS_NETWORK_STATE",
    "WRITE_EXTERNAL_STORAGE",
    "READ_EXTERNAL_STORAGE",
]

# Features
features = ["android.hardware.camera"]

# Metadata
android_entrypoint = "org.kivy.android.PythonActivity"
android_apptheme = "@android:style/Theme.NoTitleBar"

[tool.buildozer.android.gradle]
dependencies = [
    "com.google.android.material:material:1.8.0",
]

[tool.buildozer]
log_level = 2
warn_on_root = 1
```

### Build Commands

```sh
# Export to buildozer.spec
uv run toml2spec pyproject.toml project_dist/android/.buildozer/buildozer.spec

# Build Android debug APK
cd project_dist/android
buildozer android debug

# Build Android release APK
buildozer android release

# Deploy to connected device
buildozer android deploy run
```

## Migration from Existing buildozer.spec

If you have an existing Buildozer project:

### Step 1: Initialize with existing spec

```sh
psproject init MyApp --buildozer path/to/old/buildozer.spec
```

### Step 2: Move pip requirements

Identify pip-installable packages in your old spec:

```ini title="old buildozer.spec"
[app]
requirements = python3,kivy,pillow,requests,kivymd,android
```

Move pip packages to `pyproject.toml`:

```toml title="pyproject.toml"
[project]
dependencies = [
    "kivy>=2.3.1",
    "pillow>=10.0.0",
    "requests>=2.31.0",
    "kivymd>=1.1.1",
]

[tool.buildozer.app]
# Keep only platform-specific
requirements = python3,android
```

### Step 3: Verify sections

Check that all sections from your old spec are present in `pyproject.toml`:

- `[app]` → `[tool.buildozer.app]`
- `[app:android]` → `[tool.buildozer.android]`
- `[buildozer]` → `[tool.buildozer]`

### Step 4: Export and test

```sh
uv run toml2spec pyproject.toml project_dist/android/.buildozer/buildozer.spec
cd project_dist/android
buildozer android debug
```

## Troubleshooting

### Common Issues

!!! warning "Requirements not found"
    **Problem:** Build fails with "Could not find X recipe"
    
    **Solution:** Check if X is a pip package. If yes, move it to `[project.dependencies]`. If it's a p4a recipe, keep it in `[tool.buildozer.app]` requirements.

!!! warning "Version conflicts"
    **Problem:** Buildozer complains about version specifiers
    
    **Solution:** `toml2spec` strips version specifiers when exporting to buildozer.spec. Buildozer will use the version installed by pip from `[project.dependencies]`.

!!! warning "Export path doesn't exist"
    **Problem:** `toml2spec` fails because directory doesn't exist
    
    **Solution:** Create the directory first:
    ```sh
    mkdir -p project_dist/android/.buildozer
    uv run toml2spec pyproject.toml project_dist/android/.buildozer/buildozer.spec
    ```

### Debugging

Enable verbose logging:

```toml
[tool.buildozer]
log_level = 2  # 0=error, 1=info, 2=debug
```

Check exported spec:

```sh
cat project_dist/android/.buildozer/buildozer.spec
```

## Best Practices

!!! tip "Single Source of Truth"
    Keep all dependency versions in `pyproject.toml`. Let `toml2spec` handle the export to `buildozer.spec`.

!!! tip "Version Control"
    Add to `.gitignore`:
    ```gitignore
    # Buildozer generated files
    .buildozer/
    bin/
    project_dist/android/.buildozer/buildozer.spec
    ```
    
    Don't commit the generated `buildozer.spec` - generate it during build from `pyproject.toml`.

!!! tip "Automated Export"
    Add a script to automate export:
    ```sh title="build.sh"
    #!/bin/bash
    set -e
    
    echo "Exporting buildozer configuration..."
    uv run toml2spec pyproject.toml project_dist/android/.buildozer/buildozer.spec
    
    echo "Building Android APK..."
    cd project_dist/android
    buildozer android debug
    ```

!!! tip "Test on Both Platforms"
    Regularly test your app on both iOS and Android to catch platform-specific issues early:
    ```sh
    # Test iOS
    psproject update site-packages
    # Open in Xcode and run
    
    # Test Android
    uv run toml2spec pyproject.toml project_dist/android/.buildozer/buildozer.spec
    cd project_dist/android
    buildozer android debug deploy run
    ```

## Reference

### toml2spec Command Options

```sh
# Basic usage
toml2spec <input_toml> <output_spec>

# With custom section mapping
toml2spec --mapping custom_mapping.json pyproject.toml buildozer.spec

# Dry run (don't write file)
toml2spec --dry-run pyproject.toml buildozer.spec
```

### Supported Buildozer Sections

All standard Buildozer sections are supported:

- `[tool.buildozer.app]` - Application settings
- `[tool.buildozer.android]` - Android-specific settings
- `[tool.buildozer.android.gradle]` - Gradle dependencies
- `[tool.buildozer.ios]` - iOS settings (use psproject instead)
- `[tool.buildozer]` - Build settings

!!! note "iOS Configuration"
    While you can include `[tool.buildozer.ios]`, psproject handles iOS builds independently. Use `[tool.psproject.ios]` for iOS configuration instead.

## Additional Resources

- [PSProject Documentation](https://github.com/PythonSwiftLink/psproject)
- [Buildozer Documentation](https://buildozer.readthedocs.io/)
- [toml2spec Repository](https://github.com/KivySwiftPackages/toml2spec)
- [python-for-android Documentation](https://python-for-android.readthedocs.io/)
- [Kivy Documentation](https://kivy.org/doc/stable/)
