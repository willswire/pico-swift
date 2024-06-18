struct Device {
    var led: LED = LED()

    public enum SleepUnits {
        case sec, min
    }

    init() {
        stdio_init_all()

        if cyw43_arch_init() != 0 {
            fatalError("Unable to initialize the Wi-Fi module")
        }
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

struct LED {
    private let pin = UInt32(CYW43_WL_GPIO_LED_PIN);

    var enabled: Bool = true {
        didSet {
            cyw43_arch_gpio_put(pin, enabled)
        }
    }
}