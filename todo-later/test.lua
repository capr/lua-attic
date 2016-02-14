local nw = require'nw'

local objc = require'objc'
local ffi = require'ffi'
local dispatch = require'objc_dispatch'

objc.load'AVFoundation'
objc.load'CoreVideo'
objc.load'CoreMedia'
objc.load'CoreFoundation'

session = objc.AVCaptureSession:alloc():init()
session:setSessionPreset(objc.AVCaptureSessionPresetHigh)

device = objc.AVCaptureDevice:defaultDeviceWithMediaType(objc.AVMediaTypeVideo)
assert(device)

local err = ffi.new'id[1]'
input = objc.AVCaptureDeviceInput:deviceInputWithDevice_error(device, err)
assert(input)
assert(err[0] == nil)
assert(session:canAddInput(input))
session:addInput(input)

MyAVCaptureVideoDataOutput = objc.class('MyAVCaptureVideoDataOutput',
	'AVCaptureVideoDataOutput <AVCaptureVideoDataOutputSampleBufferDelegate>')

videoDataOutput = MyAVCaptureVideoDataOutput:new() --objc.AVCaptureVideoDataOutput:new()
assert(videoDataOutput)

pixelformat = objc.tolua(ffi.cast('id', objc.kCVPixelBufferPixelFormatTypeKey))
settings = objc.toobj{[pixelformat] = objc.kCVPixelFormatType_32BGRA}
videoDataOutput:setVideoSettings(settings)

videoDataOutput:setAlwaysDiscardsLateVideoFrames(true)

videoDataOutputQueue = dispatch.main_queue -- dispatch.queue_create('VideoDataOutputQueue', dispatch.DISPATCH_QUEUE_SERIAL)

local win, cambmp

function videoDataOutput:captureOutput_didOutputSampleBuffer_fromConnection(co, sb, conn)

	--local arr = objc.CMSampleBufferGetSampleAttachmentsArray(sb, false)
	--print(arr)
	local img = objc.CMSampleBufferGetImageBuffer(sb)
	objc.CVPixelBufferLockBaseAddress(img, objc.kCVPixelBufferLock_ReadOnly)
	local p = objc.CVPixelBufferGetBaseAddress(img)
	--local typ = objc.CFGetTypeID(img)
	--assert(typ == objc.CVPixelBufferGetTypeID)
	local sz = objc.CVImageBufferGetDisplaySize(img)
	local w, h = sz.width, sz.height
	local sz = w * h * 4
	local buf = ffi.new('char[?]', sz)
	ffi.copy(buf, p, sz)
	cambmp = {
		data = buf,
		w = w,
		h = h,
		size = sz,
		format = 'bgra8',
		stride = w * 4,
	}
	objc.CVPixelBufferUnlockBaseAddress(img, objc.kCVPixelBufferLock_ReadOnly)

	win:invalidate()
	--dispatch.async(dispatch.main_queue, function()
	--end)
end

videoDataOutput:setSampleBufferDelegate_queue(videoDataOutput, videoDataOutputQueue)

local obj = ffi.new('dispatch_object_t')
obj._dq = videoDataOutputQueue
dispatch.release(obj)

assert(session:canAddOutput(videoDataOutput))
session:addOutput(videoDataOutput)

conn = videoDataOutput.connections:objectAtIndex(0)
assert(conn)

if conn.supportsVideoMirroring then
	print(conn.automaticallyAdjustsVideoMirroring, conn.videoMirrored)
	conn.automaticallyAdjustsVideoMirroring = false
	conn.videoMirrored = true
	print(conn.automaticallyAdjustsVideoMirroring, conn.videoMirrored)
end

if conn.supportsVideoOrientation then
	print(conn.videoOrientation, objc.AVCaptureVideoOrientationPortraitUpsideDown)
	conn.videoOrientation = objc.AVCaptureVideoOrientationPortraitUpsideDown
end

session:startRunning()

local app = nw:app()
win = app:window{cw = 700, ch = 500}
function win:repaint()
	if not cambmp then return end
	local bmp = self:bitmap()
	bmp:clear()
	local bitmap = require'bitmap'
	local box2d = require'box2d'
	local rect = box2d(box2d.clip(0, 0, bmp.w, bmp.h, 0, 0, cambmp.w, cambmp.h))
	local src = bitmap.sub(cambmp, rect())
	local dst = bitmap.sub(bmp,    rect())
	if bmp then
		bitmap.paint(src, dst)
	end
end
app:runevery(0.1, function()
	--win:invalidate()
end)
app:run()

session:stopRunning()
