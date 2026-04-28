# BTC/ETH/SOL Coinbase Public-Data Paper Bot v10

This package is a **paper-trading simulation lab** for BTC, ETH, and SOL.

It uses **Coinbase public market data only**:
- no API keys
- no Coinbase account access
- no real orders
- no withdrawals
- no live trading

It simulates trades, tracks performance, estimates fees/taxes for planning, compares the bot to buy-and-hold benchmarks, and writes CSV files you can inspect.

## Files

```text
btc_eth_sol_coinbase_paper_bot_v10.py  Main paper-trading bot
analyze_bot_performance_v10.py         Performance analyzer
run_btc_bot.sh                        Activates .venv and runs scripts
setup_btc_bot.sh                      Installs/copies files into ~/btc-bot
README.md                             This file
```

## What changed from v9

- v10 adds clearer open-position accounting so you can see whether a loss is from market movement or trading friction.
- The display now separates entry fee, market move P/L before entry fee, open P/L after entry fee, estimated exit fee, net liquidation P/L, and break-even bid.
- The equity log now includes open-position fee and liquidation-estimate columns.
- The analyzer now prints the latest open-position cost breakdown when those columns exist.
- SOL-USD remains included as a default tracked/traded product alongside BTC-USD and ETH-USD.
- v10 uses new log files so it does not overwrite v9 simulations.

## Install on Kali

From the unzipped package folder:

```bash
bash setup_btc_bot.sh
cd ~/btc-bot
```

Check help:

```bash
./run_btc_bot.sh --help
./run_btc_bot.sh btc_eth_sol_coinbase_paper_bot_v10.py --help
./run_btc_bot.sh analyze_bot_performance_v10.py --help
```

## Quick one-cycle test

```bash
./run_btc_bot.sh btc_eth_sol_coinbase_paper_bot_v10.py \
  --once \
  --paper-cash 10000 \
  --trade-size 500 \
  --loss-stop-value 1000
```

## Start a fresh simulation

```bash
./run_btc_bot.sh btc_eth_sol_coinbase_paper_bot_v10.py \
  --reset \
  --paper-cash 10000 \
  --trade-size 500 \
  --loss-stop-value 1000 \
  --poll 60
```

Stop with:

```text
Ctrl+C
```

The bot saves its state before exiting.

## Aggressive $100 paper simulation example

```bash
./run_btc_bot.sh btc_eth_sol_coinbase_paper_bot_v10.py \
  --reset \
  --paper-cash 100 \
  --trade-size 50 \
  --loss-stop-value 50 \
  --daily-profit-lock 25 \
  --idle-cash-apy 0.04 \
  --fee-model conservative \
  --max-spread-pct 0.010 \
  --edge-threshold 45 \
  --min-profit-minutes 5 \
  --quick-profit-pct 0.0015 \
  --poll 60
```

## Recommended realistic simulation

```bash
./run_btc_bot.sh btc_eth_sol_coinbase_paper_bot_v10.py \
  --reset \
  --paper-cash 10000 \
  --trade-size 500 \
  --loss-stop-value 1000 \
  --daily-profit-lock 300 \
  --idle-cash-apy 0.04 \
  --fee-model conservative \
  --max-spread-pct 0.006 \
  --poll 60
```

## Analyze results

After the bot has generated logs:

```bash
./run_btc_bot.sh analyze_bot_performance_v10.py
```

The analyzer reports:
- total P/L
- max drawdown
- fees
- closed-trade win/loss stats
- estimated after-tax P/L
- bot vs BTC buy-and-hold
- bot vs ETH buy-and-hold
- bot vs SOL buy-and-hold
- bot vs equal-weight BTC/ETH/SOL

## Choose products manually

Default v10 products:

```bash
--products BTC-USD,ETH-USD,SOL-USD
```

BTC and ETH only:

```bash
./run_btc_bot.sh btc_eth_sol_coinbase_paper_bot_v10.py \
  --reset \
  --products BTC-USD,ETH-USD \
  --paper-cash 1000 \
  --trade-size 100 \
  --loss-stop-value 200 \
  --poll 60
```

SOL only:

```bash
./run_btc_bot.sh btc_eth_sol_coinbase_paper_bot_v10.py \
  --reset \
  --products SOL-USD \
  --paper-cash 1000 \
  --trade-size 100 \
  --loss-stop-value 200 \
  --poll 60
```

## v10 display cost breakdown

When a position is open, v10 shows extra accounting lines:

```text
Entry fee paid:  $0.30
Market move P/L: $0.00 before entry fee
Open P/L:        $-0.30 after entry fee
Est. exit fee:   $0.30 if sold at current bid
Net liquidation: $-0.60 after entry+exit fees
Break-even bid:  $85.60 | move needed 1.2081%
```

