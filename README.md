# SwiftUI Fluid Motion

Apps built with AI tend to feel stiff. Screens appear out of nowhere, numbers
blink instead of counting, and nothing quite connects to what you tapped. The
code is correct. It just feels cheap, and it is hard to say why.

This is a skill you add to Claude or GPT. Once it is installed, the code they
write for your iOS app moves properly, without you having to know what any of
that means.

It is a translation of [**Family Values**](https://benji.org/family-values) by
[Benji Taylor](https://x.com/benjitaylor), the design principles behind the
Family wallet, into rules an AI can check itself against. The thinking is his.
This turns it into something enforceable.

## What you need

- A Mac with Xcode
- An iOS app you are building, targeting iOS 18 or later
- Claude or GPT, whichever you already use to write code

**You do not need to know Swift.** You do need a real iOS project for the code
to go into. If you are building for the web, this will not help you yet.

## What changes

The same request, asked of an AI with and without this skill installed.

| | Without | With |
|---|---|---|
| Tapping something | The next screen replaces the last one with a generic slide | The next screen grows out of the exact thing you tapped |
| Going back | Only the edge swipe works | Drag the screen down and it shrinks back into where it came from |
| Numbers updating | Blink to the new value | Roll from the old value to the new one |
| Timing | Uniform and mechanical | Physics, and leaving is quicker than arriving |
| Motion sensitivity settings | Ignored | Every animation has a still fallback |

Structurally the two versions are near identical. Every difference is movement.

The actual code for both is in [`example/`](example/): the unedited AI output
with no skill loaded, and the same request with it. Worth a look if you want to
see the difference rather than take my word for it.

## Install

### Claude

**[⬇ Download swiftui-fluid-motion.skill](https://github.com/sudeepkumarg/swiftui-fluid-motion/raw/main/swiftui-fluid-motion.skill)**

That link downloads the file. Add it to your Claude account and you are done. It
is also attached to every
[release](https://github.com/sudeepkumarg/swiftui-fluid-motion/releases).

### Claude Code

```
git clone https://github.com/sudeepkumarg/swiftui-fluid-motion.git \
  ~/.claude/skills/swiftui-fluid-motion
```

### GPT

Copy everything in [`for-gpt/system-prompt.md`](for-gpt/system-prompt.md) into
the Instructions field of a Custom GPT or a Project. Upload the three files in
[`references/`](references/) as knowledge files.

## How to use it

You do not have to invoke it. Ask for what you want the way you normally would
and the rules apply themselves.

```
Build a portfolio list that opens into a detail view.

Add a filter tray to this screen.

The balance updates live. Make it not look broken.

Review this screen's transitions.
```

That last one is the underrated case. Point it at something you already built
and it audits the work rather than writing anything new.

**One thing worth doing on day one.** Ask your AI to add
[`references/motion-tokens.swift`](references/motion-tokens.swift) to your
project. It is a small file that names every speed and bounce the rules refer
to. Without it the AI invents its own each time, and you end up with three
slightly different versions of the same movement.

**If nothing seems different,** say "using the fluid motion rules" once in your
message. That wakes it up.

## What the rules are

Five of them, in plain terms:

1. **Things come from somewhere.** A new screen grows out of whatever you
   tapped, rather than appearing from nowhere.
2. **Movement obeys physics.** Anything you touch responds like a physical
   object, not on a fixed timer.
3. **Direction means something.** Forward goes deeper. Back retraces the exact
   way in.
4. **You can interrupt it.** Change your mind mid-swipe and the motion reverses
   from where it is, rather than snapping and starting over.
5. **It respects motion sensitivity.** If someone has reduced motion turned on,
   every animation has a still version.

There is also a ten-point checklist the AI runs against its own work before
handing it to you, and a list of twelve mistakes it has been told not to make.

## What's inside

| File | What it is |
|---|---|
| `SKILL.md` | The rules the AI reads |
| `references/motion-tokens.swift` | The named speeds and bounces to add to your project |
| `references/patterns.md` | Worked examples of each kind of movement |
| `references/antipatterns.md` | Twelve mistakes and their fixes |
| `example/baseline.swift` | Real AI output with no skill loaded |
| `example/with-skill.swift` | The same request with it, annotated |
| `for-gpt/system-prompt.md` | The same rules, formatted for GPT |

## Requirements

iOS 18 and later. Two of the techniques are iOS 18 APIs and have no equivalent
before that. On an older target the skill falls back to an older method and
tells you it has done so, rather than quietly producing something that will not
work.

## One honest caveat

The example code was written and reviewed carefully but never compiled. Build it
once before trusting it. If something does not work,
[open an issue](https://github.com/sudeepkumarg/swiftui-fluid-motion/issues) and
I will fix it.

## Contributing

Useful contributions, roughly in order:

- Fixes for anything that does not compile
- Mistakes you have hit that are not in the list of twelve
- A web or Android version of the same five rules
- Evidence that a rule is wrong. That is the most valuable kind of issue.

## Credit

Every idea here traces back to
[Family Values](https://benji.org/family-values) by
[Benji Taylor](https://x.com/benjitaylor). If this is useful to you, read the
original. It is better than my summary of it.

## License

MIT. See [LICENSE](LICENSE).
