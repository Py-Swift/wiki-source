


!!! info First create uv project which psproject will use the pyproject.toml as project info
    ```sh
    psproject init kivy_app
    ```

!!! info You should now have a kivy_app/pyproject.toml looking like this:
    ```toml
    [project]
    name = "kivy-app" # have no effect on the xcode app name
    version = "0.1.0"
    description = "Add your description here"
    readme = "README.md"
    authors = [
        { name = "Name", email = "name@email.com" }
    ]
    requires-python = ">=3.11.11"
    dependencies = []

    [build-system]
    requires = ["uv_build>=0.8.4,<0.9.0"]
    build-backend = "uv_build"


    [dependency-groups]
    iphoneos = []

    [pyswift.project]
    backends = []
    bundle_id = "org.pyswift.kivy_app"
    folder_name = "kivy_app"
    name = "kivy_app"
    pip_install_app = false
    platforms = [ "iphoneos" ]
    swift_sources = []

    [pyswift.project.dependencies]
    pips = []

    [pyswift.project.plist]

    [pyswift.swift-packages]
    ```


!!! info Now change the following properties to run a kivy based app:
    ```toml
    [project]
    dependencies = [
        "kivy",
        # add other pip requirements here
    ]

    [pyswift.project]
    backends = [
        "kivylauncher"
    ]
    bundle_id = "org.pyswift.my_kivy_app" # example
    folder_name = "MyKivyApp-apple" # example
    name = "MyKivyApp" # example
    ```

!!! info To create the xcode project, type the following command
    ```sh
    psproject create --uv kivy_app
    ```
