import SwiftUI

struct OptionsCalculatorView: View {
    @State private var model = CalculatorModel()

    private var deltaColor: Color {
        switch model.optionType {
        case .call: return model.result.delta > 0.4 ? .green : .red
        case .put: return .red
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.xxl) {
                inputsSection
                resultSection
                metricsGrid
                breakevenSection
                scenarioSection
            }
            .padding(AppSpacing.xl)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.appBackground)
        .navigationTitle("Calculator")
    }

    // MARK: - Inputs

    private var inputsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            SectionHeader(title: "Inputs")

            VStack(spacing: AppSpacing.md) {
                inputRow(label: "Stock price", unit: "$") {
                    TextField("Stock price", value: $model.stockPrice, format: .number)
                }
                inputRow(label: "Strike price", unit: "$") {
                    TextField("Strike price", value: $model.strike, format: .number)
                }
                inputRow(label: "Days to expiration", unit: "days") {
                    TextField("Days", value: $model.days, format: .number)
                }
                inputRow(label: "Implied volatility", unit: "%") {
                    TextField("IV", value: $model.ivPercent, format: .number)
                }
                inputRow(label: "Risk-free rate", unit: "%") {
                    TextField("Risk-free rate", value: $model.riskFreePercent, format: .number)
                }

                Picker("Option type", selection: $model.optionType) {
                    ForEach(OptionType.allCases) { type in
                        Text(type.displayName).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .padding(.top, AppSpacing.xs)
            }
            .cardStyle()
        }
    }

    private func inputRow<Field: View>(
        label: String,
        unit: String,
        @ViewBuilder field: () -> Field
    ) -> some View {
        HStack(spacing: AppSpacing.md) {
            Text(label)
                .font(.bodyText)
                .foregroundStyle(.primary)
            Spacer(minLength: AppSpacing.md)
            field()
                .font(.statValue)
                .multilineTextAlignment(.trailing)
                .textFieldStyle(.plain)
                .frame(maxWidth: 120)
            Text(unit)
                .font(.appCaption)
                .foregroundStyle(.secondary)
                .frame(width: 36, alignment: .leading)
        }
    }

    // MARK: - Result hero

    private var resultSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeader(title: "\(model.optionType.displayName) Option Value")
            Text(model.result.price.asCurrency)
                .font(.heroNumber)
                .foregroundStyle(model.optionType.color)
            Text("Theoretical price per share (x100 per contract)")
                .font(.appCaption)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Metrics

    private var metricsGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: AppSpacing.md),
                GridItem(.flexible(), spacing: AppSpacing.md)
            ],
            spacing: AppSpacing.md
        ) {
            MetricCard(
                label: "Delta",
                value: String(format: "%.3f", model.result.delta),
                caption: "Directional exposure",
                valueColor: deltaColor
            )
            MetricCard(
                label: "Theta",
                value: String(format: "%.3f", model.result.theta),
                caption: "Daily time decay",
                valueColor: .red
            )
            MetricCard(
                label: "Vega",
                value: String(format: "%.3f", model.result.vega),
                caption: "Per 1% IV move"
            )
            MetricCard(
                label: "Gamma",
                value: String(format: "%.4f", model.result.gamma),
                caption: "Delta change rate"
            )
        }
    }

    // MARK: - Breakeven

    private var breakevenSection: some View {
        HStack(spacing: AppSpacing.sm) {
            Text("Break-even at expiry:")
                .font(.bodyText)
                .foregroundStyle(.secondary)
            Text(model.breakeven.asPrice)
                .font(.bodyText.weight(.semibold))
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }

    // MARK: - Scenario

    private var scenarioSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(title: "Scenario")

            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                HStack {
                    Text("Stock move")
                        .font(.appCaption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(model.scenarioPct.asSignedPercent)
                        .font(.statValue)
                        .foregroundStyle(model.scenarioPct >= 0 ? .green : .red)
                }

                Slider(value: $model.scenarioPct, in: -30...30, step: 1)

                Text(scenarioSentence)
                    .font(.bodyText)
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .cardStyle()
        }
    }

    private var scenarioSentence: String {
        let stock = model.scenarioStockPrice.asPrice
        let move = model.scenarioPct.asSignedPercent
        let worth = model.scenarioOptionValue.asPrice
        return "At \(stock) (stock \(move)), the option is worth about \(worth) at expiration."
    }
}
