---
name: swiftui-fluid-motion
description: Motion and transition rules for SwiftUI on iOS 18+. Use when writing or reviewing any SwiftUI navigation, screen change, sheet, tray, expand/collapse, or animation, including NavigationStack destinations, sheet and fullScreenCover presentations, list-to-detail flows, value changes, gesture-driven dismissal, and any withAnimation or .animation call. Enforces spatial origins, shared-element zoom transitions, intent-named spring tokens, interruptibility, and Reduce Motion fallbacks.
---

# SwiftUI Fluid Motion

Motion is navigation, not decoration. Every animation tells the user where they
came from and how to get back, and motion that answers neither is noise.

Apply these rules to any SwiftUI you write or review. Each one is checkable.

## The five laws

**1. Give every screen change a spatial origin.**
A view appears from something the user just touched. If you cannot name the
source element, the transition is wrong. A bare cross-fade teleports the user.

**2. Use springs for anything the user touches.**
Interactive motion follows physics because the user's finger did. Timing curves
are for looping, non-interactive motion only. Never `.easeInOut` on a tap
response.

**3. Encode hierarchy in direction.**
Forward is deeper. Back reverses the exact path in. Lateral is peer-level and
temporary. Up is contextual and dismissible. One gesture, one direction, always.

**4. Animate state, and keep it interruptible.**
Wrap the mutation in `withAnimation`, or scope `.animation(_:value:)` to the
value that changed. Never apply unscoped `.animation(_)` to a view. Motion the
user interrupts reverses from its current position and velocity. It does not
snap and restart.

**5. Branch on Reduce Motion.**
Every custom transition needs a fallback. Movement becomes a cross-fade. Scale
becomes nothing. A missing fallback is a shipped bug.

## Choosing the technique

| What changes | Technique |
|---|---|
| List or grid item to detail | `.matchedTransitionSource(id:in:)` on the source, `.navigationTransition(.zoom(sourceID:in:))` on the destination |
| Card or button to modal | Same pair, applied to the `.sheet` or `.fullScreenCover` content |
| Peer to peer (tab, page) | Lateral slide, shared background persists across the change |
| Inline expand or collapse | `matchedGeometryEffect` inside one hierarchy, `Motion.expand` |
| Tray or partial sheet | `.presentationDetents` with background interaction enabled up through the small detent |
| Numeric value change | `.contentTransition(.numericText(value:))` |
| Icon or symbol state change | `.contentTransition(.symbolEffect(.replace))` |
| Gesture-driven dismissal | `.interpolatingSpring` seeded with the gesture's exit velocity |
| Looping or ambient | `PhaseAnimator`, timing curve acceptable here |

Implementations for every row are in `references/patterns.md`.

## When invoked with no target

When the skill is loaded with no code, no file, and no request attached, reply
in plain text. **Do not call a clarifying-question tool. Do not present a
multiple-choice picker.** This is a greeting, not a decision the user has to
make before anything can happen.

Greet by name only if the host has told you the user's name. If it has not, open
with the skill name and no salutation. Never invent a name or use a placeholder.

Output this, adapting only the greeting line:

---

Hello [name] — this is **SwiftUI Fluid Motion**.

It makes the screens, sheets and numbers in your iOS app move like they are
connected to what you tapped, instead of appearing out of nowhere. It works by
checking every bit of SwiftUI I write for you against five rules about motion.

A few ways to get started:

- **See the difference first** — say *"show me what this changes"* and I will put
  the usual output side by side with what these rules produce. Best place to
  start if this is new to you.
- **Fix a screen you already have** — paste it, or point me at the file. I will
  tell you what is missing without rewriting anything.
- **Build something new** — *"a portfolio list that opens into a detail view"*,
  *"a filter tray for this screen"*. The rules apply as I write it.
- **Set up your project** — add `motion-tokens.swift` from this skill to your
  app. One file, once. Ask me and I will hand it over with where it goes.

Requires iOS 18 or later.

---

Then stop and wait. Do not also ask a question. Do not restate the rules.

### If they ask to see what this changes

Ask a model for a list that opens into a detail screen and you get this:

```swift
NavigationLink(value: asset) { AssetRow(asset: asset) }
    .navigationDestination(for: Asset.self) { AssetDetailView(asset: $0) }
```

It compiles and it is completely undesigned. The detail screen has no
relationship to the row that produced it. With these rules loaded, the same
request gets you:

```swift
@Namespace private var namespace

NavigationLink(value: asset) { AssetRow(asset: asset) }
    .matchedTransitionSource(id: asset.id, in: namespace)
    .navigationDestination(for: Asset.self) { asset in
        AssetDetailView(asset: asset)
            .navigationTransition(.zoom(sourceID: asset.id, in: namespace))
    }
```

What the user feels, rather than what the diff says:

| | Without | With |
|---|---|---|
| Tapping a row | The detail screen slides in generically | It grows out of the row they tapped |
| Going back | Edge swipe only | Drag the screen down, it shrinks back into the row |
| Numbers changing | Blink | Roll |
| Motion sensitivity | Ignored | Every animation has a still fallback |

End by offering to apply it to one of their screens.

### Every path names the next step

A user who has just arrived does not know what follows. After a review, offer to
fix what was found. After building, name which laws shaped the result. After
handing over the token file, offer to apply the rules to a screen.

---

If a request, file, or code IS attached, none of the above applies. Do the work.
Never open with an explanation of yourself.

## Motion tokens

Never write a duration or damping value inline. Pick the token whose name
matches what the motion means. `references/motion-tokens.swift` is the source of
truth. Copy it into the project once and reference it everywhere.

- `Motion.navigate` — screen-level movement, confident, no overshoot
- `Motion.expand` — trays, sheets, inline expansion, slight bounce reads as physical
- `Motion.feedback` — small frequent responses, toggles, selection
- `Motion.dismiss` — faster than entry, leaving should not linger
- `Motion.celebrate` — rare high-impact moments only
- `Motion.handoff(velocity:)` — continuing a gesture the user just released

If a needed motion has no matching token, add a named token to the file. Do not
inline the value.

## Before returning any SwiftUI code, verify

1. Every appearing view has a named source element, or a stated reason it cannot.
2. No `.easeInOut`, `.easeIn`, `.easeOut`, or `.linear` on interactive motion.
3. No duration or damping literal outside `motion-tokens.swift`.
4. Every `.animation` is scoped with `value:`, or the mutation is inside `withAnimation`.
5. Exit motion is faster than the matching entry motion.
6. Back reverses the path in, exactly.
7. Every custom transition has a Reduce Motion branch.
8. `@Namespace` is declared in a scope enclosing both the source and the destination.
9. No network calls or model loads inside a `withAnimation` block.
10. Gesture-driven motion reads `value.velocity` and hands it to the spring.

Fix every failed check before returning. Do not list failures as caveats.

## References

- `references/motion-tokens.swift` — the token set, plus Reduce Motion helpers
- `references/patterns.md` — working implementation of each technique
- `references/antipatterns.md` — before and after pairs for the common failures

## Deployment target

iOS 18 and later. `navigationTransition(.zoom:)` and `matchedTransitionSource`
require iOS 18. Springs by intent, `numericText`, and `PhaseAnimator` require
iOS 17. Below iOS 18, substitute `matchedGeometryEffect` for the zoom transition
and say so explicitly. Never degrade silently.
