# Patterns

Working implementations for each row of the technique table in `SKILL.md`.
All examples assume `motion-tokens.swift` has been copied into the project.

---

## 1. List or grid item to detail

The zoom transition is the native shared-element transition. The detail view
grows out of the exact row the user tapped, and dismissal is interactive by
default: the user drags the detail back down and it returns to its origin.

```swift
struct AssetListView: View {
    @Namespace private var namespace
    let assets: [Asset]

    var body: some View {
        NavigationStack {
            List(assets) { asset in
                NavigationLink {
                    AssetDetailView(asset: asset)
                        .navigationTransition(.zoom(sourceID: asset.id, in: namespace))
                } label: {
                    AssetRow(asset: asset)
                }
                .matchedTransitionSource(id: asset.id, in: namespace)
            }
        }
    }
}
```

`@Namespace` must be declared in a scope that encloses both the source and the
destination. Declaring it inside the row is the most common cause of a silently
missing transition.

---

## 2. Card or button to modal

Same pair, applied to a presentation instead of a navigation destination. Use
this whenever a modal is triggered by a specific visible element.

```swift
struct PortfolioView: View {
    @Namespace private var namespace
    @State private var selected: Asset?

    var body: some View {
        Button {
            selected = featured
        } label: {
            FeaturedCard(asset: featured)
        }
        .matchedTransitionSource(id: featured.id, in: namespace)
        .sheet(item: $selected) { asset in
            AssetDetailView(asset: asset)
                .navigationTransition(.zoom(sourceID: asset.id, in: namespace))
        }
    }
}
```

If a modal has no visible trigger element, for example one presented by a push
notification or a background event, it is the one legitimate case for a
non-spatial presentation. State that reason in a comment.

---

## 3. Peer to peer

Peers move laterally, and the background persists so the user reads the change
as sliding along one plane rather than arriving somewhere new.

```swift
struct WalletTabs: View {
    @State private var tab: Tab = .balances

    var body: some View {
        ZStack {
            BackgroundGradient()      // persists, never transitions
            content
                .motionTransition(
                    .asymmetric(
                        insertion: .move(edge: tab.isForward ? .trailing : .leading),
                        removal:   .move(edge: tab.isForward ? .leading : .trailing)
                    )
                )
                .motion(Motion.navigate, value: tab)
        }
    }
}
```

Direction is derived from where the user is going, not hardcoded. A tab to the
right of the current one enters from the trailing edge, always.

---

## 4. Inline expand or collapse

`matchedGeometryEffect` works when both states live in one view hierarchy. The
element does not appear and disappear, it moves and resizes.

```swift
struct TransactionRow: View {
    @Namespace private var namespace
    @State private var isExpanded = false

    var body: some View {
        VStack {
            if isExpanded {
                ExpandedDetail(transaction: transaction)
                    .matchedGeometryEffect(id: "card", in: namespace)
            } else {
                CollapsedSummary(transaction: transaction)
                    .matchedGeometryEffect(id: "card", in: namespace)
            }
        }
        .motion(Motion.expand, value: isExpanded)
        .onTapGesture { isExpanded.toggle() }
    }
}
```

---

## 5. Tray or partial sheet

A tray preserves context. The content behind it stays visible and stays
interactive up through the small detent, which is what separates a tray from a
modal that has taken over the screen.

```swift
.sheet(isPresented: $showTray) {
    TrayContent()
        .presentationDetents([.height(240), .large], selection: $detent)
        .presentationBackgroundInteraction(.enabled(upThrough: .height(240)))
        .presentationCornerRadius(28)
        .presentationDragIndicator(.visible)
}
```

Detent changes animate themselves. Do not wrap the `selection` mutation in a
custom animation, it will fight the system's.

---

## 6. Numeric value change

Numbers should roll, not blink. This is the highest-frequency motion in a
finance interface and the token is deliberately the restrained one.

```swift
Text(balance, format: .currency(code: "USD"))
    .contentTransition(.numericText(value: balance))
    .motion(Motion.feedback, value: balance)
```

For a value that should read as counting up rather than merely changing, pass
the direction:

```swift
.contentTransition(.numericText(countsDown: newValue < oldValue))
```

The mutation must be animated for the transition to run:

```swift
withAnimation(Motion.feedback) { balance = fetched }
```

---

## 7. Icon or symbol state change

```swift
Image(systemName: isPlaying ? "pause.fill" : "play.fill")
    .contentTransition(.symbolEffect(.replace.downUp))
```

`.replace` for a change of meaning. `.bounce` for acknowledgement of a tap.
Never both on the same element.

---

## 8. Gesture-driven dismissal

The handoff from finger to physics is where interfaces most often break. If the
spring starts from zero velocity, the element visibly stalls at the moment the
user lifts their finger.

```swift
struct DraggableCard: View {
    @State private var offset: CGFloat = 0

    var body: some View {
        CardContent()
            .offset(y: offset)
            .gesture(
                DragGesture()
                    .onChanged { offset = max(0, $0.translation.height) }
                    .onEnded { value in
                        let shouldDismiss = value.predictedEndTranslation.height > 200
                        let target: CGFloat = shouldDismiss ? dismissDistance : 0
                        let v = Motion.normalizedVelocity(
                            value.velocity.height,
                            remaining: target - offset
                        )
                        withAnimation(Motion.handoff(velocity: v)) {
                            offset = target
                        }
                    }
            )
    }
}
```

Decide dismissal from `predictedEndTranslation`, not from `translation`. A fast
short flick should dismiss. A slow long drag should not necessarily.

---

## 9. Looping or ambient motion

The one place a timing curve is correct, because no user input is being
continued.

```swift
PhaseAnimator([0.0, 1.0], trigger: isLoading) { phase in
    ShimmerOverlay(progress: phase)
} animation: { _ in
    .easeInOut(duration: 1.2)
}
```

Ambient motion must stop entirely under Reduce Motion, not slow down.
