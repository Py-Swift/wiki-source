=========================
Installing a KSL Release:
=========================

Download lastest release and unpack it

https://github.com/psychowasp/KivySwiftLink/releases/latest/download/KivySwiftLink.zip

open terminal with the current folder KivySwiftLink was downloaded to as root path
and type the following

.. code-block:: sh

    chmod +x KivySwiftLink
    ./KivySwiftLink install

and it will now copy KivySwiftLink to 

.. code-block:: sh

    /usr/local/bin/ksl

so from now on you just have to run KivySwiftLink like this

.. code-block:: sh

    ksl <commands>


==============================
Setting up new working folder:
==============================

Create a new empty folder of your choosing, and cd into it with `Terminal`.
Now run the following command 

.. code-block:: sh

    ksl setup

Like the official kivy-ios statement says: 
    Don't grab a coffee, just do diner. 
    Compiling all the libraries for the first time, 
    2x over (remember, 2 archs, x86_64, arm64) will take time.



===================
Creating a Project:
===================