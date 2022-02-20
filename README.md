# Gemini Trader Terminal

A Ruby client which uses the [Gemini](https://www.gemini.com/) [REST API](https://docs.gemini.com/rest-api/) to place `maker-or-cancel` limit orders on the Gemini Exchange. The currency pairs for orders is limited to `btcusd` and `ethusd`.
## Why does the application exist?

Gemini charges much lower transaction fees when the order is made through their API.

At the time of this writing the fees are the following:

|              | Maker (%) | Taker (%) | Auction (%) | 30 day trading volume ($) | Link                                                                   |
|--------------|-----------|-----------|-------------|---------------------------|------------------------------------------------------------------------|
| ActiveTrader | 0.250     | 0.350     | 0.250       | < 500,000                 | https://www.gemini.com/fees/activetrader-fee-schedule#section-overview |
| API          | 0.100     | 0.350     | 0.200       | < 1,000,000               | https://www.gemini.com/fees/api-fee-schedule#section-overview          |
| Mobile       |           |           |             |                           | https://www.gemini.com/fees/mobile-fee-schedule                        |
| Web          |           |           |             |                           | https://www.gemini.com/fees/web-fee-schedule                           |

I spent way too much time just to save 15 basis points.

## Installation

1. Install the version of Ruby specificed in the Gemfile using your favorite Ruby management tool.
2. Run `bundle install`.
3. Create `.env` and populate the file with the API keys. Sandbox details can be found in [Gemini's API documentation](https://docs.gemini.com/rest-api/#sandbox).
   1. Add `GEMINI_SANDBOX_API_KEY`
   2. Add `GEMINI_SANDBOX_API_SECRET`
   3. Add `GEMINI_API_KEY`
   4. Add `GEMINI_API_SECRET`

## How to use

Run `ruby ./lib/ruby.rb` in the terminal to start the interactive UI.

![Environment selection screen](/assets/README/01.png)
![Main menu screen](/assets/README/02.png)
![View balances screen](/assets/README/03.png)
![Starting an ethusd order](/assets/README/04.png)
![Selecting a limit price](/assets/README/05.png)
![Confirm order screen](/assets/README/06.png)
![Order placed screen](/assets/README/07.png)
