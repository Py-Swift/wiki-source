


!!! info "First create uv project which psproject will use the pyproject.toml as project info"
    ```sh
    psproject init HelloWorld
    ```

!!! info "cd into the new project - if terminal app only usage"
    ```sh
    cd HelloWorld
    ```

!!! info "vscode users can instead open the folder by"
    ```sh
    code HelloWorld
    ```

!!! info "You should now have a HelloWorld/pyproject.toml looking like this:"
    ```toml
    --8<-- "docs/project/kivy/pyproject.toml"
    ```


!!! info "Now change the following properties to run a kivy based app:"
    ```toml hl_lines="24-26"
    --8<-- "docs/project/kivy/pyproject.toml"
    ```


!!! info "To create the xcode project, type the following command"
    ```sh
    psproject create xcode
    ```
