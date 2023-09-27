=========================================
Install Swiftonize:
=========================================

.. code-block:: sh
    brew tap pythonswiftlink/tools
    brew install swiftonize_master


==============================
Setting up new working folder:
==============================

Create a new empty folder of your choosing, and cd into it with `Terminal`.
Now run the following command 

.. code-block:: sh
    python3.10 -m venv venv
    . venv/bin/activate

    pip install cython #==0.29.36
    pip install https://github.com/PythonSwiftLink/mod-pbxproj/archive/master.zip
    pip install https://github.com/kivy/kivy-ios/archive/master.zip
    pip install git+https://github.com/PythonSwiftLink/SwiftTools

    git clone https://github.com/PythonSwiftLink/Kivy-iOS-XcTemplate
    cp -rf Kivy-iOS-XcTemplate/templates ./venv/lib/python3.10/site-packages/kivy_ios/tools/
    rm -fr Kivy-iOS-XcTemplate

    mkdir swift-packages
    cd swift-packages
    curl https://gist.githubusercontent.com/PythonSwiftLink/eaf7105c371aca42eaf0fd1664b2eeb8/raw/6a3ef62cbcd7c602a6f023f4594cd60d4eea03b5/custom_pythonlib.py --output custom_pythonlib.py
    python custom_pythonlib.py
    git clone --branch testing https://github.com/PythonSwiftLink/PythonSwiftCore
    rm -f PythonSwiftCore/package.swift
    curl https://gist.githubusercontent.com/PythonSwiftLink/aef31fa04954f2a09644437376756274/raw/6b31763457071851e4ca240589fb2c3bc112b212/package.swift --output PythonSwiftCore/package.swift
    cd ..

    toolchain build kivy

Like the official kivy-ios statement says: 
    Don't grab a coffee, just do diner. 
    Compiling all the libraries for the first time, 
    2x over (remember, 2 archs, x86_64, arm64) will take time.



===================
Creating a Project:
===================

Create your project like you normally do with Kivy-iOS.