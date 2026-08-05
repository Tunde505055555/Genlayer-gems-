# GenLayer Contract Primitives

Two standalone GenLayer Intelligent Contracts, packaged as a **contract-only**
repository: source, tests, docs, examples, and deployment scripts. No web app,
no frontend, no server code.

| Contract | File | Consensus pattern |
| --- | --- | --- |
| AI Web Oracle | [`contracts/price_oracle.py`](contracts/price_oracle.py) | Comparative equivalence with numeric tolerance (±2 %) + partial-field matching |
| Content Moderation | [`contracts/content_moderation.py`](contracts/content_moderation.py) | Non-comparative equivalence: validators grade the leader's verdict against on-chain criteria |

## Layout

```text
contracts/          Intelligent Contract source (deployable as-is)
contracts/tests/    Pytest sketches for the validator / state logic
docs/               Deep-dive on the Equivalence Principle and the two patterns
examples/           Copy-paste deploy + call payloads (JSON args)
scripts/            genlayer CLI deployment scripts
```

## The Equivalence Principle in one paragraph

GenLayer validators must reach consensus on **non-deterministic** results (web
fetches, LLM outputs). A randomly-selected *leader* executes the
non-deterministic block and publishes a result. Every *validator* independently
re-executes the block (or re-evaluates the leader's output against the same
source) and votes accept or reject. The leader's result is written to state only
if a majority agrees; otherwise the network rotates the leader, and if consensus
still fails the transaction goes **undetermined** and state is unchanged. The
hard part is the validator function: it must verify the *substance* of the
answer, not its shape.

## 1. AI Web Oracle — `contracts/price_oracle.py`

Turns any public web page that displays a price into an on-chain feed, without
cooperation from the publisher.

- **Leader**: `gl.nondet.web.render(source_url, mode="text")`, then an LLM
  extracts `{price, currency, confidence, analysis}`.
- **Validator**: re-renders and re-prompts, then accepts iff
  1. `currency` matches exactly,
  2. `price` is within ±2 % (200 bps),
  3. `confidence` is within ±1 on a 0–10 scale,
  4. the reject sentinel (`confidence == 0`) is unanimous.
- Subjective `analysis` is stored but never compared — two LLMs never word
  reasoning identically.
- `confidence == 0` reverts the transaction, so a blank or broken page can never
  silently write a zero price.

State: `pair`, `source_url`, `price_micro` (price × 1e6, avoids floats),
`currency`, `confidence`, `analysis`, `updated_at_block`.

## 2. Content Moderation with Reputation — `contracts/content_moderation.py`

A moderation queue where "is this acceptable?" is a judgment call graded against
written, on-chain guidelines.

- **Leader**: fetches the submitted content and classifies it into
  `ok | warn | remove | ban` with a rationale citing the rules.
- **Validator**: uses `gl.eq_principle.prompt_non_comparative` to judge whether
  the leader's verdict is *defensible* given the same source and criteria — it
  does not generate a competing verdict. This is the right pattern whenever
  several answers are defensible but only one must be picked.
- Accepted verdicts move the author's reputation (`ok +1`, `warn −2`,
  `remove −10`, `ban −50`) as a consensus-backed side effect.

**Authorization model**: `submit(post_id, content_url)` binds the author to
`gl.message.sender_address` — there is no `author` parameter, so no account can
attribute reputation-affecting content to a third party. Each `post_id` is
write-once: an accepted verdict cannot be silently overwritten.

Reputation is stored as an offset from `1_000_000` in a `TreeMap[Address, u256]`
so negative balances are representable without a signed type.

## Deploy

Studio: paste a file into [studio.genlayer.com](https://studio.genlayer.com/),
keep the `# v0.2.16` pragma and the `Depends` line, and deploy with the
constructor args from [`examples/`](examples/).

CLI:

```bash
./scripts/deploy_price_oracle.sh "BTC-USD" "https://example.com/prices/BTC-USD"
./scripts/deploy_content_moderation.sh
```

## Test

```bash
pip install pytest
pytest contracts/tests -v
```

The tests re-implement the validator gates and reputation arithmetic in plain
Python so the consensus rules can be exercised without a live GenVM.

## License

MIT — these primitives are meant to be copied, modified, and shipped.
