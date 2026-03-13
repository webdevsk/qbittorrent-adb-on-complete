# qBittorrent to Android Auto-Push

A lightweight Windows batch script that automatically transfers finished video downloads from qBittorrent directly to your Android device via ADB. 

To keep your device serial number out of version control, this script uses a local environment variable to identify your specific phone.

## Features
* **Safe for Git:** Device serial is stored locally in an environment variable, not hardcoded.
* **Efficient Logic:** Fails fast. It immediately exits if the download isn't a single file, isn't an `.mkv`, or if your specific device isn't plugged in.
* **Size Limit:** Prevents massive transfers by restricting pushes to files under 2GB.
* **Targeted Push:** Ignores other devices on the network and pushes only to your designated phone.

## Prerequisites
1. **Windows OS** (relies on Batch and PowerShell).
2. **qBittorrent** installed.
3. **Android Platform Tools (ADB)** installed and added to your system's `PATH`.
4. USB Debugging enabled on your Android device and authorized with your PC.

## Setup Instructions

### 1. Set Your Device Environment Variable
First, find your device's ADB serial number:
1. Plug your phone into your PC.
2. Open Command Prompt and run `adb devices`.
3. Copy the alphanumeric string next to the word `device`.

Next, save it as a permanent Windows environment variable:
1. Open Command Prompt as Administrator.
2. Run the following command (replace `YOUR_SERIAL` with your actual serial number):
   ```bat
   setx MY_ADB_DEVICE "YOUR_SERIAL"
Restart your computer (or fully exit and restart qBittorrent) to ensure the application picks up the new environment variable.

### 2. Configure qBittorrent
Open qBittorrent and go to Tools > Options (or press Alt + O).

Navigate to the Downloads tab.

Scroll down to the Run external program section.

Check the box for Run on torrent finished.

Paste the following command into the text box. Make sure to update the path to point to where you saved the .bat file:

```bat
"C:\Path\To\Your\qbittorrent-adb-on-complete\index.bat" "%C" "%Z" "%F"
```

#### How the Parameters Work
%C: Number of files in the torrent.

%Z: Total size of the torrent in bytes.

%F: Absolute path to the downloaded file.

#### File Destination
By default, the script pushes the file to the following directory on your Android device:
```
/storage/emulated/0/Download/Quick Share
```