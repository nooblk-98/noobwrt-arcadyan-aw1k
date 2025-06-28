# Uboot Flash Methode 

This guide is intended for users of the original firmware on the AW1000 router who wish to upgrade to a custom firmware. Please proceed with caution and follow the instructions carefully. 

> ⚠️ Note: We are not responsible for any damage or issues that may occur during or after the flashing process.

### **Step 1: Prepare Your Environment**

1. **Connect LAN**
   Plug an **Ethernet cable** into one of the yellow LAN ports of your router and connect the other end to your **computer**.

2. **Set a Static IP on Your Computer**

   * Go to your computer's **Network Settings**.
   * Set your **IPv4 address** manually to:

     ```
     IP Address: 192.168.1.2
     Subnet Mask: 255.255.255.0
     Gateway: 192.168.1.1 (optional)
     ```

---

### **Step 2: Power On Router into U-Boot Mode**

1. Unplug the router from power.
2. Press and **hold the reset/WPS button** (usually on the back).
3. While holding the button, **plug in power**.
4. Continue holding for **8–10 seconds** until:

   * The LED flashes differently.
   * Or you can **ping 192.168.1.1** from your computer and get a response.

---

### **Step 3: Access the U-Boot Web Interface**

1. Open your browser and go to:

   ```
   http://192.168.1.1
   ```
2. You should see the **U-Boot recovery page**.

---

Here is the corrected and professionally formatted **Step 4** for flashing the firmware:

---

### **Step 4: Flash the Firmware**

1. Download the official **OpenWrt (ImmortalWrt) raw firmware** file from the following URL:

   ```
   https://downloads.immortalwrt.org/releases/24.10.2/targets/qualcommax/ipq807x/immortalwrt-24.10.2-qualcommax-ipq807x-arcadyan_aw1000-squashfs-factory.ubi
   ```

   > You can also use a custom `.ubi` firmware if you have one prepared.

2. Open the **U-Boot recovery page** at `http://192.168.1.1` in your browser.

3. On the U-Boot web interface:

   * Click **Choose File** and select the downloaded `.ubi` firmware file.
   * Click **Update Firmware** or **Upload** (label may vary depending on version).

4. Wait **2–3 minutes** for the flashing process to complete. The router will automatically reboot after the firmware is successfully installed.

---
### **Step 5: Connect via SSH and Run Custom Firmware Script**

After rebooting, the router will boot into OpenWrt.

1. On your terminal (Linux/macOS) or via PuTTY (Windows), connect to the router:

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

### ✅ After Completion

Once the script completes and the router reboots:

* Access OpenWrt LuCI Web Interface at:

  ```
  http://192.168.1.1
  ```
