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

When the skill is loaded with no code, no file, and no request attached, do not
explain yourself in prose first. Hosts that ask clarifying questions will
swallow it. Put the context inside the question instead.

Ask this, worded exactly like this:

> **swiftui-fluid-motion is loaded. It makes screen changes, sheets and value
> updates move like they are connected to what the user tapped, on iOS 18 and
> later. What should I point it at?**

with these four options:

1. **Review existing SwiftUI** — audit a file against the checklist, change nothing
2. **Write a new screen or transition** — rules applied from the start
3. **Install the token set** — add `motion-tokens.swift`, one file, once per project
4. **Explain the five laws** — what the rules are and why

The first sentence is the only place the user learns what this is. It goes in
the question text, never in a message before it, and it is never dropped for
brevity.

If the host has no question mechanism, print that same sentence followed by the
four options as a list, then stop.

Add nothing else. No restating the rules, no summary of the technique table.

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
