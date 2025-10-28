# Potatodo

An iOS **habit tracker** with a tamagotchi-style potato buddy 🥔
- Decide three daily priorities, celebrate completion with your potato pal, keep your streak going.

---

## The Product Thesis

focus + consistency are the keys to forming habits
- only choosing 3 tasks per day encourages focus
- streaks and tamagotchi buddy encourage consistency

plan less, finish more

---

## The Prototype

This prototype exists to test the question: "is there a market for a tamagotchi habit tracker app?"

It was my **first iOS app** and was built in ~2 weeks - from concept to alpha test deployment. 

The goal was to get user feedback asap, so speed of development was prioritized, and the code is scrappy in parts.

10 friends tested this app during Alpha. I collected feedback via a survey and google analytics.

---

## Key Features

- **Tamagotchi-style Potato Buddy** with dance animations and async buffered speach
- Choose **3 tasks/day**
- View by **day/week/month**
- Visualize **streaks** with counters and calendar
- Animated launch screen and overlay celebration fx
- Set **Notifications**
- **Profile** management
- **Data Persistence** via FileManager (tasks) and UserDefaults (settings)
- Seperate **RELEASE**/Test/Debug builds for development
- Interactive **Debug View**
- **Google Analytics** enabled


See `TODO.txt` for a chronological feature log.

---

## Screenshots / Demo

- (Add a 20–30s GIF here if you have one)  
- (Optional) `/docs/screenshots/` for static shots

---

## Getting started

**iPhone Installation**

Use this link to install on your iPhone via TestFlight: 
## [Potatodo iPhone(17+) Installation](https://testflight.apple.com/join/w8TPU5AM)

**Or Run In Xcode**

1. Open the project in Xcode (15+).
2. Select an iPhone simulator (17+).  
3. Build & Run potatodo_RELEASE.

---

# Codebase

## Architecture

Files are named according to the following conventions:
- `*_V.swift` - views (UI components)
- `*Manager.swift` – managers (store + manipulate data)
- `*_VM.swift` - viewmodels (assemble views, tigger manager updates)

## Key Files (START HERE)

- `potatodo/potatodoApp.swift` – app entry point

- `potatodo/AppManager.swift` – central state manager
- `potatodo/Pages/` – the various app screens
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

## Notes

- **Speed to feedback > polish.** I prioritized shipping an alpha quickly to evaluate the “3 tasks/day + streak + tamagotchi” concept.  
- **Simple state with a single manager.** `AppManager.swift` currently centralizes app state, prioritizing iteration speed.
- **Placeholder graphics and UI.** This was a MVP funcitonal prototype so animations and UI are very basic.
