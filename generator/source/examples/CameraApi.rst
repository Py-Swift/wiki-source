CameraApi
=========



Wrapper file:
*************
.. code-block:: python

    #camera_api.py

    from symtable import Class
    from swift_types import *


    class CameraConfigMode(Enum):

        QRcode = 0
        PhotoRaw = 1
        PhotoPng = 2
        Video = 3
        Vision = 4
        CoreML = 5
        

    class KivyTextureKeys(ObjectStrEnum):
        cfmt="colorfmt"
        bfmt="bufferfmt"

    @wrapper(
        dispatch_events=True,
        events=["test","test2"],
        singleton=True
    )

    class CameraApi:
        """
        A Wrapper For AVCapture Foundation
        """
        def start_capture(self, mode: int, callback_cls: object):
            """
            
            start_capture
            
            """
        def stop_capture(self, mode: int): ...

        def set_camera_mode(self, mode: int): ...

        def select_camera(self, index: long): ...

        def take_photo(self): ...

        def take_multi_photo(self, count: long): ...
        
        def select_preview_preset(self, preset:str): ...
        
        def set_focus_point(self, x: double, y: double): ...
        
        def zoom_camera(self, zoom: double): ...
        
        def set_exposure(self, value: double): ...
        
        def auto_exposure(self, state: bool): ...

        def set_preview_size(self, width: int, height: int): ...
        
        def update_view_pos(self, x: float, y: float): ...
        
        def update_view_size(self, width: float, height: float): ...
        
        #@send_self
        def get_presets(self): ...
        
        #@callback(direct=True)
        def returned_image_data(self, data: object, width: long, height: long): ...

        # @callback
        # @direct
        # def returned_thumbnail_data(self, data: object, width: long, height: long): ...
        
        @callback
        #@direct
        def preview_pixel_data(self, data: object ,width: long, height: long, pixel_count: long): ...
        
        @callback
        #@direct
        def blit_buffer(self, data: object): ...
        
        @callback
        def set_camera_texture(self, width: long, height: long): ...
        
        # @callback
        # def test_values(self, arg0: int, arg1: uint, arg2: uint8, arg3: str, arg4: list[uint8]): ...
        
        # @callback
        # def test_multi_data_args(self, data0: data, mem: memoryview[uint8], string: str): ...
        # @callback
        # def change_cam_res(self, width: long, height: long): ...

        # @callback
        # def get_camera_types(self, front: object, back: object): ...
        
        
        # @callback()
        # def set_preview_presets(self, presets: object): ...
        

        
        
    #python imports
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

    @python
    class CameraView(RelativeLayout, CameraApi):
        tex = ObjectProperty(None)    
        touch_pos = ListProperty([0,0])
        touched =  NumericProperty(0)

        capture_outline_color = ColorProperty()
        capture_outline_alpha = NumericProperty(0.0)
        
        preview_buffersize: int
        
        def get_image_ratio(self):
            """_summary_

            Returns:
                _type_: _description_
            """
            
            print("get_image_ratio")
            tex = self.tex
            if tex:
                return tex.width / float(tex.height)
            return 1.

        image_ratio = AliasProperty(get_image_ratio, bind=('tex',), cache=True)
        
        def get_norm_image_size(self):
            tex = self.tex
            if not tex:
                return list(self.size)
            ratio = self.image_ratio
            w, h = self.size
            #tw, th = tex.size

            # ensure that the width is always maximized to the container width

            iw = w
            # calculate the appropriate height
            ih = iw / ratio
            # if the height is too higher, take the height of the container
            # and calculate appropriate width. no need to test further. :)
            if ih > h:
                ih = h
                iw = ih * ratio
            return [iw, ih]

        norm_image_size = AliasProperty(get_norm_image_size,
                                        bind=('tex', 'size', 
                                            'image_ratio'),
                                        cache=True)


        def get_offset_pos(self):
            w, h = self.size
            tw, th = self.norm_image_size
            
            offset_x = (w - tw) / 2
            offset_y = (h - th) / 2
            
            return [self.x + offset_x, self.y + offset_y]

        offset_pos = AliasProperty(get_offset_pos,
                                bind=('norm_image_size','pos'),
                                cache=True
                                )

        def __init__(self, **kw):
            app = ObjectProperty(None)
            self.bind(offset_pos=self.send_texture_pos)
            self.bind(norm_image_size=self.send_texture_size)
            super(CameraView, self).__init__(callback_class = self, **kw)
            
            self.update_cam = self.canvas.ask_update
            self.preview_buffersize = 0
            self.set_camera_texture(2160,3840)

        
        
        def set_camera_texture(self, width: int, height: int) -> Texture:
            print("set_camera_texture", width, height)

            tex: Texture = Texture.create(
                size=(width, height),
                colorfmt="bgra",
                bufferfmt="ubyte"
                )
            tex.flip_vertical()
            self.tex = tex        
            # self.preview_buffersize = width * height * 4
            return tex
        
        def new_texture(self,size, fmt):
            print("set_camera_texture", size)
            tex: Texture = Texture.create(
                size=size,
                colorfmt=fmt,
                bufferfmt="ubyte"
                )
            tex.flip_vertical()
            self.tex = tex  
        
        def blit_buffer(self,mem):
            print("blit_buffer",len(mem))
            #self.tex.blit_buffer(mem, colorfmt="bgra")
        
        def preview_pixel_data(self, data: object, width: int, height: int, pixel_count: int):
            if pixel_count != self.preview_buffersize:
                tex = self.set_camera_texture(width,height)
                self.preview_buffersize = pixel_count
                print(self, f"changed resolution to {width}x{height}")
            else:
                tex = self.tex
            if tex:
                tex.blit_buffer(data, colorfmt="bgra")
                self.update_cam()
                
        def blit_buffer(self, data: object):
            self.tex.blit_buffer(data, colorfmt="bgra")
            self.update_cam()
            
            
        
        def returned_image_data(self, data: object, width: int, height: int):
            ...
        
        def send_texture_pos(self,_, pos):
            x,y = pos
            self.update_view_pos(x, y)
            
        def send_texture_size(self,_, size):
            w,h = size
            self.update_view_size(w, h)
        
        # def test_values(self, arg0: int, arg1: int, arg2: int, arg3: str, arg4: list[int]):
        #     print(arg0, arg1, arg2, arg3, arg4)

