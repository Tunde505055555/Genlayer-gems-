# AI Web Oracle — example usage

## Constructor args

```json
["BTC-USD", "https://www.coingecko.com/en/coins/bitcoin"]
```

| Arg | Type | Meaning |
| --- | --- | --- |
| `pair` | `str` | Label for the feed, e.g. `BTC-USD` |
| `source_url` | `str` | Public page that displays the price |

## Calls

Refresh the feed (write, runs the equivalence principle):

```json
{ "method": "refresh", "args": [] }
```

Read the current state (view, free):

```json
{ "method": "get_price", "args": [] }
```

Example response:

```json
{
  "pair": "BTC-USD",
  "source_url": "https://www.coingecko.com/en/coins/bitcoin",
  "price_micro": 67123450000,
  "currency": "USD",
  "confidence": 8,
  "analysis": "Mid price read from the primary quote block.",
  "updated_at_block": 0
}
```

Divide `price_micro` by `1_000_000` to get the human price.

Owner-only: repoint the feed.

```json
{ "method": "set_source", "args": ["ETH-USD", "https://www.coingecko.com/en/coins/ethereum"] }
```

## Consensus outcomes

| Situation | Result |
| --- | --- |
| Validator prices within 2 % | accepted, state updated |
| Validator price drifts > 2 % | rejected, leader rotated |
| Page shows no price (`confidence = 0`) | transaction reverts, state unchanged |
