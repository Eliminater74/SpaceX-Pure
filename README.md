# Rooting_Android_5.1.1-6.0_SELinux-Enforcing
Rooting Android 5.1.1/6.0 on stock Kernel, SELinux enforcing. Modified ramdisk only! 

You need modifications sepolicy yourself as follows: (All credit SuperSU 2.50+ @Chainfire)
- Root a reference device (4.4+ with SELinux enabled) with v2.50+
- Extract the sepolicy file from the target boot image's ramdisk
- With the reference device connected to ADB:

adb push sepolicy /data/local/tmp/sepolicy
adb shell su -c "supolicy --file /data/local/tmp/sepolicy /data/local/tmp/sepolicy_out"
adb shell su -c "chmod 0644 /data/local/tmp/sepolicy_out"
adb pull /data/local/tmp/sepolicy_out sepolicy_out

- Replace the sepolicy file in the boot image's ramdisk with the sepolicy_out file
- Profit
