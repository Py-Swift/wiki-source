# PyProject.toml Configuration Guide

This document explains all the configuration keys used in the `pyproject.toml` file for PySwift projects.

## Standard Project Metadata

!!! info "`[project]` - Standard Python project metadata following PEP 621"

- **`name`**: The name of your project/package
  - Example: `"helloworld"`
  
- **`version`**: The current version of your project following semantic versioning
  - Example: `"0.1.0"`
  
- **`description`**: A brief description of what your project does
  - Example: `"Add your description here"`
  
- **`readme`**: Path to the README file
  - Example: `"README.md"`
  
- **`authors`**: List of project authors with name and email
  - Example: `[{ name = "Py-Swift", email = "psychowaspx@gmail.com" }]`
  
- **`requires-python`**: Minimum Python version required
  - Example: `">=3.13"`
  
- **`dependencies`**: List of Python package dependencies
  - Example: `["kivy>=2.3.1"]` or `[]` for no dependencies

!!! info "`[project.scripts]` - Defines command-line entry points for your application"

- **Key**: The command name that will be available in the terminal
- **Value**: The module and function to execute in format `"module:function"`
- Example: `helloworld = "helloworld:main"` creates a `helloworld` command that runs the `main()` function from the `helloworld` module

## Build System

!!! info "`[build-system]` - Specifies the build backend and its requirements"

- **`requires`**: List of packages needed to build the project
  - Example: `["uv_build>=0.9.2,<0.10.0"]`
  
- **`build-backend`**: The build backend module to use
  - Example: `"uv_build"`

## Dependency Groups

!!! info "`[dependency-groups]` - Optional dependency groups for different platforms or use cases"

- **`iphoneos`**: Dependencies specific to iPhone/iOS platform
  - Example: `[]`

## PySwift Project Configuration

!!! info "`[tool.psproject]` - Main PySwift project configuration section"

- **`app_name`**: The display name of your application
  - Example: `"HelloWorld"`
  
- **`backends`**: List of backend frameworks to use
  - Example: `["kivyschool.kivylauncher"]`
  - Common values: Kivy-based backends for cross-platform UI
  
- **`cythonized`**: Whether to compile Python code with Cython for performance
  - Type: Boolean
  - Example: `false`
  
- **`extra_index`**: Additional PyPI index URLs for package resolution
  - Example: `[]`
  
- **`pip_install_app`**: Whether to install the app using pip
  - Type: Boolean
  - Example: `false`

!!! info "`[tool.psproject.ios]` - iOS-specific PySwift configuration"

- **`backends`**: iOS-specific backend frameworks
  - Example: `[]`
  
- **`extra_index`**: Additional package indexes for iOS dependencies
  - Example:
    ```toml
    [
        "https://pypi.anaconda.org/beeware/simple",
        "https://pypi.anaconda.org/pyswift/simple",
        "https://pypi.anaconda.org/kivyschool/simple"
    ]
    ```
  - These indexes provide iOS-compatible wheels and packages

!!! info "`[tool.psproject.ios.info_plist]` - iOS-specific Info.plist configuration"

This section can contain key-value pairs that will be added to the iOS app's Info.plist file.

Common keys might include:

- Bundle identifiers
- App permissions (camera, microphone, etc.)
- Supported orientations
- App capabilities

!!! info "`[tool.psproject.ios.swift_packages]` - iOS-specific Swift Package Manager dependencies"

Define Swift packages that your iOS app depends on.

- Format: Typically package name and version/URL specifications

!!! info "`[tool.psproject.macos]` - macOS-specific PySwift configuration"

- **`backends`**: macOS-specific backend frameworks
  - Example: `[]`
  
- **`extra_index`**: Additional package indexes for macOS dependencies
  - Example: `[]`

!!! info "`[tool.psproject.macos.info_plist]` - macOS-specific Info.plist configuration"

Similar to iOS Info.plist but for macOS applications.

Common keys might include:

- Bundle identifiers
- App permissions
- Supported file types
- App capabilities

!!! info "`[tool.psproject.macos.swift_packages]` - macOS-specific Swift Package Manager dependencies"

Define Swift packages that your macOS app depends on.

!!! info "`[tool.psproject.swift_packages]` - Cross-platform Swift Package Manager dependencies"

Define Swift packages that are used across iOS, macOS, and other supported platforms

- Format: Package specifications with URLs and version constraints

## Example Usage

!!! info "Complete minimal configuration example (including all required sections)"
    ```toml
    [project]
    name = "helloworld"
    version = "0.1.0"
    description = "Add your description here"
    readme = "README.md"
    authors = [
        { name = "Py-Swift", email = "psychowaspx@gmail.com" }
    ]
    requires-python = ">=3.13"
    dependencies = [
        "kivy>=2.3.1",
    ]

    [project.scripts]
    helloworld = "helloworld:main"

    [build-system]
    requires = ["uv_build>=0.9.2,<0.10.0"]
    build-backend = "uv_build"

    [dependency-groups]
    iphoneos = []

    [tool.psproject]
    app_name = "HelloWorld"
    backends = [
        "kivyschool.kivylauncher"
    ]
    cythonized = false
    extra_index = []
    pip_install_app = false

    [tool.psproject.ios]
    backends = []
    extra_index = [
        "https://pypi.anaconda.org/beeware/simple",
        "https://pypi.anaconda.org/pyswift/simple",
        "https://pypi.anaconda.org/kivyschool/simple"
    ]

    [tool.psproject.ios.info_plist]

    [tool.psproject.ios.swift_packages]

    [tool.psproject.macos]
    backends = []
    extra_index = []

    [tool.psproject.macos.info_plist]

    [tool.psproject.macos.swift_packages]

    [tool.psproject.swift_packages]
    ```

## Tips

!!! tip "Version Constraints"
    Always specify version constraints for dependencies to ensure reproducible builds

!!! tip "Extra Indexes"
    Order matters - indexes are checked in the order listed

!!! tip "Platform Separation"
    Keep platform-specific configuration in the appropriate sections

!!! tip "Swift Packages"
    Use Swift packages for native functionality that Python alone cannot provide
