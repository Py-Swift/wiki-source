


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
    ```toml hl_lines="10-12 26-28"
    --8<-- "docs/project/kivy/pyproject_post.toml"
    ```


!!! info "To create the xcode project, type the following command"
    ```sh
    psproject create xcode
    ```

!!! warning "Copy your main Python file to the Xcode project"
    After creating the Xcode project, you need to copy your `__main__.py` (or main entry point) to the app directory:
    ```sh
    cp __main__.py project_dist/xcode/app/
    ```
    
    This file will be bundled with your iOS app and serves as the entry point for your Python application.

!!! info "To update the xcode project's site-packages, type the following command"
    ```sh
    psproject update site-packages
    ```