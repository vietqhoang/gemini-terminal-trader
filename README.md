# Disclaimer

This is an coding exploratory project. This project is not meant to be used outside of my own use and knowledge building and is not ready (and will never be ready) for the public to use. If you choose to use this project, proceed at your own risk.

# Gemini Trader Terminal

A Ruby client which uses the [Gemini](https://www.gemini.com/) [REST API](https://docs.gemini.com/rest-api/) to place `maker-or-cancel` limit orders on the Gemini Exchange. The currency pairs for orders is limited to `btcusd` and `ethusd`, though trading other currency pairs can be an option.

## Why does the application exist?

Gemini charges much lower transaction fees when the order is made through their API. The goal is to be able to place simple limit orders, taking advantage of the low fee.

At the time of this writing the 30-day fees are the following:

|              | Maker (%) | Taker (%) | Auction (%) | 30 day trading volume ($) | Link                                                                   |
|--------------|-----------|-----------|-------------|---------------------------|------------------------------------------------------------------------|
| ActiveTrader | 0.250     | 0.350     | 0.250       | < 500,000                 | https://www.gemini.com/fees/activetrader-fee-schedule#section-overview |
| API          | 0.100     | 0.350     | 0.200       | < 1,000,000               | https://www.gemini.com/fees/api-fee-schedule#section-overview          |
| Mobile       |           |           |             |                           | https://www.gemini.com/fees/mobile-fee-schedule                        |
| Web          |           |           |             |                           | https://www.gemini.com/fees/web-fee-schedule                           |

I spent way too much time just to save 15 basis points.

Compared to their main competition, Gemini's API taker fees are much lower when transacting low volumes.

|              | Maker (%) | Taker (%) | 30 day trading volume ($) | Link                                                                             |
|--------------|-----------|-----------|---------------------------|----------------------------------------------------------------------------------|
| Bittrex      | 0.350     | 0.350     | < 25,000                  | https://bittrex.zendesk.com/hc/en-us/articles/115000199651-Bittrex-fees          |
| Coinbase Pro | 0.500     | 0.500     | < 10,000                  | https://help.coinbase.com/en/pro/trading-and-funding/trading-rules-and-fees/fees |
| Kraken Pro   | 0.160     | 0.260     | < 50,000                  | https://www.kraken.com/en-us/features/fee-schedule/#kraken-pro                   |

## Installation

1. Install the version of Ruby specificed in the [Gemfile](/Gemfile) using your favorite Ruby management tool.
2. Run `bundle install` to install the dependencies.
3. Create `.env` in the project root. [Populate the file](https://github.com/bkeepers/dotenv#usage) with the API keys. Sandbox details can be found in [Gemini's API documentation](https://docs.gemini.com/rest-api/#sandbox). The naming of the keys are self explanatory.
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

## What is next

* Test suite
* Code clean-up
