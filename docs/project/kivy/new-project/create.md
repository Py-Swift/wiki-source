


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
    --8<-- "docs/project/kivy/new-project/pyproject.toml"
    ```


!!! info "Now change the following properties to run a kivy based app:"
    ```toml hl_lines="10-12 26-28"
    --8<-- "docs/project/kivy/new-project/pyproject_post.toml"
    ```


!!! info "To create the xcode project, type the following command"
    ```sh
    psproject create xcode
    ```

!!! warning "Copy your main Python file to the Xcode project"
    After creating the Xcode project, you need to copy your `__main__.py` (main entry point) to the app directory:
    ```sh
    cp src/helloworld/__main__.py project_dist/xcode/app/
    ```
    
    Replace `helloworld` with your actual app name. This file will be bundled with your iOS app and serves as the entry point for your Python application.

!!! info "To update the xcode project's site-packages, type the following command"
    ```sh
    psproject update site-packages
    ```

!!! tip "Customize mobile vs desktop settings"
    The `project_dist/xcode/app/__main__.py` can be different from `src/helloworld/__main__.py`! This allows you to run your app with different parameters or configurations for mobile vs desktop:
    
    **Desktop version** (`src/helloworld/__main__.py`):
    ```python
    from kivy.config import Config
    from helloworld import main  # Replace 'helloworld' with your app module name from src/
    
    # Set window size for desktop
    Config.set('graphics', 'width', '1280')
    Config.set('graphics', 'height', '720')
    
    if __name__ == "__main__":
        main()
    ```
    
    **Mobile version** (`project_dist/xcode/app/__main__.py`):
    ```python
    from helloworld import main  # Replace 'helloworld' with your app module name from src/
    
    if __name__ == "__main__":
        main()
    ```
    
    This separation lets you optimize settings, features, and UI layouts specifically for each platform without cluttering your code with conditional checks.