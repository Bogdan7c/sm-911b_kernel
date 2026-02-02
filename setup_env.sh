#!/bin/bash

# 1. ОПРЕДЕЛЕНИЕ КОРНЯ ПРОЕКТА
# Это самое важное: скрипт понимает, где он лежит (в GitHub Actions или у тебя на ПК)
export ANDROID_BUILD_TOP=$(pwd)
echo "Setting build root to: $ANDROID_BUILD_TOP"

# 2. НАСТРОЙКИ УСТРОЙСТВА (S23 / Kalama)
export BUILD_TARGET=dm1q_eur_openx
export MODEL=dm1q
export PROJECT_NAME=dm1q
export CHIPSET_NAME=kalama
export TARGET_PRODUCT=gki
export TARGET_BOARD_PLATFORM=gki

# 3. ПУТИ К ВЫХОДНЫМ ФАЙЛАМ (Куда класть готовое ядро)
# Samsung использует папку out/ внутри корня. Мы повторяем эту логику.
export OUT_DIR="${ANDROID_BUILD_TOP}/out/msm-kernel-${CHIPSET_NAME}-${TARGET_PRODUCT}"
export ANDROID_PRODUCT_OUT="${ANDROID_BUILD_TOP}/out/target/product/${MODEL}"

# Создаем эти папки заранее, чтобы скрипты не ругались
mkdir -p "$OUT_DIR"
mkdir -p "$ANDROID_PRODUCT_OUT"

# 4. ЛЕЧЕНИЕ "KBUILD_EXTRA_SYMBOLS" (Та самая проблема из README)
# Мы указываем компилятору искать символы модулей (экран, память) в НАШЕЙ папке out,
# а не в /home/dpi/...
# Обрати внимание: эти файлы (Module.symvers) появятся там в процессе сборки,
# но переменная должна указывать на них заранее.

export KBUILD_EXTRA_SYMBOLS="${OUT_DIR}/vendor/qcom/opensource/mmrm-driver/Module.symvers \
${OUT_DIR}/vendor/qcom/opensource/mm-drivers/hw_fence/Module.symvers \
${OUT_DIR}/vendor/qcom/opensource/mm-drivers/sync_fence/Module.symvers \
${OUT_DIR}/vendor/qcom/opensource/mm-drivers/msm_ext_display/Module.symvers \
${OUT_DIR}/vendor/qcom/opensource/securemsm-kernel/Module.symvers"

# 5. НАСТРОЙКИ МОДУЛЕЙ (Камера, Аудио, Дисплей)
# Здесь пути относительные (начинаются с ../), их Samsung прописал нормально,
# но на всякий случай явно задаем их.
export KBUILD_EXT_MODULES="../vendor/qcom/opensource/mm-drivers/msm_ext_display \
../vendor/qcom/opensource/mm-drivers/sync_fence \
../vendor/qcom/opensource/mm-drivers/hw_fence \
../vendor/qcom/opensource/mmrm-driver \
../vendor/qcom/opensource/securemsm-kernel \
../vendor/qcom/opensource/display-drivers/msm \
../vendor/qcom/opensource/audio-kernel \
../vendor/qcom/opensource/camera-kernel"

# 6. НАСТРОЙКА ТУЛЧЕЙНА (Компилятора)
# Указываем, где искать Clang. В GitHub Actions мы скачаем его именно сюда.
export CLANG_PATH="${ANDROID_BUILD_TOP}/kernel_platform/prebuilts/clang/host/linux-x86/clang-r487747c"
export PATH="${CLANG_PATH}/bin:$PATH"

echo "Environment setup complete. Ready to build."
