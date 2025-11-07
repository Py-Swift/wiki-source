


!!! info "First create uv project which psproject will use the pyproject.toml as project info"
    ```sh
    psproject init HelloWorld
    ```

!!! info "You should now have a HelloWorld/pyproject.toml looking like this:"
    ```toml
    --8<-- "docs/project/kivy/pyproject.toml"
    ```

!!! info "Now change the following properties to run a kivy based app:"
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

!!! info "cd into the new project"
    ```sh
    cd HelloWorld
    ```

!!! info "To create the xcode project, type the following command"
    ```sh
    psproject create xcode --ios
    ```
