echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"
source ~/.profile
echo "-----------------------------------------------------------------------------"
echo "Установка CLI"
echo "-----------------------------------------------------------------------------"
curl -sSL https://raw.githubusercontent.com/soundnesslabs/soundness-layer/main/soundnessup/install | bash
sleep 1

BASE_DIR=$HOME
SOUNDNESS_DIR=${SOUNDNESS_DIR-"$BASE_DIR/.soundness"}
SOUNDNESS_BIN_DIR="$SOUNDNESS_DIR/bin"
PROFILE=$HOME/.profile
echo >> $PROFILE && echo "export PATH=\"\$PATH:$SOUNDNESS_BIN_DIR\"" >> $PROFILE
source ~/.profile

source ~/.bashrc
sleep 3
soundnessup install
echo "Soundnessup CLI установлен"

echo "Генерирую пару ключей | В процессе Вас попросят ввести пароль. Запомните его"
sleep 3
expect <(curl -s https://raw.githubusercontent.com/razumv/trash/refs/heads/main/soundness/generate_key.exp)
sleep 3
echo "Ключи сгенерированы, сохраните мнемоническую фразу"

echo "-----------------------------------------------------------------------------"
echo "Wish lifechange case with DOUBLETOP"
echo "-----------------------------------------------------------------------------"