Swift:
******

.. code-block:: swift

    import Foundation
    import AVFoundation
    //import SwiftyJSON
    import KivySwiftLinkSupport

    import Vision

    //private let photo_output = AVCapturePhotoOutput()
    private let photoPixelFormatType = kCVPixelFormatType_32BGRA

    class PythonCameraControl: NSObject {
        
        private let captureSession = AVCaptureSession()
        //private let photoSession = AVCaptureSession()
        
        var py_call: CameraApiPyCallback!
            
        var cameratypes: [AVCaptureDevice.DeviceType] = []
        var available_back_cams: [AVCaptureDevice.DeviceType] = []
        private var videoDevice: AVCaptureDevice!
        private var currentOutputDevice: AVCaptureOutput!
        private var currentInputDevice: AVCaptureInput!
        private var videoConnection: AVCaptureConnection!
        private var inputCameras_back: [AVCaptureDevice] = []
        //private var audioConnection: AVCaptureConnection!
        var camStreamRunning = false
        var current_mode: CameraConfigMode!
        private let videoDataOutput = AVCaptureVideoDataOutput()
        
        var current_view: UnsafeRawPointer!
        var camera_texture_update: PythonPointer!
        var blit_buffer: ((PythonPointer)->Void)!
        
        var camera_python_cls: PythonObject!

        
        var tex_x: Double = 0, tex_y: Double = 0, tex_w: Double = 1000, tex_h: Double = 1000
        var tex_buffer_size: Int = 1920*1080

        
        
        override init() {
            super.init()
            InitCameraApi_Delegate(delegate: self)
            add_cameras()
            
        }
        
        
        
        func add_cameras() {
            
            cameratypes.append(contentsOf: [.builtInDualCamera, .builtInTelephotoCamera, .builtInWideAngleCamera, .builtInMicrophone])
            
            if #available(iOS 13, *) {
                cameratypes.append(contentsOf: [.builtInDualWideCamera, .builtInTripleCamera, .builtInTrueDepthCamera, .builtInUltraWideCamera])
            }
        }
        
        private func startCapture(mode: CameraConfigMode){
            if captureSession.isRunning {
                print("already running")
                return
            }
            print("Start Capturing")
            setMode(mode: mode)
            
            captureSession.startRunning()
            camStreamRunning = true
            
            
        }
        
        
        
        
        func stopCapture(){
            if !captureSession.isRunning {
                print("already stopped")
                return
            }
            camStreamRunning = false
            DispatchQueue.main.asyncAfter(deadline: .now() ) {
                self.captureSession.stopRunning()
            }
            
        }
        
        private func setupCaptureSession() {
            //let captureSession = AVCaptureSession()
            #if !targetEnvironment(simulator)
            
            
            if let captureDevice = AVCaptureDevice.default(for: .video) {
                videoDevice = captureDevice
                do {
                    let input = try AVCaptureDeviceInput(device: captureDevice)
                    currentInputDevice = input
                    print("adding input", input)
                    if captureSession.canAddInput(currentInputDevice) {
                        captureSession.addInput(currentInputDevice)
                    }
                    
                } catch let error {
                    print("Failed to set input device with error: \(error)")
                }
            }

            captureSession.sessionPreset = .hd4K3840x2160

            do {
                videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable as! String: NSNumber(value: kCVPixelFormatType_32BGRA)]
                videoDataOutput.alwaysDiscardsLateVideoFrames = true
                let queue = DispatchQueue(label: "org.kivy.videosamplequeue")
                videoDataOutput.setSampleBufferDelegate(self, queue: queue)
                
                guard captureSession.canAddOutput(videoDataOutput) else {
                    fatalError()
                }
                captureSession.addOutput(videoDataOutput)
    
                videoConnection = videoDataOutput.connection(with: .video)
                //videoConnection.videoOrientation = .landscapeLeft
            }
            #endif
        }
        
        func getPresets(view: UnsafeRawPointer) {
            let discoveryBack = AVCaptureDevice.DiscoverySession.init(deviceTypes: self.cameratypes, mediaType: .video, position: .back)
            let discoveryFront = AVCaptureDevice.DiscoverySession.init(deviceTypes: self.cameratypes, mediaType: .video, position: .front)
            self.inputCameras_back.append(contentsOf: discoveryBack.devices)
            //print("targets", available_back_cams.map({$0.rawValue}))
            let backs = discoveryBack.devices.map({$0.deviceType.rawValue.replacingOccurrences(of: "AVCaptureDeviceTypeBuiltIn", with: "")})
            let fronts = discoveryFront.devices.map({$0.deviceType.rawValue.replacingOccurrences(of: "AVCaptureDeviceTypeBuiltIn", with: "")})
            //py_call.get_camera_types(cls: view, front: fronts.asData(), back: backs.asData())
        }
        
        func removeCaptureDevice(device: AVCaptureOutput) {
            if captureSession.outputs.contains(device) {
                captureSession.removeOutput(device)
            }
            if currentOutputDevice != nil {
                currentOutputDevice = nil
            }
        }
        
        private func PhotoMode() {
            let photo_output = AVCapturePhotoOutput()
            print("setting photo mode: \(photo_output)")
            photo_output.isHighResolutionCaptureEnabled = true
            if captureSession.canAddOutput(photo_output) {
                captureSession.addOutput(photo_output)
            } else {return}
            currentOutputDevice = photo_output
        }
        
        private func QRCodeMode() {
            let metadataOutput = AVCaptureMetadataOutput()
            if (captureSession.canAddOutput(metadataOutput)) {
                captureSession.addOutput(metadataOutput)

                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = [.qr]
            } else {return}
            currentOutputDevice = metadataOutput
        }
        
        private func CoreMLMode() {
            //setupCoreML()
            //PhotoMode()
        }
        

        private func setMode(mode: CameraConfigMode) {
            if let device = currentOutputDevice {
                removeCaptureDevice(device: device)
            }
            current_mode = mode
            switch mode {
                case .QRcode:
                    QRCodeMode()
                case .PhotoRaw:
                    PhotoMode()
                case .PhotoPng:
                    break
                case .Video:
                    break
                case .Vision:
                    break
                    //VisionTextMode()
                case .CoreML:
                    CoreMLMode()
                default:
                    break
            }
        }
        
        func setPreviewSize(width: Int, height: Int) {
            let pixelBufferOptions = [
                kCVPixelBufferWidthKey : NSNumber(value: width),
                kCVPixelBufferHeightKey : NSNumber(value: height),
                kCVPixelBufferPixelFormatTypeKey : NSNumber(value: UInt32(kCVPixelFormatType_32BGRA))
            ] as [String: Any]
            videoDataOutput.videoSettings = pixelBufferOptions
        }
        
        func capturePhoto() {
            if let device = currentOutputDevice {
                if device is AVCapturePhotoOutput {
                    if let photo_output = device as? AVCapturePhotoOutput {
                        let settings = AVCapturePhotoSettings(format: [kCVPixelBufferPixelFormatTypeKey as String : photoPixelFormatType] )
                        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
                        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                                            kCVPixelBufferWidthKey as String: 160,
                                            kCVPixelBufferHeightKey as String: 160]
                        settings.previewPhotoFormat = previewFormat
                        photo_output.capturePhoto(with: settings, delegate: self)
                    }
                }
            }
        }
        
        func setFocusPoint(x: Double, y: Double) {
            let focus_point = CGPoint(x: x, y: y)

            try! videoDevice.lockForConfiguration()
            videoDevice.focusPointOfInterest = focus_point
            videoDevice.exposurePointOfInterest = focus_point
            videoDevice.focusMode = .autoFocus
            videoDevice.exposureMode = .autoExpose
            videoDevice.unlockForConfiguration()
        }
    }

    extension PythonCameraControl: CameraApi_Delegate {
        
        func set_CameraApi_Callback(callback: CameraApiPyCallback) {
            py_call = callback
            blit_buffer = callback.blit_buffer
            setupCaptureSession()
            
        }
        
        func update_view_pos(x: Double, y: Double) {
            tex_x = x
            tex_y = y
        }
        
        func update_view_size(width: Double, height: Double) {
            tex_w = width
            tex_h = height
        }
        
        
        func start_capture(mode: Int, callback_cls callback_class: PythonPointer) {
            //current_view = cls
            //camera_texture_update = callback_class
            //callback_class.incref()
            
            
            //PythonPointer converted to new type "PythonObject"
            //camera_python_cls = callback_class.object
            //PythonObject can Dynamic Subscript
            //camera_blit_buffer = camera_python_cls.blit_buffer
            //camera_canvas_update = camera_python_cls.canvas.ask_update
            //camera_texture_update = camera_python_cls.preview_pixel_data
            //camera_new_texture = camera_python_cls.new_texture
            
            //current_mode = mode
            startCapture(mode: .init(rawValue: mode)!)
        }
        
        func stop_capture(mode: Int) {
            stopCapture()
            //camera_texture_update.decref()
            //camera_texture_update = nil
            //camera_blit_buffer.decref()
            //camera_blit_buffer = nil
            //camera_canvas_update.decref()
            //camera_canvas_update = nil
            current_view = nil
        }
        
        func get_presets() {
            //getPresets(view: cls)
        }
        
        func set_camera_mode(mode: Int) {
            
        }
        
        func select_camera(index: Int) {
            captureSession.removeInput(currentInputDevice)
            videoDevice = inputCameras_back[index]
            currentInputDevice = try! AVCaptureDeviceInput(device: videoDevice)
            captureSession.addInput(currentInputDevice)
        }
        
        func take_photo() {
            capturePhoto()
        }
        
        func take_multi_photo(count: Int) {
            
        }
        
        func set_preview_size(width: Int, height: Int) {
            setPreviewSize(width: width, height: height)
        }
        
        func select_preview_preset(preset: String) {
            DispatchQueue.global().async {
            if self.captureSession.isRunning {
                self.stopCapture()
                self.captureSession.sessionPreset = .init(rawValue: preset)
                if let mode = self.current_mode {
                    self.startCapture(mode: mode)
                }
            } else {
                self.captureSession.sessionPreset = .init(rawValue: preset)
            }
        }
        }
        
        func set_focus_point(x: Double, y: Double) {
            setFocusPoint(x: x, y: 1 - y)
        }
        
        func zoom_camera(zoom: Double) {
            try! videoDevice.lockForConfiguration()
            videoDevice.videoZoomFactor = CGFloat(zoom)
            videoDevice.unlockForConfiguration()
        }
        
        func set_exposure(value: Double) {
            try! videoDevice.lockForConfiguration()
            videoDevice.setExposureTargetBias(Float(value)) { (time) in
                print(time)
            }
            videoDevice.unlockForConfiguration()
        }
        
        func auto_exposure(state: Bool) {
            try! videoDevice.lockForConfiguration()
            if state {
                videoDevice.exposureMode = .locked
            } else {
                videoDevice.exposureMode = .autoExpose
            }
            videoDevice.unlockForConfiguration()
        }
        
    
    }

Api:
****

Enums:
""""""

.. autoclass:: camera_api.CameraConfigMode
    :members:
    :undoc-members:
        
.. autoclass:: camera_api.CameraApi
    :members:

.. autoclass:: camera_api.CameraApi.Callbacks
    :members:

.. autoclass:: camera_api.CameraView
    :members: