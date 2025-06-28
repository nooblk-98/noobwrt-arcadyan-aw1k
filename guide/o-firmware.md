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

### **Step 4: Flash the Custom Firmware**

1. Download the `openwrt-ramips-mt7621-aw1000-squashfs-factory.bin` file (or your custom `.bin` image).
2. On the U-Boot web page:

   * Click **Choose File** and select your `.bin` firmware.
   * Click **Update Firmware**.
3. Wait 2–3 minutes for the process to complete. The router will reboot automatically.

---