from symtable import Class
from swift_types import *


class CameraConfigMode(Enum):
    QRcode = 0
    PhotoRaw = 1
    PhotoPng = 2
    Video = 3
    Vision = 4
    CoreML = 7


class KivyTextureKeys(ObjectStrEnum):
    cfmt = 'colorfmt'
    bfmt = 'bufferfmt'


class CameraApi:
    """
    A Wrapper For AVCapture Foundation
    """

    def start_capture(self, mode: int, callback_cls: object):
        """
        
        start_capture
        
        """

    def stop_capture(self, mode: int):
        ...

    def set_camera_mode(self, mode: int):
        ...

    def select_camera(self, index: int):
        ...

    def take_photo(self):
        ...

    def take_multi_photo(self, count: int):
        ...

    def select_preview_preset(self, preset: str):
        ...

    def set_focus_point(self, x: float, y: float):
        ...

    def zoom_camera(self, zoom: float):
        ...

    def set_exposure(self, value: float):
        ...

    def auto_exposure(self, state: bool):
        ...

    def set_preview_size(self, width: int, height: int):
        ...

    def update_view_pos(self, x: float, y: float):
        ...

    def update_view_size(self, width: float, height: float):
        ...

    def get_presets(self):
        ...

    def returned_image_data(self, data: object, width: int, height: int):
        ...

    @callback
    def preview_pixel_data(self, data: object, width: int, height: int, pixel_count: int):
        ...

    @callback
    def blit_buffer(self, data: object):
        ...

    @callback
    def set_camera_texture(self, width: int, height: int):
        ...


from kivy.uix.floatlayout import FloatLayout
from kivy.uix.relativelayout import RelativeLayout
from kivy.properties import AliasProperty, ObjectProperty, NumericProperty, ListProperty, ColorProperty
from kivy.lang import Builder
from kivy.graphics.texture import Texture
Builder.load_string("""
<CameraView>:
    app: app
    canvas:
        Rectangle:
            texture: self.tex
            pos: self.offset_pos
            size: self.norm_image_size
        Color:
            rgb: self.capture_outline_color[:3]
            a: self.capture_outline_alpha
        Line:
            width: 8
            rectangle: self.x, self.y - 8 , self.width - 8, self.height - 8         
""")


class CameraView(RelativeLayout, CameraApi):
    tex = ObjectProperty(None)
    touch_pos = ListProperty([0, 0])
    touched = NumericProperty(0)
    capture_outline_color = ColorProperty()
    capture_outline_alpha = NumericProperty(0.0)
    preview_buffersize: int

    def get_image_ratio(self):
        """_summary_

        Returns:
            _type_: _description_
        """
        print('get_image_ratio')
        tex = self.tex
        if tex:
            return tex.width / float(tex.height)
        return 1.0
    image_ratio = AliasProperty(get_image_ratio, bind=('tex',), cache=True)

    def get_norm_image_size(self):
        tex = self.tex
        if not tex:
            return list(self.size)
        ratio = self.image_ratio
        w, h = self.size
        iw = w
        ih = iw / ratio
        if ih > h:
            ih = h
            iw = ih * ratio
        return [iw, ih]
    norm_image_size = AliasProperty(get_norm_image_size, bind=('tex', 'size', 'image_ratio'), cache=True)

    def get_offset_pos(self):
        w, h = self.size
        tw, th = self.norm_image_size
        offset_x = (w - tw) / 2
        offset_y = (h - th) / 2
        return [self.x + offset_x, self.y + offset_y]
    offset_pos = AliasProperty(get_offset_pos, bind=('norm_image_size', 'pos'), cache=True)

    def __init__(self, **kw):
        app = ObjectProperty(None)
        self.bind(offset_pos=self.send_texture_pos)
        self.bind(norm_image_size=self.send_texture_size)
        super(CameraView, self).__init__(callback_class=self, **kw)
        self.update_cam = self.canvas.ask_update
        self.preview_buffersize = 0
        self.set_camera_texture(2160, 3840)

    def set_camera_texture(self, width: int, height: int) ->Texture:
        print('set_camera_texture', width, height)
        tex: Texture = Texture.create(size=(width, height), colorfmt='bgra', bufferfmt='ubyte')
        tex.flip_vertical()
        self.tex = tex
        return tex

    def new_texture(self, size, fmt):
        print('set_camera_texture', size)
        tex: Texture = Texture.create(size=size, colorfmt=fmt, bufferfmt='ubyte')
        tex.flip_vertical()
        self.tex = tex

    def blit_buffer(self, mem):
        print('blit_buffer', len(mem))

    def preview_pixel_data(self, data: object, width: int, height: int, pixel_count: int):
        if pixel_count != self.preview_buffersize:
            tex = self.set_camera_texture(width, height)
            self.preview_buffersize = pixel_count
            print(self, f'changed resolution to {width}x{height}')
        else:
            tex = self.tex
        if tex:
            tex.blit_buffer(data, colorfmt='bgra')
            self.update_cam()

    def blit_buffer(self, data: object):
        self.tex.blit_buffer(data, colorfmt='bgra')
        self.update_cam()

    def returned_image_data(self, data: object, width: int, height: int):
        ...

    def send_texture_pos(self, _, pos):
        x, y = pos
        self.update_view_pos(x, y)

    def send_texture_size(self, _, size):
        w, h = size
        self.update_view_size(w, h)
