from gc import callbacks
from swift_types import *


#@wrapper
class AudioPlayerExample():
    "AudioPlayerExample"
    
    def new_song_url(self, filePath: str):
        ""
    
    def new_song_bytes(self, data: data):
        ""
    
    def new_playlist(self, files: list[str]):
        ""
    
    def add2playlist(self, filePath: str):
        ""
    
    def play_pause(self): ...
    
    def next(self): ...
    
    def prev(self): ...
    
    def jump_to_track(self, index: int): ...
    
    def stop(self): ...

    def rate_adjustment(self, adjuster: float32): ...

    def rate_reset(self): ...
    
    # class Callbacks:
        
    #     def player_info(self, mins: int, secs: int, progress_text: str , progress: float):
    #         ""
    #     def playing_status(self, state: int):
    #         ""
    #     def set_duration(self, duration: float):
    #         ""
