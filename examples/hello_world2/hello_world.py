from swift_types import *


@wrapper
class HelloWorld:
    
    class Callbacks:
        
        def get_string(self, string: str):
            """
            Get a string from swift
            """

    def send_string(self, string: str):
        """
        Sends a str to swift.
        """
