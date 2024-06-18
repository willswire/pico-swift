@main
struct Main {
    static func main() {
        stdio_init_all();
        while true {
            print("Hello World!")
            sleep_ms(1000);
        }
    }
}