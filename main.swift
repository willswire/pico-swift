@main
struct Main {
    static func main() {
        let led = UInt32(CYW43_WL_GPIO_LED_PIN)
        if cyw43_arch_init() != 0 {
            print("Wi-Fi init failed")
            return
        }
        while true {
            cyw43_arch_gpio_put(led, true)
            sleep_ms(1000)
            cyw43_arch_gpio_put(led, false)
            sleep_ms(1000)
        }
    }
}