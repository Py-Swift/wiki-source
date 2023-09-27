import kivy
from kivy.app import App
from kivy.uix.button import Button
from kivy.uix.boxlayout import BoxLayout
from kivy.uix.relativelayout import RelativeLayout
from kivy.properties import NumericProperty, BooleanProperty,ObjectProperty,StringProperty
from kivy.uix.label import Label
from kivy.uix.slider import Slider
from kivy.uix.dropdown import DropDown
from kivy.lang.builder import Builder


from av_media_player import AVPlayerApi

from os import getcwd, listdir
            
            
class MediaPlayerWindow(RelativeLayout, AVPlayerApi):
    #duration = NumericProperty(0)
    current_time = NumericProperty(0)
    
    current_process = NumericProperty(0)
    
    time_text = StringProperty("")
    
    time_slider = ObjectProperty(None)
    
    def __init__(self, **kw):
        self.duration = 0
        #self.play_list = PlayList(width=800)
        
        super(MediaPlayerWindow,self).__init__(callback_class=self,**kw)

    def player_info(self, mins: int, secs: int, progress_text: str , progress: float):
        self.time_text = progress_text
        self.current_process = progress

    def set_duration(self, duration: float):
        self.duration = duration

    def playing_status(self, state: int):
        if state == -1:
            ...
        elif state == 1:
            ...
        else:
            ...





Builder.load_string("""
  
<MediaPlayerWindow>:

    Button:
        id: show_playlist
        text: "new playlist"
        pos_hint: {'right': 1, 'top': 1}
        size_hint: 0.15,0.15
        on_release: root.new_playlist(app.playlist)
    Button:
        id: play
        text: "Play"
        pos_hint: {'center_x': 0.5, 'center_y': 0.5}
        size_hint: 0.15,0.15
        on_release: root.play_pause()
    Button:
        id: prev
        text: "Prev"
        pos_hint: {'center_x': 0.25, 'center_y': 0.5}
        size_hint: 0.15,0.15
        on_release: root.prev()
    Button:
        id: next
        text: "Next"
        pos_hint: {'center_x': 0.75, 'center_y': 0.5}
        size_hint: 0.15,0.15
        on_release: root.next()
    BoxLayout:
        orientation: "vertical"
        pos_hint: {'center_x': 0.5, 'y': 0.0}
        size_hint: 0.8,0.2
        Label:
            text: root.time_text
            font_size: 48
        Slider:
            id: time
            min: 0.0
            max: 1.0
            value: root.current_process
            
""")

class MediaSwift(App):
    def __init__(self, **kwargs):
        self.playlist = [
            "songs/Funk Test 3 - Mix.mp3",
            "songs/Sommer - test 1.m4a",
            "songs/Blå som himmelen - Chorus Test 3.mp3",
            "songs/Klig_Kys_-_Export_2.mp3"
        ]
        super(MediaSwift, self).__init__(**kwargs)

    def build(self):
        
        self.mp_window = MediaPlayerWindow()
        return self.mp_window
    
        
if __name__ == "__main__":

    MediaSwift().run()  