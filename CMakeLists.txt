# Specify the minimum required version of CMake
cmake_minimum_required(VERSION 3.13)

# Set environment variables for the toolchains and board type
set(ENV{TOOLCHAINS} "swift")
set(ENV{PICO_BOARD} "pico_w")
# Set the path to the Pico SDK
set(ENV{PICO_SDK_PATH} "${CMAKE_CURRENT_SOURCE_DIR}/pico-sdk/")

# Include the Pico SDK CMake import file
include($ENV{PICO_SDK_PATH}/external/pico_sdk_import.cmake)

# Define the project name
project(swift-pico)

# Initialize the Pico SDK
pico_sdk_init()

# Get the path to the Swift compiler using xcrun
execute_process(
    COMMAND xcrun -f swiftc
    OUTPUT_VARIABLE SWIFTC
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

# Define an executable target named 'swift-pico'
add_executable(swift-pico)

# Define a custom command to compile Swift code to an object file
add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/_swiftcode.o
    COMMAND ${SWIFTC}
        -target armv6m-none-none-eabi -Xcc -mfloat-abi=soft -Xcc -fshort-enums
        -Xcc -DCYW43_LWIP
        -Xcc -DPICO_CYW43_ARCH_THREADSAFE_BACKGROUND
        -Xcc -I$ENV{PICO_SDK_PATH}/lib/lwip/src/include
        -Xcc -I${CMAKE_CURRENT_LIST_DIR}/include
        -Xfrontend -function-sections -enable-experimental-feature Embedded -wmo -parse-as-library
        $$\( echo '$<TARGET_PROPERTY:swift-pico,INCLUDE_DIRECTORIES>' | tr '\;' '\\n' | sed -e 's/\\\(.*\\\)/-Xcc -I\\1/g' \)
        $$\( echo '${CMAKE_C_IMPLICIT_INCLUDE_DIRECTORIES}' | tr ' ' '\\n' | sed -e 's/\\\(.*\\\)/-Xcc -I\\1/g' \)
        -import-bridging-header ${CMAKE_CURRENT_LIST_DIR}/BridgingHeader.h
        ${CMAKE_CURRENT_LIST_DIR}/*.swift
        -c -o ${CMAKE_CURRENT_BINARY_DIR}/_swiftcode.o
    DEPENDS
        ${CMAKE_CURRENT_LIST_DIR}/BridgingHeader.h
        ${CMAKE_CURRENT_LIST_DIR}/Main.swift
)

# Create a custom target to build the Swift code
add_custom_target(swift-pico-swiftcode DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/_swiftcode.o)

# Link the Swift object file with the executable target
target_link_libraries(swift-pico
    pico_stdlib
    hardware_uart
    hardware_gpio
    pico_lwip_arch
    pico_cyw43_arch_lwip_threadsafe_background
    ${CMAKE_CURRENT_BINARY_DIR}/_swiftcode.o
)

# Include local lwipopts
include_directories(${CMAKE_CURRENT_LIST_DIR}/include)

# Ensure the Swift code is compiled before linking the executable
add_dependencies(swift-pico swift-pico-swiftcode)

# Add extra outputs for the executable (map/bin/hex/uf2)
pico_add_extra_outputs(swift-pico)

# Enable USB output and disable UART output for the executable
pico_enable_stdio_usb(swift-pico 1)
pico_enable_stdio_uart(swift-pico 0)