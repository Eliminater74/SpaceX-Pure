#!/system/bin/sh

mount -o remount,rw /system

# Inject SuperSU
if [ ! -f /system/xbin/su ]; then
	# Make necessary folders
	mkdir /system/etc/init.d
	mkdir /system/app/SuperSU

	# Extract SU from ramdisk to correct locations
	rm -rf /system/bin/app_process
	rm -rf /system/bin/install-recovery.sh
	cp /sbin/su/supolicy /system/xbin/
	cp /sbin/su/su /system/xbin/
	cp /sbin/su/libsupol.so /system/lib64/
	cp /sbin/su/install-recovery.sh /system/etc/
	cp /sbin/su/SuperSU.apk /system/app/SuperSU/
	cp /sbin/su/99SuperSUDaemon /system/etc/init.d/

	# Begin SuperSU install process
	cp /system/xbin/su /system/xbin/daemonsu
	cp /system/xbin/su /system/xbin/sugote
	cp /system/bin/sh /system/xbin/sugote-mksh
	mkdir -p /system/bin/.ext
	cp /system/xbin/su /system/bin/.ext/.su

	cp /system/bin/app_process64 /system/bin/app_process_init
	mv /system/bin/app_process64 /system/bin/app_process64_original

	echo 1 > /system/etc/.installed_su_daemon

	chmod 755 /system/xbin/su
	chmod 755 /system/xbin/daemonsu
	chmod 755 /system/xbin/sugote
	chmod 755 /system/xbin/sugote-mksh
	chmod 755 /system/xbin/supolicy
	chmod 777 /system/bin/.ext
	chmod 755 /system/bin/.ext/.su
	chmod 755 /system/bin/app_process_init
	chmod 755 /system/bin/app_process64_original
	chmod 644 /system/lib64/libsupol.so
	chmod 755 /system/etc/install-recovery.sh
	chmod 644 /system/etc/.installed_su_daemon
	chmod 755 /system/app/SuperSU
	chmod 644 /system/app/SuperSU/SuperSU.apk
	
	ln -s /system/etc/install-recovery.sh /system/bin/install-recovery.sh
	ln -s /system/xbin/daemonsu /system/bin/app_process
	ln -s /system/xbin/daemonsu /system/bin/app_process64

	/system/xbin/su --install
fi

# Inject Busybox if not present
if [ ! -f /system/xbin/busybox ]; then
	cp /sbin/busybox /system/xbin/
	chmod 755 /system/xbin/busybox
	/system/xbin/busybox --install -s /system/xbin
fi
	
# Private Mode fix
if [ ! -f /system/priv-app/PersonalPageService/PersonalPageService_Fix.apk ]; then
	rm -f /system/priv-app/PersonalPageService/*
	rm -fR /system/priv-app/PersonalPageService/*
	cp -f /sbin/su/PersonalPageService_Fix.apk /system/priv-app/PersonalPageService/
	chmod 0644 /system/priv-app/PersonalPageService/PersonalPageService_Fix.apk
fi
	
# Kill securitylogagent
rm -fR /system/app/SecurityLogAgent
rm -fR /system/priv-app/KLMSAgent
rm -fR /system/app/*Knox*
rm -fR /system/app/*KNOX*
rm -fR /system/container
rm -fR /system/app/Bridge
rm -fR /system/app/BBCAgent
rm -fR /system/priv-app/FotaClient
rm -fR /system/priv-app/SyncmIDM
rm -fR /system/priv-app/*FWUpdate*


# SQLite 
if [ ! -f /system/etc/init.d/99sqlite ]; then
	cp -f /sbin/su/99sqlite /system/etc/init.d/
	cp -f /sbin/su/sqlite3 /system/xbin/
	cp -f /sbin/su/fstrim /system/xbin/
	chmod 755 /system/xbin/sqlite3
	chmod 755 /system/xbin/fstrim
fi	
	
# Enforce init.d script perms on any post-root added files
chmod 755 /system/etc/init.d
chmod 755 /system/etc/init.d/*

# Run init.d scripts
mount -t rootfs -o remount,rw rootfs
run-parts /system/etc/init.d

# Deep sleep fix
if [ ! -d /system/su.d ]; then
	mkdir /system/su.d
	chmod 0700 /system/su.d
	if [ ! -f /system/su.d/000000deepsleep ]; then
		cp -f /sbin/su/000000deepsleep /system/su.d/
		chmod 0700 /system/su.d/000000deepsleep
	fi
	/system/bin/reboot
fi

# Fix gapps wakelock
sleep 40
su -c "pm enable com.google.android.gms/.update.SystemUpdateActivity"
su -c "pm enable com.google.android.gms/.update.SystemUpdateService"
su -c "pm enable com.google.android.gms/.update.SystemUpdateService$ActiveReceiver"
su -c "pm enable com.google.android.gms/.update.SystemUpdateService$Receiver"
su -c "pm enable com.google.android.gms/.update.SystemUpdateService$SecretCodeReceiver"
su -c "pm enable com.google.android.gsf/.update.SystemUpdateActivity"
su -c "pm enable com.google.android.gsf/.update.SystemUpdatePanoActivity"
su -c "pm enable com.google.android.gsf/.update.SystemUpdateService"
su -c "pm enable com.google.android.gsf/.update.SystemUpdateService$Receiver"
su -c "pm enable com.google.android.gsf/.update.SystemUpdateService$SecretCodeReceiver"

sync
