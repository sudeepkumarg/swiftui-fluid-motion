// Supporting types the examples reference.
//
// Trimmed out of baseline.swift and with-skill.swift because they are identical
// in both versions and not what the comparison is about. They live here so the
// example compiles in CI.

import SwiftUI
import Charts

struct CryptoAsset: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let symbol: String
    let balance: Double
    let usdValue: Double

    var formattedBalance: String {
        balance.formatted(.number.precision(.fractionLength(0...6)))
    }

    var formattedUSDValue: String {
        usdValue.formatted(.currency(code: "USD"))
    }
}

extension CryptoAsset {
    static let sampleAssets: [CryptoAsset] = [
        CryptoAsset(name: "Bitcoin",  symbol: "BTC", balance: 0.4523, usdValue: 26_842.19),
        CryptoAsset(name: "Ethereum", symbol: "ETH", balance: 3.1287, usdValue: 8_214.55),
        CryptoAsset(name: "Solana",   symbol: "SOL", balance: 42.75,  usdValue: 3_918.30),
        CryptoAsset(name: "Cardano",  symbol: "ADA", balance: 1200.0, usdValue: 540.00),
        CryptoAsset(name: "Polkadot", symbol: "DOT", balance: 87.6,   usdValue: 612.20)
    ]
}

struct AssetRow: View {
    let asset: CryptoAsset

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(.tint)
                .frame(width: 36, height: 36)
                .overlay {
                    Text(asset.symbol.prefix(1))
                        .font(.headline)
                        .foregroundStyle(.white)
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(asset.name).font(.body.weight(.medium))
                Text(asset.symbol).font(.caption).foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(asset.formattedUSDValue).font(.body.weight(.medium))
                Text("\(asset.formattedBalance) \(asset.symbol)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct PriceChart: View {
    let asset: CryptoAsset

    private struct PricePoint: Identifiable {
        let id: Int
        let value: Double
    }

    private var series: [PricePoint] {
        (0..<30).map { day in
            let noise = sin(Double(day) * 0.4) * 0.08
            return PricePoint(id: day, value: asset.usdValue * (1 + noise))
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Price History").font(.headline)

            Chart(series) { point in
                LineMark(x: .value("Day", point.id), y: .value("Value", point.value))
                    .interpolationMethod(.catmullRom)
                AreaMark(x: .value("Day", point.id), y: .value("Value", point.value))
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(.tint.opacity(0.15))
            }
            .frame(height: 220)
            .chartXAxis(.hidden)
            .padding()
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
    }
}
