# Content Moderation — example usage

## Constructor args

```json
["R1: No harassment or targeted abuse.\nR2: No spam or unsolicited advertising.\nR3: No doxxing or sharing private information.\nR4: No illegal content."]
```

A single `guidelines` string. Rule ids make validator grading much sharper —
the criteria require the rationale to cite the rules actually violated.

## Calls

Submit **your own** post for moderation (write, runs the equivalence principle):

```json
{ "method": "submit", "args": ["post-001", "https://example.com/posts/1"] }
```

The author is taken from `gl.message.sender_address`. There is deliberately no
`author` argument, and `post_id` is write-once.

Read a moderated post (view):

```json
{ "method": "get_post", "args": ["post-001"] }
```

```json
{
  "id": "post-001",
  "author": "0xabc...",
  "content_url": "https://example.com/posts/1",
  "verdict": "warn",
  "rationale": "Borderline personal attack under R1; not severe enough to remove."
}
```

Read reputation (view, returns a signed integer):

```json
{ "method": "reputation_of", "args": ["0xabc..."] }
```

Owner-only: replace the guidelines.

```json
{ "method": "set_guidelines", "args": ["R1: ...\nR2: ..."] }
```

## Reputation deltas

| Verdict | Delta |
| --- | --- |
| `ok` | +1 |
| `warn` | −2 |
| `remove` | −10 |
| `ban` | −50 |
