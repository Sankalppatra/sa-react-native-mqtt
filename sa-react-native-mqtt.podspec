require "json"

json = File.read(File.join(__dir__, "package.json"))
package = JSON.parse(json).deep_symbolize_keys

Pod::Spec.new do |s|
  s.name         = "sa-react-native-mqtt-mqtt"
  s.version      = "0.6.8"
  s.summary      = "MQTT client for react-native"
  s.description  = <<-DESC
                  MQTT client for react-native
                   DESC
  s.homepage     = "https://github.com/Sankalppatra/sa-react-native-mqtt-mqtt"
  s.license      = "MIT"
  s.author       = { "sankalp patra" => "sankalppatra2002@gmail.com" }
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/Sankalppatra/sa-react-native-mqtt-mqtt.git", :tag => "master" }
  s.source_files  = "ios/**/*.{h,m}"
  s.requires_arc = true

  s.dependency "React"
  s.dependency "MQTTClient"
end