# Serial Hex Terminal

A lightweight, GUI-based PowerShell utility for sending raw hexadecimal bytes to serial devices and viewing their responses.

## Features
- **Graphical Interface**: Simple Windows Form UI built with PowerShell.
- **Hex Formatting**: Automatically strips spaces and validates hex input.
- **Real-time Logging**: Displays TX (Sent) and RX (Received) data in a scrollable terminal window.
- **Portable**: No installation required; runs natively on Windows via PowerShell.


<img width="446" height="498" alt="Screenshot 2026-06-18 101117" src="https://github.com/user-attachments/assets/cbba4f54-0ad8-4d53-a5ba-2ede499b128e" />


## Prerequisites
- Windows OS
- PowerShell 5.1 or later

## How to Use
1. Download the `serial hex to com.ps1` file.
2. Right-click the file and select **"Run with PowerShell"**. (Alternatively download and run the exe from the release)
3. Enter your **COM Port** (e.g., `COM3`).
4. Set the **Baud Rate** (e.g., `115200`).
5. Enter your hex payload (e.g., `AA 09 00 09`).
6. Click **"Send Bytes"**.


## Troubleshooting
- **Permission Denied**: Ensure no other application (like Arduino IDE Serial Monitor) is currently using the COM port.
- **No Response**: Verify that your device is powered on, the baud rate matches the device requirements, and the cables are securely connected.

## License
MIT
