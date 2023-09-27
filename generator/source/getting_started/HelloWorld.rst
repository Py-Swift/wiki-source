==========================
Making your first wrapper:
==========================

Part 1
======

In this example a project with the name ``my_project`` was used 
and target python folder was created in the root of the working folder
with the name ``hello_src``

with the 3 following commands
(1: create new python_src folder, 2: creating new project and finally 3: selecting it as current target project)

.. code-block:: sh

   mkdir hello_src
   ksl project create my_project hello_src
   ksl project select my_project

in ``Finder`` goto 

.. code-block:: sh

   <working_folder>/my_project-ios/wrapper_sources

and create a new file called

.. code-block:: sh

   hello_world.py

and paste the following:

.. literalinclude:: ../../../examples/hello_world/hello_world.py
   :language: python

Swift:
^^^^^^

Open the Xcode project. (my_project-ios)

.. image:: ../../../examples/hello_world/images/xcode_select_sources.png

Click on File -> New -> File

.. image:: ../../../examples/hello_world/images/xcode_select_new_file.png

and write the name "HelloWorld.swift

.. image:: ../../../examples/hello_world/images/xcode_select_swift_file.png


HelloWorld.swift
"""""""""""""""""
.. literalinclude:: ../../../examples/hello_world/HelloWorld.swift
   :language: swift


You will now be met by the following warning

.. image:: ../../../examples/hello_world/images/xcode_protocol_missing.png

Click on the red box to get the following option

.. image:: ../../../examples/hello_world/images/xcode_protocol_fix.png

Xcode will now inject the missing protocol functions (the ones you defined in the hello_world.py wrapper file.)

.. image:: ../../../examples/hello_world/images/xcode_protocol_result.png

replace *code* with the following string:

.. code-block:: swift

   print(string)

and you should end up with the this result

.. literalinclude:: ../../../examples/hello_world/HelloWorld-2.swift
   :language: swift

Here comes the most important of all, because just creating a swift class with the same name won't do much magic.

You might also wonder what is this `HelloWorld_Delegate`, other than it mimics the same function layout as you wrote in the hello_world.py.

Protocols are used to create links between different classes, or in our case to connect the generated code in "hello_world.swift" ( look in SwiftWrappers group ).

So for each wrapper file, KivySwiftLink will create a protocol with the same name layout <WrapperClassName>_Delegate.
In this case, it will be HelloWorld_Delegate.

So how do we set the protocol/delegate target then?
Well, simple, KSL also generates a function for that need and will have the following name layout

.. code-block:: swift
   
   Init<WrapperClassName>_Delegate

and accepts the following arguement

.. code-block:: swift

   (delegate: <WrapperClassName>_Delegate)

so in HelloWorld's case:

.. code-block:: swift
	
   InitHelloWorld_Delegate(delegate: HelloWorld_Delegate)

Let's insert ``InitHelloWorld_Delegate`` in the ``init`` in HelloWorld swift class, 
but use ``self`` as the delegate parameter since ``self`` conforms to ``HelloWorld_delegate``

.. literalinclude:: ../../../examples/hello_world/HelloWorld-3.swift
   :language: swift
   :emphasize-lines: 7

Now for the final step on the swift-side.

PythonMain.swift
^^^^^^^^^^^^^^^^

goto `PythonMain.swift` 

`PythonMain` is the main class, where all your Swift classes needs to inited from.

see it as the main root, since this Class will be inited as the first thing when app launches.
Once this class is done initing all the classes that have been added to it, then the Kivy main app will start running.

Add the following line to PythonMain class 

.. code-block:: swift
	
   let hello_world = HelloWorld()

.. literalinclude:: ../../../examples/hello_world/PythonMain.swift
   :language: swift
   :emphasize-lines: 11



Hello World Api
^^^^^^^^^^^^^^^

.. autoclass:: hello_world.HelloWorld
    :members:


Kivy code(main.py)
^^^^^^^^^^^^^^^^^^

main.py
"""""""

.. literalinclude:: ../../../examples/hello_world/main.py
   :language: python
   :emphasize-lines: 11



Part 2
======
        
        
Api:
****
.. autoclass:: hello_world.HelloWorld
    :members:
    :noindex:

.. autoclass:: hello_world.HelloWorld.Callbacks
   :members: