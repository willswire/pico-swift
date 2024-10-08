# pico-swift

this project is a playground for embedded swift on the rasberry pi pico w. the first experiment is to get wifi up and running on the pico, using as little of the c sdk as possible. this may require some reimplementation of the sdk from c in swift native. we'll see how that goes...

## build notes

install the following dependencies (Apple silicon):
- [Arm GNU Toolchain 13.3](https://developer.arm.com/-/media/Files/downloads/gnu/13.3.rel1/binrel/arm-gnu-toolchain-13.3.rel1-darwin-arm64-arm-none-eabi.pkg)
- [CMake 3.30.3](https://github.com/Kitware/CMake/releases/download/v3.30.3/cmake-3.30.3-macos-universal.dmg)
- [Ninja 1.12.1](https://github.com/ninja-build/ninja/releases/download/v1.12.1/ninja-mac.zip)

```sh
# set up all git submodules
git submodule update --init

# set up creds (this file is ignored)
cp Credentials.swift.template Credentials.swift

# build commands
cmake -B build -G Ninja .
cmake --build build
```

## run notes

```sh
# copy the program to the pico
cp build/ps.uf2  /Volumes/RPI-RP2

# the following usb tty id is specific to me
# run `ls /dev/tty.*` on macOS to find yours

screen /dev/tty.usbmodem11101 115200
```

To exit your Screen session completely[^1]:

- Make sure the Terminal window has focus.
- Type Ctrl+A (you won’t see anything displayed yet)
- Then type Ctrl+\ (the forward slash is located below Delete)
- At the bottom of the Terminal window, you should see “Really quit and kill all your windows [y/n]”. Type “y”.
- A confirmation to quit screen will show up in the bottom left corner of Terminal
- You are now back in your regular Terminal command line.

## helpful links

- [Networking Libraries](https://www.raspberrypi.com/documentation/pico-sdk/networking.html#pico_cyw43_arch)
- [Getting started with Pico](https://datasheets.raspberrypi.com/pico/getting-started-with-pico.pdf)
- [Swift Forums discussion on example projects](https://forums.swift.org/t/embedded-swift-example-projects-for-arm-and-risc-v-microcontrollers/71066/30)

[^1]: [Using Screen - Mac / Linux](https://ssg-drd-iot.github.io/getting-started-guides/docs/shell_access/mac-and-linux/using_screen.html)
