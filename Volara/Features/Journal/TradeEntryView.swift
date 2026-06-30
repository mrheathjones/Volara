import SwiftUI

struct TradeEntryView: View {
    let entry: TradeEntry

    @Environment(AppEnvironment.self) private var env
    @Environment(\.dismiss) private var dismiss

    @State private var draft: TradeEntry
    @State private var isClosed: Bool
    @State private var exitPriceValue: Double
    @State private var exitDateValue: Date

    init(entry: TradeEntry) {
        self.entry = entry
        _draft = State(initialValue: entry)
        _isClosed = State(initialValue: entry.exitPrice != nil)
        _exitPriceValue = State(initialValue: entry.exitPrice ?? 0)
        _exitDateValue = State(initialValue: entry.exitDate ?? Date())
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Trade") {
                    TextField("Ticker", text: $draft.ticker)
                        .textCase(.uppercase)

                    Picker("Type", selection: $draft.optionType) {
                        ForEach(OptionType.allCases) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)

                    TextField("Strike", value: $draft.strike, format: .number)

                    TextField("Premium", value: $draft.premium, format: .number)

                    Stepper(value: $draft.contracts, in: 1...1000) {
                        HStack {
                            Text("Contracts")
                            Spacer()
                            Text("\(draft.contracts)")
                                .foregroundStyle(.secondary)
                                .monospacedDigit()
                        }
                    }
                }

                Section("Dates") {
                    DatePicker("Entry Date", selection: $draft.date, displayedComponents: .date)
                    DatePicker("Expiration", selection: $draft.expiration, displayedComponents: .date)
                }

                Section("Exit") {
                    Toggle("Closed", isOn: $isClosed)

                    if isClosed {
                        TextField("Exit Price", value: $exitPriceValue, format: .number)
                        DatePicker("Exit Date", selection: $exitDateValue, displayedComponents: .date)
                    }
                }

                Section("Notes") {
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text("Entry Reason")
                            .font(.appCaption)
                            .foregroundStyle(.secondary)
                        TextField("Why did you enter this trade?", text: $draft.entryReason, axis: .vertical)
                            .lineLimit(2...4)
                    }

                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text("Notes")
                            .font(.appCaption)
                            .foregroundStyle(.secondary)
                        TextField("Additional notes", text: $draft.notes, axis: .vertical)
                            .lineLimit(2...5)
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle(entry.ticker.isEmpty ? "New Trade" : "Edit Trade")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(draft.ticker.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .frame(minWidth: 440, minHeight: 560)
    }

    private func save() {
        var edited = draft
        edited.ticker = draft.ticker.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if isClosed {
            edited.exitPrice = exitPriceValue
            edited.exitDate = exitDateValue
        } else {
            edited.exitPrice = nil
            edited.exitDate = nil
        }
        env.journal.update(edited)
        dismiss()
    }
}
