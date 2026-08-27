# Antipatterns

Before and after pairs for the common failures. If you are writing the left
column, stop.

---

## 1. The teleport

The view arrives from nowhere. The user cannot tell what they touched.

```swift
// Wrong
.sheet(isPresented: $showDetail) {
    DetailView(asset: asset)
}

// Right
Button { showDetail = true } label: { AssetRow(asset: asset) }
    .matchedTransitionSource(id: asset.id, in: namespace)
    .sheet(isPresented: $showDetail) {
        DetailView(asset: asset)
            .navigationTransition(.zoom(sourceID: asset.id, in: namespace))
    }
```

---

## 2. Timing curves on interactive motion

A timing curve describes a schedule. The finger described a force.

```swift
// Wrong
withAnimation(.easeInOut(duration: 0.3)) { isOpen.toggle() }

// Right
withAnimation(Motion.expand) { isOpen.toggle() }
```

---

## 3. Unscoped animation

Animates every property in the subtree, including ones added later by someone
else.

```swift
// Wrong
CardView()
    .animation(.spring())

// Right
CardView()
    .motion(Motion.expand, value: isExpanded)
```

---

## 4. Symmetric entry and exit

One duration for both makes dismissal feel sluggish.

```swift
// Wrong
withAnimation(Motion.expand) { isOpen = false }

// Right
withAnimation(Motion.dismiss) { isOpen = false }
```

---

## 5. Reduce Motion as an afterthought

```swift
// Wrong
.transition(.move(edge: .bottom))

// Right
.motionTransition(.move(edge: .bottom))   // cross-fades under Reduce Motion
```

Reading `UIAccessibility.isReduceMotionEnabled` in a view body is also wrong.
The view will not invalidate when the user flips the setting. Use
`@Environment(\.accessibilityReduceMotion)`.

---

## 6. Namespace in the wrong scope

The most common cause of a matched transition that silently does nothing.

```swift
// Wrong
struct Row: View {
    @Namespace private var namespace   // new namespace per row, never matches
}

// Right
struct AssetList: View {
    @Namespace private var namespace   // one namespace enclosing both endpoints
}
```

---

## 7. Offsetting instead of laying out

`.offset` moves the pixels and leaves the hit-testing rectangle behind. The user
taps a button that is no longer visually there.

```swift
// Wrong
content.offset(y: isOpen ? 0 : 300)

// Right
if isOpen { content.motionTransition(.move(edge: .bottom)) }
```

`.offset` is correct only for in-flight gesture tracking that returns the
element to its laid-out position.

---

## 8. Magic numbers

```swift
// Wrong
withAnimation(.spring(response: 0.38, dampingFraction: 0.72)) { ... }

// Right
withAnimation(Motion.expand) { ... }
```

Two views using 0.38 by coincidence is not consistency. Add a named token.

---

## 9. Non-visual work inside withAnimation

The closure is for state that drives layout. Nothing else belongs there.

```swift
// Wrong
withAnimation(Motion.navigate) {
    let data = try await api.fetchPortfolio()
    portfolio = data
    isLoading = false
}

// Right
let data = try await api.fetchPortfolio()
withAnimation(Motion.navigate) {
    portfolio = data
    isLoading = false
}
```

---

## 10. Back that does not reverse

Push in from the trailing edge, pop out to the trailing edge. An exit in a
different direction than the entry destroys the user's model of where the
previous screen went.

---

## 11. Delight on a high-frequency action

`Motion.celebrate` on a button pressed forty times a day is an obstacle.
Intensity is inversely proportional to frequency.

---

## 12. One polished screen

A single sub-screen with default transitions undermines every screen that got
the treatment, because the user learns the polish is decoration rather than how
the app works. Apply these rules everywhere or the investment does not compound.
