# MoMo Wallet

A mobile money wallet app: receive money, send money by phone number, and cash out at an agent with an exact note breakdown. My data is now saved on the phone with shared_preferences, so nothing is lost when the app closes, and it shows the live USD → RWF exchange rate from the open.er-api.com API.

## Features
- Wallet starts at 10,000 RWF with sample transactions, newest first.
- Filter transactions by All / IN / OUT.
- Receive money: description + amount, amount must be a whole number above 0.
- Send money: phone number must be exactly 10 digits starting with 078 or 079, amount at least 100 RWF, refused if it would overdraw the balance.
- Cash out: amount must be a multiple of 100 RWF; shows the exact agent notes (5000, 2000, 1000, 500, 100) before confirming.
- Statistics: total IN, total OUT, and the lowest balance ever reached.
- Delete a transaction with Undo; a delete is refused if it would ever make the balance go negative.
- Data persists with `shared_preferences` across app restarts.
- Live USD → RWF exchange rate card with loading, error, and Retry states.

## Screenshots
![Before closing](screenshots/before.png)
![After running again](screenshots/after.png)
![Live data from an API](screenshots/api.png)
![No internet](screenshots/no-internet.png)

## Think (answers)

**MoMo Wallet**

1. Why must every check happen before any money moves? What would go wrong if one check came after?
   (answer here)

2. Your lowest-balance statistic needs a starting value. What did you start it at, and why not 0?
   (answer here)

## Project structure
```
lib/
  models/transaction.dart      # MomoTransaction model + JSON (de)serialization
  logic/wallet_engine.dart     # all business rules, outside the widget tree
  data/wallet_store.dart       # shared_preferences persistence
  data/exchange_rate.dart      # live API call
  screens/wallet_screen.dart   # main screen: balance, stats, list, filters
  screens/receive_screen.dart
  screens/send_screen.dart
  screens/cash_out_screen.dart
  screens/exchange_rate_card.dart
  main.dart
```
