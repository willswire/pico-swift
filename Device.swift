struct Device {
    var led: LED
    var network: Network

    init() {
        stdio_init_all()

        if cyw43_arch_init() != 0 {
            fatalError("Unable to initialize the Wi-Fi module")
        }

        self.led = LED()
        self.network = Network()
    }
}

public enum SleepUnits {
    case sec, min
}

public func sleep(duration: Int = 1, unit: SleepUnits = .sec) {
    var newDuration: UInt32 = UInt32(duration)
    switch unit {
    case .sec:
        newDuration = newDuration * 1000
    case .min:
        newDuration = newDuration * 60000
    }
    sleep_ms(newDuration)
}

// Define the callback function
public func callback(
    arg: UnsafeMutableRawPointer?,
    pcb: UnsafeMutablePointer<udp_pcb>?,
    p: UnsafeMutablePointer<pbuf>?,
    addr: UnsafePointer<ip4_addr>?,
    port: UInt16
) {
    // Function implementation
    if p != nil {
        // Print "Connected!" when data is received
        var led: LED = LED()
        print("Connected!")
        led.enabled = true
        sleep()
        led.enabled = false
    }
    if let p = p {
        pbuf_free(p)
    }
}

struct Network {
    init() {
        cyw43_arch_enable_sta_mode()
    }

    public func connect(ssid: StaticString, password: StaticString) {
        print("Connecting to Wi-Fi...")
        //let CYW43_AUTH_WPA2_AES_PSK: UInt32 = 0x0040_0004
        let CYW43_AUTH_WPA3_SAE_AES_PSK: UInt32 = 0x0100_0004
        let err = cyw43_arch_wifi_connect_blocking(
            ssid.utf8Start, password.utf8Start, CYW43_AUTH_WPA3_SAE_AES_PSK)

        if err != 0 {
            print("Failed to connect to Wi-Fi!")
        } else {
            print("Connected to Wi-Fi!")
        }
    }

    public func listen() {
        print("Allocating a new PCB for a UDP socket...")
        let pcb = udp_new()

        if pcb == nil {
            print("Failed to allocate the PCB!")
        } else {
            print("Allocated a new PCB")
            print("Binding a new UDP socket...")
            let nullPointer: UnsafePointer<ip_addr_t>? = nil
            let bindRes = udp_bind(pcb, nullPointer, 777)
            if bindRes != 0 {
                print("Failed to bind UDP socket!")
            } else {
                print("Bound to UDP socket successfully")
                let nullPointer: UnsafeMutableRawPointer? = nil
                udp_recv(pcb, callback, nullPointer)
                while true {
                    print("Standby to receive data...")
                    sleep(duration: 5, unit: .sec)
                }
            }
        }
    }
}

struct LED {
    private let pin = UInt32(CYW43_WL_GPIO_LED_PIN)

    var enabled: Bool = true {
        didSet {
            cyw43_arch_gpio_put(pin, enabled)
        }
    }
}
