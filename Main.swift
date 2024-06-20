@main
struct Main {
    static func main() {
        var device: Device = Device()
        
        var ctr: Int = 10
        while ctr != 0 {
            print("Delaying for console access...")
            device.led.enabled.toggle()
            sleep(duration: 1)
            ctr -= 1
        }

        device.led.enabled = false
        device.network.connect(ssid: WIFI_SSID, password: WIFI_PASS)
        device.network.listen()
    }
}