Meaning:

- **Entry fee paid** is the simulated fee already paid to enter.
- **Market move P/L** shows whether the coin price itself has moved in your favor before counting the entry fee.
- **Open P/L** includes the entry fee but does not subtract the future exit fee yet.
- **Estimated exit fee** is the simulated cost to sell right now at the current bid.
- **Net liquidation** estimates what the trade would make/lose if closed immediately after both entry and exit fees.
- **Break-even bid** is the estimated bid price needed to close the trade at roughly $0 net P/L after fees.

For small accounts and conservative fees, it is normal for a trade to start negative immediately after buying.

## Main features

### 1. Buy-and-hold benchmark comparison

The bot records benchmark prices at the start of a fresh simulation and compares the bot against:
- BTC buy-and-hold
- ETH buy-and-hold
- SOL buy-and-hold
- equal-weight tracked-product benchmark

This matters because a bot is only useful if it adds value versus simply holding.

### 2. Fee presets

The bot supports:

```bash
--fee-model conservative
--fee-model custom
--fee-model coinbase-advanced-maker
--fee-model coinbase-advanced-taker
```

Common settings:

```bash
--fee-rate 0.006
--maker-fee-rate 0.004
--taker-fee-rate 0.006
```

`0.006` means 0.60%.

The bot uses bid/ask execution, so conservative/taker-style fees are usually more realistic for short-term simulated trades.

### 3. Spread no-trade filter

```bash
--max-spread-pct 0.006
```

Stops opening new trades if the bid/ask spread is wider than the selected threshold.

### 4. Drawdown risk ladder

The bot automatically becomes more conservative as the simulated account draws down:

```text
3% drawdown: reduce trade size to 75%, add 4 score points
5% drawdown: reduce trade size to 50%, add 8 score points
7% drawdown: reduce trade size to 25%, add 15 score points
10% drawdown: hard halt
```

Options:

```bash
--drawdown-step1-pct 0.03
--drawdown-step2-pct 0.05
--drawdown-step3-pct 0.07
--max-drawdown-pct 0.10
--disable-drawdown-ladder
```

### 5. Daily profit lock

```bash
--daily-profit-lock 300
```

If the bot reaches $300 profit for the UTC day, it stops opening new positions for the rest of that day. Existing positions may still be sold by the risk logic.

### 6. Idle cash yield simulation

```bash
--idle-cash-apy 0.04
```

Simulates 4% annual yield on unused paper cash.

This is not Coinbase yield. It is just a generic paper assumption for cash that might otherwise sit in a money market, T-bills, HYSA, or similar low-risk bucket.

### 7. Tax/capital-gains CSV

The bot writes:

```text
logs/paper_tax_capital_gains_v10.csv
```

Columns include:
- asset
- product_id
- lot_id
- acquire_date_utc
- dispose_date_utc
- quantity
- gross_sell_value_usd
- cost_basis_usd
- proceeds_usd
- gain_loss_usd
- buy_fee_usd
- sell_fee_usd
- total_trade_cost_usd
- estimated_tax_usd
- after_tax_gain_loss_usd

This is a simulated planning aid only, not a tax filing document.

## Log files

```text
~/btc-bot/logs/paper_state_v10.json
~/btc-bot/logs/paper_trades_v10.csv
~/btc-bot/logs/paper_equity_log_v10.csv
~/btc-bot/logs/paper_daily_pnl_v10.csv
~/btc-bot/logs/paper_tax_capital_gains_v10.csv
~/btc-bot/logs/paper_research_log_v10.csv
```

## What is the JSON file?

```text
logs/paper_state_v10.json
```

This is the bot's saved simulation memory.

It stores:
- current paper cash
- open BTC/ETH/SOL positions
- entry prices
- lot IDs
- cost basis
- realized P/L
- cash yield totals
- daily lock status
- benchmark starting prices
- kill-switch state

If you stop and restart without `--reset`, the bot continues the same simulation.

Use `--reset` to start over.

## View files

```bash
column -s, -t logs/paper_trades_v10.csv | less -S
column -s, -t logs/paper_daily_pnl_v10.csv | less -S
column -s, -t logs/paper_tax_capital_gains_v10.csv | less -S
column -s, -t logs/paper_equity_log_v10.csv | less -S
```

## Security rules

- Do not paste Coinbase API keys into ChatGPT.
- This bot does not require API keys.
- Do not give any future bot withdrawal permissions.
- Do not treat paper results as proof a live system will be profitable.

## Terminal color

The live `Score:` line prints in red so it is easier to find while the bot is running.

Disable color if needed:

```bash
./run_btc_bot.sh btc_eth_sol_coinbase_paper_bot_v10.py --no-color --once
```
# PaperCryptoTradingBot
