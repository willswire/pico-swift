# Set the minimum version of CMake required
cmake_minimum_required(VERSION 3.29)

# Set environment variables for toolchains and board
set(ENV{TOOLCHAINS} "org.swift.61202408211a")
set(ENV{PICO_BOARD} "pico_w")

# Set the path to the Pico SDK
set(PICO_SDK_PATH ${CMAKE_CURRENT_SOURCE_DIR}/pico-sdk)

# Include the Pico SDK
include(${PICO_SDK_PATH}/external/pico_sdk_import.cmake)

# Set Swift compilation mode and indicate that the Swift compiler works
set(CMAKE_Swift_COMPILATION_MODE wholemodule)
set(CMAKE_Swift_COMPILER_WORKS YES)

# Define the project name
project(pico-swift)

# Initialize the Pico SDK
pico_sdk_init()

# Enable Swift language support
enable_language(Swift)

# Add the executable target and source files
add_executable(ps Main.swift Credentials.swift Device.swift)
set_target_properties(ps PROPERTIES LINKER_LANGUAGE CXX)

# Clear default compile options and set them only for C code
set_target_properties(pico_standard_link PROPERTIES INTERFACE_COMPILE_OPTIONS "")
target_compile_options(pico_standard_link INTERFACE "$<$<COMPILE_LANGUAGE:C>:SHELL: -ffunction-sections -fdata-sections>")

# Set Swift include directories
set(SWIFT_INCLUDES)
foreach(dir ${CMAKE_C_IMPLICIT_INCLUDE_DIRECTORIES})
    string(CONCAT SWIFT_INCLUDES ${SWIFT_INCLUDES} "-Xcc ")
    string(CONCAT SWIFT_INCLUDES ${SWIFT_INCLUDES} "-I${dir} ")
endforeach()

# Set Swift compile options
target_compile_options(ps PUBLIC "$<$<COMPILE_LANGUAGE:Swift>:SHELL:
        -enable-experimental-feature Embedded
        -target armv6m-none-none-eabi -Xcc -mfloat-abi=soft -Xcc -fshort-enums -Xfrontend -function-sections
        -Xcc -DPICO_CYW43_ARCH_THREADSAFE_BACKGROUND
        -import-bridging-header ${CMAKE_CURRENT_LIST_DIR}/BridgingHeader.h
        ${SWIFT_INCLUDES}
    >")

# Link libraries to the executable
target_link_libraries(ps
    pico_stdlib
    pico_cyw43_arch_lwip_threadsafe_background
)

# Include directories for the project
include_directories(${CMAKE_CURRENT_LIST_DIR}/include)

# Add extra outputs for the Pico board
pico_add_extra_outputs(ps)

# Enable USB output and disable UART output for the executable
pico_enable_stdio_usb(ps 1)
pico_enable_stdio_uart(ps 0)
