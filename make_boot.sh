#!/bin/bash +x

# Kernel build script by ManhIT (ChoiMobile.VN)

clear
echo
echo

######################################## SETUP #########################################

# set variables

Flash="SpaceX-Pure-Edition_v1.0.0_N920T"
BK=build_kernel
OUT=Output

# updater-script setup
sed -i -e '/ui_print("~~~~~~~~~ SpaceX Kernel for/c\ui_print("~~~~~~~~~ SpaceX Kernel Peru Edition for Galaxy Note 5 ~~~~~~~~~");' Output/META-INF/com/google/android/updater-script

sed -i -e '/by ManhIT ~~~~~~~~~~~~~~~");/c\ui_print("~~~~~~~~~~~~~~~ N920T - by ManhIT ~~~~~~~~~~~~~~~");' Output/META-INF/com/google/android/updater-script

sed -i -e '/package_extract_file("boot.img/c\package_extract_file("boot.img", "/dev/block/platform/15570000.ufs/by-name/BOOT");' Output/META-INF/com/google/android/updater-script

cd .. #move to source directory

###################################### DT.IMG GENERATION #####################################

echo -n "dt.img......................................."
# Calculate DTS size for all images and display on terminal output
du -k "$BK/dt.img" | cut -f1 >sizT
sizT=$(head -n 1 sizT)
rm -rf sizT
echo "$sizT Kb"


###################################### RAMDISK GENERATION #####################################

echo -n "Make Ramdisk archive..............................."
cp $BK/ramdisk_fix_permissions.sh $BK/ramdisk/ramdisk_fix_permissions.sh
cd $BK/ramdisk
chmod 0777 ramdisk_fix_permissions.sh
./ramdisk_fix_permissions.sh
rm -f ramdisk_fix_permissions.sh
find .| cpio -o -H newc | lzma -9 > ../ramdisk.cpio.gz

##################################### BOOT.IMG GENERATION #####################################

echo -n "Make boot.img......................................"
cd ..
./mkbootimg --base 0x10000000 --kernel kernel --ramdisk_offset 0x01000000 --tags_offset 0x00000100 --pagesize 2048 --ramdisk ramdisk.cpio.gz --dt dt.img -o boot.img
# copy the final boot.img's to output directory ready for zipping
cp boot*.img $OUT/
echo "Done"


######################################## ZIP GENERATION #######################################

echo -n "Creating flashable file............................."
cd $OUT #move to output directory
zip -r "$Flash".zip *
echo -e
tar -cv boot.img >> "$Flash".tar
echo -e
tar -tvf "$Flash".tar
echo -e
md5sum -t "$Flash".tar >> "$Flash".tar
echo -e
mv -v "$Flash".tar "$Flash".tar.md5
echo -e
md5sum -t "$Flash".tar.md5

echo
echo "Done"
echo
#build script ends




