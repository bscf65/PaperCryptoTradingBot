#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/btc-bot"

echo "Checking Git status..."
git status --short

echo
echo "Adding safe project files..."

git add \
  .gitignore \
  README.md \
  run_btc_bot.sh \
  setup_btc_bot.sh \
  *.py \
  configs/*.json

# Add docs only if it exists
if [[ -d "docs" ]]; then
  git add docs
fi

echo
echo "Checking what will be committed..."
git status --short

echo
echo "Safety check: making sure private files are not staged..."

if git diff --cached --name-only | grep -E '(^logs/|\.venv/|paper_state_|paper_trades_|paper_daily_pnl_|paper_tax_capital_gains_|paper_equity_log_)'; then
  echo
  echo "ERROR: Private/generated files are staged. Aborting."
  echo "Run: git restore --staged <file>"
  exit 1
fi

if git diff --cached --quiet; then
  echo
  echo "Nothing new to commit."
  exit 0
fi

echo
read -rp "Commit message: " COMMIT_MSG

if [[ -z "$COMMIT_MSG" ]]; then
  COMMIT_MSG="Update crypto paper trading bot"
fi

git commit -m "$COMMIT_MSG"

echo
echo "Pushing to GitHub..."
git push

echo
echo "Done. Final status:"
git status --short
