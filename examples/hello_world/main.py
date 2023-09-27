from kivy.app import App
from kivy.lang.builder import Builder
from kivy.uix.button import Button
from kivy.uix.boxlayout import BoxLayout

from hello_world import HelloWorld

class Box(BoxLayout):
    pass


Builder.load_string("""
<Box>:
    Button:
        on_press: app.hello_world.send_string("Hello from python")
""")



class HelloWorldApp(App):
    
    def __init__(self, **kw):
        super(HelloWorldApp, self).__init__(**kw)
        self.hello_world = HelloWorld(self)
    
    
    def build(self):
        return Box()


if __name__ == '__main__':
    HelloWorldApp().run()