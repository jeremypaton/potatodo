# Potatodo

A tiny iOS **habit tracker** with a cheerful potato buddy 🥔

> Capture up to three daily tasks, keep a streak, and get gentle nudges from your animated potato pal.

---

## Why this exists

I built Potatodo over ~1 month, from the initial “tamagotchi todo app” idea to deployed alpha pilot with friends. It was my **first iOS app**, and the goal was speed to feedback, so the code-base is scrappy in parts. 

---

## Features

- Up to **3 tasks/day** with **day/week/month** views  
- **Daily streak** counters and visualization
- **Tamagotchi-style Potato Buddy** who celebrates your progress 
- **Notifications** to encourage consistency  
- **Profiles**, **Debug View**, and **Google Analytics**

See `TODO.txt` for a chronological feature log.

---

## Screenshots / Demo

- (Add a 20–30s GIF here if you have one)  
- (Optional) `/docs/screenshots/` for static shots

---

## Getting started

**Prereqs**

- Xcode 15+  
- iOS 17+ simulator (or device)

**Run**

1. Open the workspace/project in Xcode.  
2. Select an iPhone simulator.  
3. Press **Run** (⌘R).

**Notes**

- Notifications require simulator permissions or a real device.  
- Google Analytics config lives under `potatodo/Firebase/`. Remove/disable if you prefer a privacy-only build.

---

# Codebase

- `potatodo/potatodoApp.swift` – app entry point

## File Naming Conventions

- `*_V.swift` - view only classes (stateless)
- `*_M.swift` - model only classes (no UI)
- `*_VM.swift` - viewmodel classes (views with basic state)
- `*Manager.swift` – core state management classes

## Start here (for reviewers)

- `potatodo/AppManager.swift` – **central state manager** (app-level state, flows)  
- `potatodo/Pages/` – primary screens and navigation targets  
- `potatodo/Tasks/` – task model & logic  
- `potatodo/Potato/` – potato character (animation + speech)  

---

## Project structure

```
potatodo/
  potatodoApp.swift          # App entry point
  AppManager.swift           # General app/state manager
  Animation/                 # Animated intro (raining potatoes)
  Assets/                    # Images & asset catalogs
  Data/                      # Test & archived data
  Debug/                     # Interactive debug view
  Firebase/                  # Google Analytics setup
  Nav/                       # Navigation bars / helpers
  Overlay/                   # Overlays (task editor, potato rain)
  Pages/                     # Main app pages (Day/Week/Month)
  Potato/                    # Potato character (animation + speech)
  Tasks/                     # Task domain & logic
  Utils/                     # Shared utilities
```

---

## Design notes & trade-offs

- **Speed to feedback > polish.** I prioritized shipping an alpha quickly to evaluate the “3 tasks/day + streak + tamagotchi” thesis.  
- **Simple state with a single manager.** `AppManager.swift` currently centralizes app state, prioritizing iteration speed. This would be moduralized if scaled.
- **Placeholder graphics and UI.** This was a MVP funcitonal prototype so animations and UI are very basic.
