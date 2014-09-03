Pod::Spec.new do |s|
    s.name          = "SIOSocket"
    s.version       = "0.0.3"
    s.summary       = "Realtime iOS application framework (client) http://socket.io"
    s.license       =  "MIT"
    s.source        = { :tag => "v0.0.3", :git => "https://github.com/MegaBits/SIOSocket.git"}
    s.platform      = :ios, "7.0"
    s.source_files  = "SocketIO/Source/*.{h,m}"
    s.requires_arc  = true
    s.homepage      = "https://github.com/MegaBits/SIOSocket"
    s.authors       = { "Patrick Perini" => "pcperini@gmail.com" }
end