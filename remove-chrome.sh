#!/usr/bin/env bash
set -euo pipefail

package="com.android.chrome"

command -v adb >/dev/null || { echo "adb missing. install android-tools)."; exit 1; }

device_count=$(adb devices | awk 'NR>1 && $2=="device"' | wc -l)
if [ "$device_count" -ne 1 ]; then
    echo "need exactly 1 authorized device, found $device_count. enable USB debugging and accept prompt."
    exit 1
fi

if ! adb shell pm list packages | grep -qx "package:$package"; then
    echo "chrome already gone."
    exit 0
fi

adb shell am force-stop "$package"
adb shell pm clear "$package" || true
adb shell pm uninstall --user 0 "$package"

if adb shell pm list packages | grep -qx "package:$package"; then
    echo "failed to remove chrome."
    exit 1
fi
echo "chrome removed."
