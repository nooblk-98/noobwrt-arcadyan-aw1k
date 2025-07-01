### Connect via SSH and Run Custom Firmware Script**

After rebooting, the router will boot into OpenWrt.

1. On your terminal (Linux/macOS) or via PuTTY (Windows), connect to the router:

   ```bash
   ssh-keygen -R 192.168.1.1
   ```
   ```bash
   ssh root@192.168.1.1
   ```

2. If prompted with a host authenticity warning, type `yes`.

3. Once logged in, run the custom firmware flash script:

   ```sh
    wget -O /tmp/flash-lite.sh https://raw.githubusercontent.com/nooblk-98/arcadyan-aw1000-mod-firmware/refs/heads/main/flash/flash-lite.sh && chmod +x /tmp/flash-lite.sh && sh /tmp/flash-lite.sh
   ```

4. The script will handle flashing and applying custom modifications. Monitor the terminal output for progress.

---

### 📺 How to Flash Video

[![Watch on YouTube](https://img.youtube.com/vi/6eYihpGg7Sw/hqdefault.jpg)](https://youtu.be/6eYihpGg7Sw)



### ✅ After Completion

Once the script completes and the router reboots:

* Access OpenWrt LuCI Web Interface at:

  ```
  http://192.168.1.1
  ```
