# SwiftUI Fluid Motion

An AI skill that makes Claude and GPT write SwiftUI motion that actually
navigates, instead of screens that arrive with no relationship to what you
tapped.

It is a direct translation of [**Family Values**](https://benji.org/family-values)
by [Benji Taylor](https://x.com/benjitaylor), the design principles behind the
Family wallet, into rules an AI model can check before it hands you code. The
thinking is his. This repo turns it into something enforceable.

## The problem

Ask any model for a SwiftUI detail view and the code compiles, uses
`NavigationStack` correctly, and looks fine in a diff. It also has no
`@Namespace`, no transition, no animation of any kind, and no Reduce Motion
handling. The detail view has no relationship to the row that produced it.

The output is not bad. It is undesigned. See
[the real comparison below](#what-actually-changes).

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

**[⬇ Download swiftui-fluid-motion.skill](https://github.com/sudeepkumarg/swiftui-fluid-motion/raw/main/swiftui-fluid-motion.skill)**

That link downloads the file directly. Add it to your Claude account, or drop
this folder into your skills directory. It is also attached to every
[release](https://github.com/sudeepkumarg/swiftui-fluid-motion/releases).

### Claude Code

```bash
git clone https://github.com/sudeepkumarg/swiftui-fluid-motion.git \
  ~/.claude/skills/swiftui-fluid-motion
```

### GPT (Custom GPTs, Projects)

Paste [`for-gpt/system-prompt.md`](for-gpt/system-prompt.md) into your
Instructions field. Upload the files in `references/` as knowledge files.

## How to use

Once installed, you do not invoke it. Ask for SwiftUI the way you normally
would and the rules apply themselves.

**It triggers on** navigation, screen changes, sheets, trays, expand and
collapse, value changes, gesture-driven dismissal, and any `withAnimation` or
`.animation` call. Outside that scope it stays out of the way.

Prompts that work:

```
Build a portfolio list that opens into an asset detail view.

Add a filter tray to this screen.

The balance number updates from a websocket. Make it not look broken.

Review this file's transitions.
```

That last one is the underrated case. Point it at existing code and it audits
against the ten-item checklist rather than writing anything new.

**What you should see change:**

- A `@Namespace` appears, declared at the right level
- `matchedTransitionSource` on the source, `navigationTransition(.zoom:)` on the destination
- Spring tokens by name, never `.easeInOut(duration: 0.3)`
- Exit motion faster than entry
- `contentTransition(.numericText:)` on anything that counts
- A Reduce Motion branch on every custom transition

**If it isn't triggering,** the skill description is the trigger surface. Say
"using the fluid motion rules" once and it will load.

**One habit worth forming:** copy
[`references/motion-tokens.swift`](references/motion-tokens.swift) into your
project on day one. The rules assume `Motion.navigate` and friends exist. Without
the file the model will invent tokens, and you will end up with three versions of
the same spring.

## What actually changes

Real output, not a strawman. The same prompt run twice, once with no skill
loaded and once with it. Full files in [`example/`](example/).

**Prompt:** *"Write a SwiftUI view for an iOS 18 app: a list of crypto assets
where tapping an asset navigates to a detail view showing that asset's balance
and a placeholder chart."*

### Before

```swift
struct AssetListView: View {
    let assets: [CryptoAsset] = CryptoAsset.sampleAssets

    var body: some View {
        NavigationStack {
            List {
                Section("Assets") {
                    ForEach(assets) { asset in
                        NavigationLink(value: asset) {
                            AssetRow(asset: asset)
                        }
                    }
                }
            }
            .navigationDestination(for: CryptoAsset.self) { asset in
                AssetDetailView(asset: asset)
            }
        }
    }
}
```

Correct code. Zero motion decisions. The detail view arrives as a generic push
with no connection to the row that produced it.

### After

```swift
struct AssetListView: View {
    @Namespace private var namespace                       // LAW 1
    let assets: [CryptoAsset] = CryptoAsset.sampleAssets

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text(totalUSDValue, format: .currency(code: "USD"))
                        .font(.largeTitle.bold())
                        .contentTransition(.numericText(value: totalUSDValue))
                        .motion(Motion.feedback, value: totalUSDValue)   // LAW 4
                }

                Section("Assets") {
                    ForEach(assets) { asset in
                        NavigationLink(value: asset) {
                            AssetRow(asset: asset)
                        }
                        .matchedTransitionSource(id: asset.id, in: namespace)   // LAW 1
                    }
                }
            }
            .navigationDestination(for: CryptoAsset.self) { asset in
                AssetDetailView(asset: asset)
                    .navigationTransition(.zoom(sourceID: asset.id, in: namespace))  // LAW 3
            }
        }
    }
}
```

### The diff, itemised

| | Before | After |
|---|---|---|
| Spatial origin | none | `matchedTransitionSource` per row |
| Transition | system default push | zoom out of the tapped row, interactive dismiss back to it |
| Back gesture | edge swipe only | drag the detail down, it returns to its origin |
| Value changes | instant | `numericText`, rolls |
| Motion values | none | named tokens |
| Reduce Motion | unhandled | branched on every custom transition |

Structurally the two files are the same. Every difference is motion.

## What's inside

| File | Purpose |
|---|---|
| `SKILL.md` | The five laws, technique table, and pre-return checklist |
| `references/motion-tokens.swift` | Spring tokens named by intent, plus Reduce Motion helpers |
| `references/patterns.md` | Working implementation of all nine techniques |
| `references/antipatterns.md` | Twelve before/after pairs |
| `example/baseline.swift` | Unedited model output, no skill loaded |
| `example/with-skill.swift` | Same prompt, skill loaded, annotated by law |
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
