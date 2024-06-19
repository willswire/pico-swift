struct Device {
    var led: LED
    var network: Network

    public enum SleepUnits {
        case sec, min
    }

    init() {
        stdio_init_all()

        if cyw43_arch_init() != 0 {
            fatalError("Unable to initialize the Wi-Fi module")
        }

        self.led = LED()
        self.network = Network()
    }
    
    public func sleep(duration: Int = 1, unit: SleepUnits = .sec) {
        var newDuration: UInt32 = UInt32(duration);
        switch unit {
        case .sec:
            newDuration = newDuration * 1000
            break
        case .min:
            newDuration = newDuration * 60000
            break
        }
        sleep_ms(newDuration);
    }
}

struct Network {
    init() {
        cyw43_arch_enable_sta_mode();
    }

    public func connect(ssid: StaticString, password: StaticString) {
        print("Connecting to Wi-Fi...")
        let err = cyw43_arch_wifi_connect_blocking(ssid.utf8Start, password.utf8Start, 0x00400004)

        if err != 0 {
            print("Failed to connect to Wi-Fi!")
        } else {
            print("Connected to Wi-Fi!")
        }
    }
}

struct LED {
    private let pin = UInt32(CYW43_WL_GPIO_LED_PIN);

    var enabled: Bool = true {
        didSet {
            cyw43_arch_gpio_put(pin, enabled)
        }
    }
}