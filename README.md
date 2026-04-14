# Capsule

> Lock away what hurts. Heal without willpower.

**Capsule** is an iOS app that helps people going through a breakup by locking away digital memories — photos, screenshots, contact info — behind a real time lock. No peeking. No cheating. When the timer ends, you choose: **restore** everything, **incinerate** it all, or **extend** the timer.

This is not a photo vault. It's a **commitment device for emotional healing**, backed by peer-reviewed neuroscience.

---

## The Problem

Every breakup leaves a digital minefield. Photos in your camera roll. Screenshots of old texts. Their number one tap away. Apple's Hidden Album is useless — it's one Face ID scan from relapse.

You don't lack the desire to stop looking. You lack a lock that's stronger than your 2am impulse.

## The Science

| Study | Finding | Why It Matters |
|---|---|---|
| Fisher et al. (2010), *J. Neurophysiology* | Rejection activates the VTA and nucleus accumbens — the same dopaminergic reward circuits as **cocaine addiction** | Checking your ex's photos is literally addictive |
| Marshall (2012), *Cyberpsych. Behavior & Social Networking* (n=464) | Ex-surveillance → **+10% distress**, **+15% longing**, impaired personal growth | Every peek makes it objectively worse |
| Marshall (2025), McMaster University (n=762) | Active searching creates a **"next-day emotional hangover"**; effects persist at **6 months** | The damage compounds over time |
| Loewenstein (1996), Carnegie Mellon | In "hot" states, visceral drives **crowd out all other goals** | Why Hidden Album fails — zero friction against a 2am impulse |
| Karlan, Yale (StickK.com) | Commitment devices → **5x goal achievement** (78% vs 35%) | A real lock works. Willpower doesn't. |
| Acolin et al. (2023), *Emerging Adulthood* (n=156) | Depressive symptoms return to baseline **within 3 months** | 30/60/90 day timers match actual recovery science |
| Norton & Gino (2014), Harvard (n=247) | Rituals reduce grief via **increased feelings of control** | The locking and unlock ceremonies are therapeutic |
| Pennebaker (1986-2018), UT Austin (100+ studies) | Expressive writing → **50% fewer health visits**, improved immunity, effect size **d=.47** | The unsent letters journal |
| Lieberman (2007), UCLA | Naming emotions **diminishes amygdala activation** | The mood labeling check-ins |

Each re-exposure to photos of an ex **resets the extinction learning clock** — the brain's natural process for unlearning emotional associations. The vault prevents this by removing access to the stimulus entirely for 30, 60, or 90 days.

## How It Works

```
Select → Lock → Heal → Choose
```

1. **Select** — Pick the photos, screenshots, and contacts you need space from
2. **Lock** — Set a timer (30, 60, or 90 days). Items are AES-256 encrypted and removed from your camera roll. The vault seals.
3. **Heal** — Track urges, label emotions, write unsent letters, watch yourself recover
4. **Choose** — When the timer ends: **Restore** everything back to your camera roll, **Incinerate** it permanently, or **Extend** the timer

### Incinerate

Moved on before the timer expires? Don't wait. **Incinerate** permanently destroys everything in the vault. Type `INCINERATE` to confirm — this is irreversible. It's a ceremony of letting go. Not rage-deleting at 2am — a deliberate act of closure made from strength.

## Features

### The Vault (Free)
- AES-256 encrypted on-device storage (up to 10 items free)
- Real time lock — cannot be opened until the timer expires
- 24-hour cooldown if you try to break the lock (impulse protection)
- Urge tracking — every resisted peek is logged as a win
- Daily mood check-in with affect labeling
- Lock Screen + Home Screen widgets
- Locking ceremony, unlock ceremony, and incinerate

### Healing Tools (Pro — $6.99/month)
- **Unlimited vault items**
- **Unsent Letters** — Write what you need to say. Never sent. Locked in the vault.
- **Recovery Graph** — Mood tracked over time. Bad days are normal. Look at the trend.
- **Urge History** — Watch urges decline week over week. Visible proof of healing.
- **Milestone Insights** — Real science delivered at Day 7, 14, 21, 30, 45, 60, 90
- **Stage-Appropriate Prompts** — Distraction (early) → Reappraisal (mid) → Growth (late)
- **Guided Blocking Walkthroughs** — Step-by-step for iMessage, Instagram, Snapchat, WhatsApp
- **Multiple Vaults** — Different people, different timers
- **Premium Widgets** — More sizes, customizable
- **Unwatermarked Share Cards**

## Architecture

- **SwiftUI** + **SwiftData** — iOS 17+ minimum
- **CryptoKit** — AES-GCM encryption for vault contents
- **PhotoKit** — Import from / delete from / restore to photo library
- **WidgetKit** — Home Screen + Lock Screen widgets
- **CallKit** — Optional call blocking via directory extension
- **On-device only** — No server required. Your data never leaves your phone.

## Project Structure

```
Capsule/
├── CapsuleApp.swift              # App entry point + routing
├── Theme.swift                   # Design system (colors, type, spacing)
├── Models/
│   ├── Vault.swift               # Vault state, timer, progress
│   ├── VaultItem.swift           # Individual locked item
│   ├── MoodEntry.swift           # Daily mood + affect label
│   ├── UrgeEvent.swift           # Resisted/broken urge log
│   └── JournalEntry.swift        # Unsent letters
├── Services/
│   ├── VaultService.swift        # Lock, unlock, incinerate, encrypt
│   ├── PhotoService.swift        # PhotoKit integration
│   ├── HapticsService.swift      # Haptic feedback at key moments
│   └── NotificationService.swift # Milestones, daily check-ins
├── Views/
│   ├── Onboarding/
│   │   ├── OnboardingContainerView.swift
│   │   ├── WelcomeView.swift
│   │   ├── ContentSelectionView.swift
│   │   ├── TimerSelectionView.swift
│   │   └── LockCeremonyView.swift
│   ├── Home/
│   │   └── HomeView.swift
│   ├── Vault/
│   │   ├── UrgeView.swift
│   │   └── BreakLockView.swift
│   ├── Unlock/
│   │   ├── UnlockCeremonyView.swift
│   │   └── IncinerateView.swift
│   ├── Journal/
│   │   └── UnsentLetterView.swift
│   ├── Insights/
│   │   └── RecoveryGraphView.swift
│   ├── Paywall/
│   │   └── PaywallView.swift
│   └── Settings/
│       └── SettingsView.swift
├── Components/
│   ├── CapsuleButton.swift
│   ├── ProgressRing.swift
│   └── ParticleEmitter.swift
CapsuleWidget/
├── CapsuleWidget.swift
└── CapsuleWidgetBundle.swift
```

## Setup

1. Clone this repository
2. Open Xcode 16+
3. File → New → Project → iOS App (SwiftUI, SwiftData)
4. Copy the `Capsule/` source files into the main target
5. Add a Widget Extension target and copy `CapsuleWidget/` files
6. Add capabilities: App Groups (shared data between app + widget)
7. Set deployment target to iOS 17.0+
8. Build and run on a physical device (PhotoKit requires real hardware)

## License

MIT

---

*Built from real pain. Backed by real science. For anyone who needs a lock stronger than their 2am impulse.*
