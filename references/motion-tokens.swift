import SwiftUI

// MARK: - Motion tokens
//
// Tokens are named by intent, never by number. Pick the token that matches what
// the motion *means*. If nothing fits, add a named token here rather than
// inlining a duration at the call site.
//
// Requires iOS 17+ for the spring presets, iOS 18+ for the zoom transition
// patterns that consume them.

enum Motion {

    /// Screen-level navigation. Confident, settled, no overshoot.
    /// Push, pop, and any full-screen destination change.
    static let navigate = Animation.smooth(duration: 0.45)

    /// Trays, sheets, inline expansion. A little bounce reads as physical mass.
    static let expand = Animation.spring(duration: 0.42, bounce: 0.22)

    /// Small, frequent feedback: toggles, selection, button press state,
    /// numeric ticks. Restrained on purpose. This fires hundreds of times a
    /// session and anything showier becomes noise.
    static let feedback = Animation.snappy(duration: 0.26, extraBounce: 0.05)

    /// Dismissal and collapse. Deliberately faster than the matching entry.
    /// Arriving deserves attention. Leaving does not.
    static let dismiss = Animation.smooth(duration: 0.30)

    /// Rare, high-impact moments only. Transaction confirmed, onboarding
    /// complete, first-run reveal. Using this on a frequent action burns it.
    static let celebrate = Animation.bouncy(duration: 0.60, extraBounce: 0.30)

    /// Continues a gesture the user just released, preserving their velocity so
    /// the handoff from finger to physics is invisible.
    ///
    /// `initialVelocity` is expressed as a fraction of the remaining distance
    /// per second. Use `normalizedVelocity(_:remaining:)` to compute it.
    static func handoff(velocity: Double) -> Animation {
        .interpolatingSpring(duration: 0.40, bounce: 0.18, initialVelocity: velocity)
    }

    /// Converts a `DragGesture.Value.velocity` component into the normalized
    /// units `handoff(velocity:)` expects. Guards the degenerate case where the
    /// element is already at rest at its destination.
    static func normalizedVelocity(_ velocity: CGFloat, remaining: CGFloat) -> Double {
        guard abs(remaining) > 0.001 else { return 0 }
        return Double(velocity / remaining)
    }
}

// MARK: - Reduce Motion

/// Applies an animation only when Reduce Motion is off.
///
/// Prefer this over reading `UIAccessibility.isReduceMotionEnabled` directly:
/// the environment value invalidates the view when the user changes the setting
/// mid-session, the static property does not.
private struct MotionModifier<V: Equatable>: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let animation: Animation
    let value: V

    func body(content: Content) -> some View {
        content.animation(reduceMotion ? nil : animation, value: value)
    }
}

extension View {
    /// Scoped, Reduce Motion aware replacement for `.animation(_:value:)`.
    /// Use this instead of the raw modifier everywhere.
    func motion<V: Equatable>(_ animation: Animation, value: V) -> some View {
        modifier(MotionModifier(animation: animation, value: value))
    }

    /// Swaps a movement transition for a cross-fade under Reduce Motion.
    /// Movement is the part that causes discomfort. Opacity is permitted.
    func motionTransition(
        _ transition: AnyTransition,
        reduced: AnyTransition = .opacity
    ) -> some View {
        modifier(MotionTransitionModifier(full: transition, reduced: reduced))
    }
}

private struct MotionTransitionModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let full: AnyTransition
    let reduced: AnyTransition

    func body(content: Content) -> some View {
        content.transition(reduceMotion ? reduced : full)
    }
}

/// For the imperative case, where you are inside a `withAnimation` call rather
/// than a view body. Read the environment value in the view and pass it down.
///
///     @Environment(\.accessibilityReduceMotion) private var reduceMotion
///     ...
///     withAnimation(Motion.expand.unlessReduced(reduceMotion)) { isOpen = true }
extension Animation {
    func unlessReduced(_ reduceMotion: Bool) -> Animation? {
        reduceMotion ? nil : self
    }
}
