import Foundation

nonisolated struct Lesson: Identifiable, Sendable {
    let id: String
    let number: Int
    let title: String
    let icon: String
    let estimatedMinutes: Int
    let content: String

    static let all: [Lesson] = [
        Lesson(
            id: "lesson-1",
            number: 1,
            title: "What is an Option?",
            icon: "questionmark.circle",
            estimatedMinutes: 5,
            content: """
            ## The Big Idea

            An **option** is a contract that gives you the **right, but not the obligation**, to buy or sell 100 shares of a stock at a specific price before a specific date. That one word — *right, not obligation* — is the whole game. If the trade works in your favor, you act on it. If it doesn't, you simply let the contract expire and walk away. You are never forced to do anything.

            Think of it like putting a small deposit on a house. You pay the seller a fee to lock in a price for a while. If the house turns out to be a great deal, you buy it at the locked price. If it doesn't, you only lose the deposit — not the price of the whole house.

            ## Two Flavors: Calls and Puts

            There are exactly two kinds of options you'll start with:

            - A **call** gives you the right to **buy** a stock at a set price. You buy calls when you think the price is going **up**.
            - A **put** gives you the right to **sell** a stock at a set price. You buy puts when you think the price is going **down**.

            That's it. Up = call. Down = put. Everything else builds on those two ideas.

            ## One Contract = 100 Shares

            This trips up almost every beginner, so let's be clear. **One option contract controls 100 shares** of the underlying stock. The price you see quoted is *per share*, so you multiply by 100 to get the real cost.

            ## A Concrete Example

            Say **AAPL** is trading at $148. You believe it will rise over the next month, so you buy **one AAPL $150 call** for a **premium** of $3.00.

            - Cost to you: $3.00 × 100 shares = **$300 total**.
            - If AAPL climbs to $160, your call has real value because you can "buy at $150" something now worth $160.
            - If AAPL never gets above $150, the call expires worthless and you lose your **$300 — and never a penny more**.

            That capped downside is the beauty of *buying* options: your maximum loss is always the premium you paid. As you continue, remember this is education, not financial advice — start small and learn the mechanics before risking real money.
            """
        ),
        Lesson(
            id: "lesson-2",
            number: 2,
            title: "Key Terms",
            icon: "character.book.closed",
            estimatedMinutes: 6,
            content: """
            ## The Vocabulary You'll Use Every Day

            Options have their own language, but it's a small dictionary. Learn these handful of terms and most of the confusion disappears.

            ## Strike Price

            The **strike** is the locked-in price in your contract. For a call, it's the price you can *buy* at; for a put, it's the price you can *sell* at. An **AAPL $150 call** has a strike of $150 — that's the line in the sand the stock has to cross for your contract to gain real value.

            ## Premium

            The **premium** is the price you pay to own the option. It's quoted per share, so multiply by 100 for the true cost. A premium of **$2.50** means **$250** out of your pocket for one contract. The premium is also the *most you can lose* when you buy an option.

            ## Expiration

            Every option has an **expiration date** — the deadline. After it, the contract is gone. Options lose value as expiration approaches (more on that when we cover **theta**), so time is always ticking against a buyer.

            ## ITM, OTM, and ATM

            These describe where the stock price sits relative to your strike:

            - **In the money (ITM):** the option has real value. A $150 call is ITM when the stock is *above* $150. A $150 put is ITM when the stock is *below* $150.
            - **Out of the money (OTM):** the option has no intrinsic value yet — only hope and time. A $150 call is OTM when the stock is *below* $150.
            - **At the money (ATM):** the stock is sitting right around your strike.

            ## Bid and Ask

            When you look at an option quote you'll see two numbers:

            - The **bid** is the highest price a buyer will pay right now.
            - The **ask** is the lowest price a seller will accept right now.

            The gap between them is the **bid-ask spread**. Tight spreads (a few cents) mean a liquid, easy-to-trade option. Wide spreads mean you lose money just entering and exiting.

            ## Putting It Together

            Imagine: **TSLA $250 call, expiring in 21 days, bid $4.10 / ask $4.30.** That's a contract to buy TSLA at $250, expiring in three weeks, costing you about **$430** if you pay the ask. If TSLA is at $240 today, this call is **OTM** — TSLA must climb past $250 (plus your premium) for you to profit. Master these terms and you can read any option chain with confidence.
            """
        ),
        Lesson(
            id: "lesson-3",
            number: 3,
            title: "The Greeks",
            icon: "function",
            estimatedMinutes: 7,
            content: """
            ## Why "Greeks"?

            The **Greeks** are a set of numbers, each named after a Greek letter, that tell you how an option's price will react to changes in the world. You don't need the math — you just need to know what each one *feels* like. Volara's calculator computes all of these for you.

            ## Delta — How Much It Moves

            **Delta** tells you how much the option price changes when the stock moves **$1**. A delta of **0.50** means the option gains about **$0.50** for every $1 the stock rises (and loses $0.50 for every $1 it falls). Delta ranges from 0 to 1 for calls and 0 to -1 for puts.

            A handy bonus: delta also roughly estimates the **probability the option finishes in the money**. A 0.30 delta call has about a 30% chance of expiring ITM.

            ## Theta — The Daily Rent

            **Theta** is time decay — the amount of value your option **loses every day**, all else equal. It's almost always working *against* you as a buyer. A theta of **-0.05** means the option bleeds about **$5 per contract per day** just from time passing. Theta accelerates as expiration nears, which is why holding too long can quietly drain a position.

            ## Vega — Sensitivity to Volatility

            **Vega** measures how much the option price changes when **implied volatility** moves 1%. High vega means your option is sensitive to volatility swings. Buy when volatility is *low* and you get more bang for your premium; buy when it's high and you risk **IV crush** (covered in a later lesson).

            ## Gamma — The Accelerator

            **Gamma** tells you how fast **delta itself** changes as the stock moves. High gamma means delta shifts quickly — your option can gain or lose value in a hurry near the strike. Gamma is highest for at-the-money options close to expiration.

            ## A Worked Example

            You buy an **AAPL $150 call** with these Greeks: **delta 0.45, theta -0.06, vega 0.12, gamma 0.04.** Suppose AAPL jumps **$2** tomorrow and nothing else changes:

            - From delta: roughly +$0.45 × 2 = **+$0.90** per share, or about **+$90** on the contract.
            - But one day passed, so theta subtracts about **$6**.
            - Net estimate: about **+$84** on the contract.

            See how the Greeks combine? They won't be exact, but they give you an honest expectation before you trade — which is exactly the point.
            """
        ),
        Lesson(
            id: "lesson-4",
            number: 4,
            title: "Reading the Indicator",
            icon: "waveform.path.ecg",
            estimatedMinutes: 6,
            content: """
            ## What the Scanner Is Telling You

            Volara's scanner (and the matching TradingView indicator) watches several technical signals at once and boils them down into a single verdict. Here's how to read each piece so the signals make sense instead of feeling like magic.

            ## The Four Signals

            - **CALL** (green): conditions line up bullish. The price is stretched low, momentum is turning up, and volume is confirming. This suggests upside may be coming.
            - **PUT** (red): conditions line up bearish. The price is stretched high, momentum is turning down, and volume confirms. This suggests downside may be coming.
            - **NEUTRAL** (blue): no strong edge right now. The market is undecided, and the calm answer is usually to wait.
            - **SQUEEZE** (orange): volatility has compressed to unusually tight levels. A big move is often coming — but the squeeze alone doesn't tell you *which direction*.

            ## RSI — Momentum Gauge

            The **Relative Strength Index** runs from 0 to 100 and measures how overbought or oversold a stock is. Below **30** is traditionally oversold (potential bounce); above **70** is overbought (potential pullback). The scanner looks for RSI below ~35 for calls and above ~65 for puts — momentum extremes that often precede reversals.

            ## Bollinger Band Width — The Squeeze Detector

            **Bollinger Bands** wrap above and below price. When they pinch tightly together, **BB width** shrinks, signaling a volatility **squeeze**. Markets breathe in and out: tight bands (low width) tend to be followed by explosive expansion. That's why a SQUEEZE flag means "get ready," not "buy now."

            ## Volume — The Confirmation

            **Volume** is the number of shares traded. A real move is backed by real participation. The scanner flags **high volume** when today's volume is more than **1.5×** the average. A signal *with* a volume spike is far more trustworthy than the same signal on a quiet day.

            ## A Worked Read

            Suppose **NVDA** prints a **CALL** signal: RSI is **33**, price is hugging the lower Bollinger Band, the fast moving average just crossed above the slow one, and volume is **1.8×** average. Every box is checked — momentum, location, trend, and confirmation all agree. That's a textbook setup. Read the signals as a *checklist*, not a crystal ball, and you'll use them well.
            """
        ),
        Lesson(
            id: "lesson-5",
            number: 5,
            title: "Picking a Strike Price",
            icon: "target",
            estimatedMinutes: 5,
            content: """
            ## The Goldilocks Problem

            Choosing a **strike price** is about being realistic. Pick a strike too far away and the stock will never reach it — your option expires worthless. Pick one too close and you pay a fat premium for little room to profit. You want *just right*: a target the stock can plausibly hit before expiration.

            ## Let ATR Set Your Expectations

            The single best tool for "what's realistic" is **ATR — Average True Range**. ATR tells you, on average, **how many dollars a stock moves in a single day**. Volara shows you this number directly. If you know the typical daily move, you can sanity-check whether your strike is reachable in the time you have.

            A simple, sane rule of thumb the scanner uses: set targets within about **1.5× ATR** of the current price. That keeps your strike inside the range the stock genuinely tends to travel.

            ## A Worked Example

            Say **AAPL** is trading at **$150** and its **ATR is $3**. That means AAPL moves roughly **$3 per day** on average.

            - Over a 21-day expiration, a rough expected swing is several ATRs — but moves aren't linear, so don't just multiply $3 × 21 and expect $63.
            - Using the 1.5× ATR guide: 1.5 × $3 = **$4.50**. A near-term, reachable upside target sits around **$150 + $4.50 = $154.50**.
            - So a **$155 call** is an ambitious-but-plausible strike, while a **$152.50 call** is more conservative and likely to gain value sooner.
            - A **$175 call** would need AAPL to move **$25** — over 8× its daily ATR. That's a lottery ticket, not a plan.

            ## Closer vs. Farther Strikes

            - **Closer to the money** (e.g., the $152.50 call): more expensive, higher delta, moves more reliably with the stock. Better odds, smaller percentage gains.
            - **Farther out of the money** (e.g., the $160 call): cheaper, lower delta, needs a big move. Lower odds, bigger percentage gains if it hits.

            Beginners are usually better served by strikes **at or slightly out of the money**, where the option actually responds to the stock. Let ATR keep your ambitions honest, and your strike selection will improve immediately.
            """
        ),
        Lesson(
            id: "lesson-6",
            number: 6,
            title: "Choosing Expiration",
            icon: "calendar",
            estimatedMinutes: 6,
            content: """
            ## Time Is a Resource — Don't Waste It

            Picking an **expiration date** is really about buying yourself enough *time* to be right. Too little time and a good idea expires before it plays out. Too much time and you overpay. The expiration you choose decides how hard **theta** (time decay) works against you.

            ## The Three Common Choices

            - **0DTE (zero days to expiration):** expires *today*. Premiums are tiny and theta is brutal — value evaporates by the hour. These are high-octane gambles for experienced traders, not beginners. A small wrong move wipes you out fast.
            - **Weeklies (a few days to ~2 weeks):** cheaper, but theta is steep and accelerating. You need to be right *quickly*. Great for sharp catalysts, punishing for "I'll just wait it out."
            - **Monthlies (3–6+ weeks):** more expensive up front, but theta is gentler day-to-day. You get breathing room for your thesis to work. The most forgiving choice while you learn.

            ## Why Theta Risk Grows Near Expiration

            **Theta** decay isn't linear — it **accelerates** as expiration approaches. An option with 30 days left loses value slowly; the same option in its final week can lose value every single day at a steep clip. That's why holding a short-dated option "just one more day" so often backfires.

            ## The 14–28 Day Sweet Spot

            For most directional swing trades, the sweet spot is **14 to 28 days to expiration**. It balances two forces: enough time that theta isn't shredding you daily, but not so much that you're overpaying for time you won't use. Volara's scanner even hints at this — "*Look for options expiring in 14–28 days.*"

            ## A Worked Example

            You're bullish on **TSLA** at **$250** and buy a **$260 call**.

            - The **2-day weekly** costs **$1.20** ($120). If TSLA drifts sideways for a day, theta alone might cut it to $0.70 — a 40%+ loss with no price drop.
            - The **21-day monthly** costs **$6.50** ($650). The same sideways day barely dents it, and you still have three weeks for TSLA to make its move.

            The monthly costs more, but it buys you *time to be right* — and time is the thing beginners run out of fastest. When in doubt, give yourself more runway.
            """
        ),
        Lesson(
            id: "lesson-7",
            number: 7,
            title: "Managing Risk",
            icon: "shield.lefthalf.filled",
            estimatedMinutes: 7,
            content: """
            ## The Skill That Keeps You in the Game

            Here's the truth no one likes to hear: **risk management matters more than picking winners.** You can be right less than half the time and still come out ahead if you size correctly and cut losers. You can also be right most of the time and still blow up if one oversized trade goes wrong. Protect the downside first.

            ## Position Sizing and the 1–2% Rule

            The cornerstone is the **1–2% rule**: never put more than **1% to 2% of your account** at risk on a single trade. With options, your premium is your maximum loss, so this sets a hard cap on each position.

            Volara's settings even compute this for you. The formula it uses:

            - **Max position = floor( account size × risk% ÷ 100 ÷ (premium × 100) )**

            ## A Worked Example

            Suppose your account is **$10,000** and you use a **2% risk** limit.

            - 2% of $10,000 = **$200** is the most you'll risk on one trade.
            - You like an **AAPL $150 call** trading at a **$3.00** premium. Each contract costs $3.00 × 100 = **$300**.
            - $200 ÷ $300 = 0.66, which floors to **0 contracts** — this single contract already exceeds your limit. The honest answer is to find a cheaper option or skip it.
            - If instead the premium were **$1.50** ($150 per contract), then $200 ÷ $150 = 1.33 → **1 contract**. That keeps your worst case at $150, comfortably under your $200 cap.

            Sizing isn't glamorous, but it's what lets you survive a string of losses and still have capital to trade.

            ## Stop Losses and Exit Plans

            Decide *before* you enter where you'll get out:

            - **Stop loss:** a rule like "I'll exit if the option drops 50%." Honor it without negotiating.
            - **Profit target:** a rule like "I'll take profits at +75–100%." Taking gains is a skill too.

            Write the plan down (the journal is perfect for this) so emotion doesn't rewrite it mid-trade.

            ## Never Risk Money You Need

            Finally, the most important rule of all: **never trade with rent money, grocery money, or anything you can't afford to lose.** Options can go to zero. Trade only with risk capital, keep positions small, and treat this as education — not a get-rich scheme. Survive first; profits follow.
            """
        ),
        Lesson(
            id: "lesson-8",
            number: 8,
            title: "IV and the BB Squeeze",
            icon: "arrow.down.right.and.arrow.up.left",
            estimatedMinutes: 6,
            content: """
            ## Why Cheap Premium Matters

            Two traders can both be right about direction and get wildly different results — because one **overpaid** for their option. The hidden price tag is **implied volatility (IV)**. Learn to watch it and you'll stop buying expensive options right before they deflate.

            ## What Implied Volatility Really Is

            **Implied volatility** is the market's expectation of how much a stock will move. When IV is **high**, options are **expensive** — you're paying up for big expected swings. When IV is **low**, options are **cheap**. Crucially, IV tends to *spike* before known events (like earnings) and *collapse* right after.

            ## Buy Low IV, Sell the Move

            As an option *buyer*, you want to **buy when IV is low** and benefit when it rises (remember **vega** from the Greeks lesson — it measures exactly this sensitivity). Buying cheap volatility gives you two ways to win: the stock moves your way *and* IV expands, both pumping up your premium.

            ## The Bollinger Band Squeeze Connection

            Here's where Volara's **SQUEEZE** signal comes in. When **Bollinger Bands** pinch tight (low **BB width**), it means realized volatility has dried up — the stock has gone quiet. Quiet usually doesn't last. A squeeze flags that **volatility is coiled and cheap**, often the *best* time to buy options before the band expansion (and the big move) arrives.

            ## IV Crush — The Beginner Trap

            **IV crush** is the painful flip side. Before earnings, IV inflates and options get expensive. The moment earnings are released, the uncertainty vanishes and **IV collapses** — sometimes 30–50% in an instant.

            ## A Worked Example

            **NVDA** is at **$120** the day before earnings. You buy a **$125 call** for **$8.00** ($800) — but IV is sky-high. Earnings come out, NVDA rises to **$124**... yet your call is now worth only **$5.00** ($500). You were *right about direction* and still lost **$300** because **IV crush** outweighed the small price gain.

            Contrast that with buying the same call weeks earlier during a **squeeze**, when IV was low and the premium was just $3.00. The lesson: don't just ask "which way?" — ask "**is volatility cheap or expensive right now?**" Buying low IV, especially out of a squeeze, stacks the odds in your favor.
            """
        ),
        Lesson(
            id: "lesson-9",
            number: 9,
            title: "Reading Option Chains on Robinhood",
            icon: "list.bullet.rectangle",
            estimatedMinutes: 6,
            content: """
            ## The Wall of Numbers, Decoded

            Open any option in Robinhood and you'll see a grid of strikes, dates, and prices — the **option chain**. It looks intimidating, but you already know most of the pieces from earlier lessons. Let's connect them to what you'll actually tap on screen.

            ## Navigating the Chain

            In Robinhood you first pick **Buy** then **Call** or **Put**, then choose an **expiration date** along the top, and finally scroll a list of **strike prices**. Strikes near the current stock price are highlighted; strikes far away sit at the edges. Tap a strike to see its detail and price.

            ## Bid, Ask, and the Spread

            Each strike shows a **bid** (what buyers offer) and an **ask** (what sellers want). The **bid-ask spread** is the gap between them, and it's a direct cost to you.

            - A spread of **$2.50 / $2.55** is tight — a healthy, liquid option.
            - A spread of **$2.50 / $3.10** is wide — you lose 60 cents per share (**$60 per contract**) just by entering and immediately exiting. Avoid these when you can.

            Robinhood often shows a single "price," but always check the underlying bid/ask before committing.

            ## Volume and Open Interest

            Two numbers tell you how *alive* a contract is:

            - **Volume** is how many contracts traded **today**. High volume means active, current interest.
            - **Open interest (OI)** is how many contracts are **currently open** across the market. High OI means the strike is widely held and easy to trade.

            Low volume *and* low OI is a red flag: thin liquidity, wide spreads, and trouble getting filled at a fair price.

            ## A Worked Example

            You want an **AAPL $150 call** expiring in 21 days. You compare two strikes:

            - **$150 call:** bid $3.00 / ask $3.05, **volume 4,200**, **OI 18,000**. Tight spread, heavy activity — easy to get in and out near a fair price.
            - **$152.50 call:** bid $1.80 / ask $2.30, **volume 40**, **OI 110**. Wide spread, barely traded — you'd overpay entering and struggle to exit.

            Same stock, same expiration — but the first is *tradeable* and the second is a trap. Reading the chain means checking spread, volume, and OI **every time**, not just glancing at the headline price.
            """
        ),
        Lesson(
            id: "lesson-10",
            number: 10,
            title: "Common Beginner Mistakes",
            icon: "exclamationmark.triangle",
            estimatedMinutes: 5,
            content: """
            ## Learn From These So You Don't Have To

            Almost every new options trader makes the same handful of mistakes. The good news: they're predictable, which means they're avoidable. Here are the big five, and how to sidestep each one.

            ## 1. Getting Crushed by IV

            The classic blunder is buying expensive options right before earnings and getting wrecked by **IV crush**. You can be right about direction and still lose, because implied volatility collapses the instant the news drops. **Fix:** check whether volatility is cheap or expensive before you buy, and be very cautious holding through earnings.

            ## 2. Holding to Expiration

            Beginners love to "let it ride" until the last day, hoping for a miracle. But **theta** decay accelerates near the end, draining value daily, and a near-expiry option can swing wildly. **Fix:** plan to exit *before* the final stretch — most of your edge is gone by then anyway.

            ## 3. Trading on FOMO

            Seeing a stock rocket and jumping in late — **fear of missing out** — usually means buying the top, right before a pullback. Chasing green candles is how accounts bleed. **Fix:** wait for *your* setup (like the scanner's checklist), not the crowd's excitement. There's always another trade.

            ## 4. Oversizing

            Putting too much into one trade is the fastest way to blow up. One bad position shouldn't be able to hurt your account. **Fix:** use the **1–2% rule** and Volara's position-size calculator every single time.

            ## 5. No Exit Plan

            Entering without knowing where you'll get out leaves you trading on emotion — holding losers too long and selling winners too early. **Fix:** decide your stop loss and profit target *before* you enter, and write them in the journal.

            ## A Worked Example

            A new trader sees **TSLA** spike and, on **FOMO**, buys **5 contracts** of a 2-day **$260 call** at $4.00 — that's **$2,000**, far more than 2% of their $10,000 account (**oversizing**), the day before earnings (**IV crush risk**), with **no exit plan**. TSLA dips slightly, theta bites, IV crushes — and the position is nearly worthless by the next morning. Four mistakes in one trade.

            Contrast that with a single, modestly sized, 21-day contract bought on a real signal with a written stop. Same trader, completely different outcome. Avoid these five and you're already ahead of most beginners. Trade small, trade your plan, and keep learning — this is education, not financial advice.
            """
        )
    ]
}
