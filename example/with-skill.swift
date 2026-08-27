// WITH SKILL — same prompt, swiftui-fluid-motion loaded.
//
// Structurally identical. Every difference is motion. The detail view now grows
// out of the row the user tapped, values roll instead of blinking, and the whole
// thing degrades correctly under Reduce Motion.
//
// Requires Motion from references/motion-tokens.swift.

import SwiftUI

struct AssetListView: View {
    // LAW 1: one namespace, declared in a scope that encloses both the source
    // row and the destination. Declaring this inside AssetRow is the most
    // common cause of a matched transition silently doing nothing.
    @Namespace private var namespace

    let assets: [CryptoAsset] = CryptoAsset.sampleAssets

    var totalUSDValue: Double {
        assets.reduce(0) { $0 + $1.usdValue }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Total Balance")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        // Numbers roll rather than blink. Motion.feedback is the
                        // restrained token on purpose: this updates constantly.
                        Text(totalUSDValue, format: .currency(code: "USD"))
                            .font(.largeTitle.bold())
                            .contentTransition(.numericText(value: totalUSDValue))
                            .motion(Motion.feedback, value: totalUSDValue)
                    }
                    .padding(.vertical, 8)
                }

                Section("Assets") {
                    ForEach(assets) { asset in
                        NavigationLink(value: asset) {
                            AssetRow(asset: asset)
                        }
                        // LAW 1: names the spatial origin. The detail view will
                        // grow out of this specific row.
                        .matchedTransitionSource(id: asset.id, in: namespace)
                    }
                }
            }
            .navigationTitle("Portfolio")
            .navigationDestination(for: CryptoAsset.self) { asset in
                AssetDetailView(asset: asset)
                    // LAW 3: direction is inherent. Forward zooms out of the
                    // row, back reverses that exact path, and the interactive
                    // dismiss drag returns the view to its origin.
                    .navigationTransition(.zoom(sourceID: asset.id, in: namespace))
            }
        }
    }
}

struct AssetDetailView: View {
    let asset: CryptoAsset

    // LAW 5: read the environment value, not UIAccessibility directly. The view
    // must invalidate when the user flips the setting mid-session.
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var chartRevealed = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(asset.name)
                        .font(.title2.bold())
                    Text(asset.symbol)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Balance")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("\(asset.formattedBalance) \(asset.symbol)")
                        .font(.title.bold())
                        .contentTransition(.numericText(value: asset.balance))

                    Text(asset.usdValue, format: .currency(code: "USD"))
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .contentTransition(.numericText(value: asset.usdValue))
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))

                if chartRevealed {
                    PriceChart(asset: asset)
                        // LAW 5: movement becomes a cross-fade under Reduce
                        // Motion. motionTransition handles the branch.
                        .motionTransition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .padding()
        }
        .navigationTitle(asset.symbol)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            // LAW 4: animate the state, scoped, not the view. The chart arrives
            // after the zoom has settled rather than competing with it.
            withAnimation(Motion.navigate.delay(0.15).unlessReduced(reduceMotion)) {
                chartRevealed = true
            }
        }
    }
}
