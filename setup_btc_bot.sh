#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="$HOME/btc-bot"
SRC_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$TARGET_DIR/logs"

copy_if_different() {
    local src="$1"
    local dst="$2"
    if [[ ! -f "$src" ]]; then
        echo "Skipping missing file: $src"
        return
    fi
    if [[ "$(realpath "$src")" == "$(realpath -m "$dst")" ]]; then
        echo "Already in place: $(basename "$dst")"
        return
    fi
    cp "$src" "$dst"
    echo "Copied: $(basename "$dst")"
}

copy_if_different "$SRC_DIR/btc_eth_sol_coinbase_paper_bot_v10.py" "$TARGET_DIR/btc_eth_sol_coinbase_paper_bot_v10.py"
copy_if_different "$SRC_DIR/analyze_bot_performance_v10.py" "$TARGET_DIR/analyze_bot_performance_v10.py"
copy_if_different "$SRC_DIR/run_btc_bot.sh" "$TARGET_DIR/run_btc_bot.sh"
copy_if_different "$SRC_DIR/README.md" "$TARGET_DIR/README_v10.md"

cd "$TARGET_DIR"

if [[ ! -d ".venv" ]]; then
    python3 -m venv .venv
    echo "Created virtual environment: $TARGET_DIR/.venv"
else
    echo "Virtual environment already exists: $TARGET_DIR/.venv"
fi

source .venv/bin/activate
python -m pip install --upgrade pip setuptools wheel
python -m pip install requests pandas numpy

chmod +x btc_eth_sol_coinbase_paper_bot_v10.py analyze_bot_performance_v10.py run_btc_bot.sh

echo "Setup complete."
echo "Bot folder: $TARGET_DIR"
echo
cat <<'EOH'
Try:
  cd ~/btc-bot
  ./run_btc_bot.sh --help
  ./run_btc_bot.sh btc_eth_sol_coinbase_paper_bot_v10.py --help
  ./run_btc_bot.sh btc_eth_sol_coinbase_paper_bot_v10.py --once --paper-cash 10000 --trade-size 500 --loss-stop-value 1000
  ./run_btc_bot.sh analyze_bot_performance_v10.py
EOH
