# swiftui-fluid-motion

An AI skill that makes Claude and GPT write SwiftUI motion that actually
navigates, instead of screens that cross-fade into each other.

It is a direct translation of [**Family Values**](https://benji.org/family-values)
by [Benji Taylor](https://x.com/benjitaylor), the design principles behind the
Family wallet, into rules an AI model can check before it hands you code. The
thinking is his. This repo turns it into something enforceable.

## The problem

Ask any model for a SwiftUI detail view and you get `.sheet(isPresented:)` with
no transition, `.easeInOut(duration: 0.3)` on every interaction, and magic
numbers scattered across twelve files. It compiles. It also feels like nothing
was designed.

## What this does

Five laws, each one checkable:

1. **Give every screen change a spatial origin.** A view appears from something
   the user just touched. No named source means the transition is wrong.
2. **Use springs for anything the user touches.** Timing curves are for looping,
   non-interactive motion only.
3. **Encode hierarchy in direction.** Forward is deeper. Back reverses the exact
   path in.
4. **Animate state, and keep it interruptible.** Interrupted motion reverses
   from its current position and velocity. It does not snap and restart.
5. **Branch on Reduce Motion.** A missing fallback is a shipped bug.

Plus a ten-item checklist the model runs against its own output before
returning, a spring token set named by intent rather than number, and twelve
before/after antipattern pairs.

## Install

### Claude (skills)

Download [`swiftui-fluid-motion.skill`](swiftui-fluid-motion.skill) and add it
to your Claude account, or drop this folder into your skills directory.

### Claude Code

```bash
git clone https://github.com/sudeepkumarg/swiftui-fluid-motion.git \
  ~/.claude/skills/swiftui-fluid-motion
```

### GPT (Custom GPTs, Projects)

Paste [`for-gpt/system-prompt.md`](for-gpt/system-prompt.md) into your
Instructions field. Upload the files in `references/` as knowledge files.

## What's inside

| File | Purpose |
|---|---|
| `SKILL.md` | The five laws, technique table, and pre-return checklist |
| `references/motion-tokens.swift` | Spring tokens named by intent, plus Reduce Motion helpers |
| `references/patterns.md` | Working implementation of all nine techniques |
| `references/antipatterns.md` | Twelve before/after pairs |
| `for-gpt/system-prompt.md` | Same rules, formatted for GPT |

## Requirements

iOS 18 and later. `navigationTransition(.zoom:)` and `matchedTransitionSource`
are iOS 18 APIs. Spring presets, `numericText`, and `PhaseAnimator` need iOS 17.
Below iOS 18 the skill substitutes `matchedGeometryEffect` and says so, rather
than degrading silently.

## A caveat worth reading

The reference code was written against the API surface and reviewed by hand, not
compiled. Build it once before you trust it. If you hit something that does not
compile, open an issue and I will fix it.

## Contributing

Useful contributions, roughly in order:

- Compile fixes for the reference code
- Additional antipattern pairs you have hit in real projects
- A React or Jetpack Compose variant of the same five laws
- Evidence that a rule is wrong. That is the most valuable kind of issue.

## Credit

Every idea in here traces back to [Family Values](https://benji.org/family-values)
by [Benji Taylor](https://x.com/benjitaylor). If this repo is useful to you, read
the original. It is better than my summary of it.

## License

MIT. See [LICENSE](LICENSE).
