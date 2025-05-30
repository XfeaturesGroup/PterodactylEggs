#!/bin/bash
INSTALL_DIR="/mnt/server"
GATE_BIN_NAME="gate"
GATE_CONFIG_FILE="config.yml"

cd "${INSTALL_DIR}" || exit 1

echo "Загрузка Gate Proxy..."
if [ "${GATE_VERSION}" == "latest" ]; then
    GATE_RELEASE_URL=$(curl -s https://api.github.com/repos/GateProxy/Gate/releases/latest | grep "browser_download_url.*linux_amd64" | cut -d : -f 2,3 | tr -d \")
else
    GATE_RELEASE_URL=$(curl -s https://api.github.com/repos/GateProxy/Gate/releases/tags/${GATE_VERSION} | grep "browser_download_url.*linux_amd64" | cut -d : -f 2,3 | tr -d \")
fi

if [ -z "${GATE_RELEASE_URL}" ]; then
    echo "Ошибка: Не удалось найти URL для загрузки Gate Proxy версии ${GATE_VERSION}."
    exit 1
fi

wget -O gate.zip "${GATE_RELEASE_URL}"
if [ $? -ne 0 ]; then
    echo "Ошибка: Не удалось загрузить Gate Proxy."
    exit 1
fi

unzip -o gate.zip
if [ $? -ne 0 ]; then
    echo "Ошибка: Не удалось распаковать gate.zip."
    exit 1
fi

rm gate.zip
chmod +x "${GATE_BIN_NAME}"

echo "Генерация базовой конфигурации Gate."
cat << EOF > "${GATE_CONFIG_FILE}"
listen: ":${SERVER_PORT}"
servers:
  default: "${DEFAULT_BACKEND}"
hosts:
  "play.yourdomain.com": "default"
  "default": "default"
onlineMode: true
proxyProtocol: none
logLevel: info
EOF

echo "Установка Gate Proxy завершена."