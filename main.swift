@main
struct Main {
    static func main() {
        stdio_init_all();

        if cyw43_arch_init() != 0 {
            print("Wi-Fi init failed");
            return;
        }

        let led = UInt32(CYW43_WL_GPIO_LED_PIN);
        var isMorning: Bool = true;
        
        while true {
            if (isMorning) {
                print("Good Morning!");
            } else {
                print("Good Night!");
            }
            
            cyw43_arch_gpio_put(led, isMorning)
            isMorning.toggle();
            sleep_ms(5000);
        }
    }
}