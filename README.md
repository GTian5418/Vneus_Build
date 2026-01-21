```bash
curl https://storage.googleapis.com/git-repo-downloads/repo > /usr/bin/repo
chmod a+x /usr/bin/repo

.repo/local_manifests/roomservice.xml

<?xml version="1.0" encoding="UTF-8"?>
<manifest>
  <remote name="gitlab" fetch="ssh://git@gitlab.com" revision="lineage-23.1" />
  <project path="packages/apps/Bellis" name="CalyxOS/platform_packages_apps_Bellis" revision="staging/android16" />
  <project path="device/xiaomi/sm8350-common" name="xiaomi-lisa-devs/android_device_xiaomi_sm8350-common" />
  <project path="device/xiaomi/venus" name="xiaomi-lisa-devs/android_device_xiaomi_venus" />
  <project path="hardware/xiaomi" name="LineageOS/android_hardware_xiaomi" />
  <project path="kernel/xiaomi/sm8350" name="xiaomi-lisa-devs/android_kernel_qcom_sm8350" />
  <project path="vendor/xiaomi/sm8350-common" name="xiaomi-lisa-devs/proprietary_vendor_xiaomi_sm8350-common" />
  <project path="vendor/xiaomi/venus" name="xiaomi-lisa-devs/proprietary_vendor_xiaomi_venus" />
  <project path="vendor/extra" name="itsvixano-dev/android/lineageos-personal/android_vendor_extra" remote="gitlab" revision="main" />
  <project path="vendor/firmware" name="itsvixano-dev/android/lineageos-personal/proprietary_vendor_firmware" remote="gitlab" revision="main" />
  <project path="vendor/lineage-priv/keys" name="GTian5418/android_vendor_lineage-priv_keys" />
</manifest>

sync

#!/bin/bash
# Var
BRANCH=lineage-23.1
# Sync & cleanup LineageOS repos
repo init -u git@github.com:LineageOS/android.git --depth=1 -b ${BRANCH} --git-lfs -g default,-notdefault,-infra --no-clone-bundle
repo forall -j$(nproc) -c 'git add . &>/dev/null; git stash &>/dev/null; git rebase --abort &>/dev/null; git reset --hard $(git rev-list --max-parents=0 HEAD) &>/dev/null; git clean -fd &>/dev/null; git checkout --detach HEAD &>/dev/null' || true
repo sync -j$(nproc) -c --detach --force-sync --force-remove-dirty --no-tags --no-clone-bundle --retry-fetches=5  --jobs-checkout=$(nproc) --optimized-fetch --prune
yes "y" | repo gc &>/dev/null
# Apply patches from gerrit
./picks
# Apply personal patches
APPLY_PATCHES=true . build/envsetup.sh




picks
#!/bin/bash
function repopick() {
    vendor/lineage/build/tools/repopick.py $@
}
# device/lineage/sepolicy
repopick 458893 # sepolicy: label more sched sysctl toggles
# frameworks/base
changes=(
    468424 # PhoneWindowManager: Fix settings not applied on boot for device key actions
    468425 # PhoneWindowManager: Use SingleKeyRule for app switch long press
    460355 # Don't pass repeated back key events to app if custom action is set up
    460409 # fw/b: Allow customisation of navbar app switch long press action
    460417 # toast: fix bg color not changing with theme change
    466477 # SystemUI: Bring back good ol' circle battery style once again
    466846 # fixup! Firewall: Transport-based toggle support (1/3)
)
repopick ${changes[@]}
## Topics
repopick -t piloti
wait



build_release
#!/bin/bash
## Devices
declare -A platforms=(
    [v]="venus"

)
## Select devices
devices=()
for platform in "$@"; do
    if [[ -n "${platforms[$platform]}" ]]; then
        devices+=( ${platforms[$platform]} )
    else
        echo "Invalid platform specified: $platform"
        exit 1
    fi
done
## Sync
./sync
## Build
. build/envsetup.sh

for device in "${devices[@]}"; do
    LOGI "Build for ${device}"
    sleep 3
    if ! mka_build --device "${device}"; then
        exit 1
    fi
    if ! release_build "${device}"; then
        exit 1
    fi
done



repo forall -c 'git lfs pull'  || true

#!/bin/bash

# 定义版本号（建议使用日期）
TAG_NAME="LineageOS-23.1-$(date +'%Y%m%d')"
REPO="GTian5418/Vneus_Build"

echo "开始创建 Release: ${TAG_NAME}..."

# 1. 创建 Release 草稿
gh release create "$TAG_NAME" \
    --repo "$REPO" \
    --title "LineageOS 23.1 for venus (小米11) - $(date +'%Y-%m-%d')" \
    --notes "Android 16 Unofficial build. 包括完整签名包和底层驱动分区镜像。"

# 2. 上传核心 ZIP 包
echo "上传签名包..."
gh release upload "$TAG_NAME" lineage-23.1-venus-SIGNED.zip --repo "$REPO"

# 3. 批量上传有内容的核心镜像 (排除那些 131 字节的占位符)
echo "过滤并上传有效镜像..."
for img in *.img; do
    # 检查文件大小是否大于 1MB (防止上传 131 字节的占位镜像)
    if [ $(stat -c%s "$img") -gt 1048576 ]; then
        echo "正在上传有效镜像: $img"
        gh release upload "$TAG_NAME" "$img" --repo "$REPO"
    fi
done

echo "上传完成！"


gh release upload "LineageOS-23.1-20260120" lineage-23.1-20260120-UNOFFICIAL-venus.zip --repo "GTian5418/Vneus_Build"	



cd packages/modules/NetworkStack/res/values/
sed -i 's|http://connectivitycheck.gstatic.com/generate_204|http://connect.rom.miui.com/generate_204|g' config.xml
sed -i 's|https://www.google.com/generate_204|https://connect.rom.miui.com/generate_204|g' config.xml
sed -i 's|http://www.google.com/gen_204|http://connectivitycheck.platform.hicloud.com/generate_204|g' config.xml
sed -i 's|http://play.googleapis.com/generate_204|http://connectivitycheck.platform.hicloud.com/generate_204|g' config.xml
cd -
cd frameworks/base/core/res/res/values/
sed -i '/name="config_ntpServer"/s/>.*</>ntp.aliyun.com</' config.xml
sed -i '/name="config_ntpPollingInterval"/s/>.*</>12000000</' config.xml
sed -i '/name="config_ntpPollingIntervalShorter"/s/>.*</>6000</' config.xml
```