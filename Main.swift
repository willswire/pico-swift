@main
struct Main {
    static func main() {
        var device: Device = Device()
        
        while true {
            print("Flipping the switch!")
            device.led.enabled.toggle()
            device.sleep(duration: 1)
        }
    }
}