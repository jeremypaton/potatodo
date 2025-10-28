# Potatodo - Alpha Prototype

An iOS **habit tracker** with a tamagotchi-style potato buddy 🥔
- Decide three daily priorities, celebrate completion with your potato pal, keep your streak going.

<img src="https://github.com/user-attachments/assets/654d0312-3a29-4c05-a887-2ec71a0bba65" alt="Alt Text" width="300">

---

## Demo

# [view 3min demo](https://drive.google.com/file/d/1KWaio40nQ0CS2WZbFiWBsQj8Crd8D0I6/view?usp=drive_link)
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

<img height="400" alt="" src="https://github.com/user-attachments/assets/dfbeca9b-02cb-48f8-be03-f5d77c269e81" />
<img height="400" alt="Screenshot 2025-10-28 at 2 24 44 pm" src="https://github.com/user-attachments/assets/163eb7ab-edd6-45a3-a9a3-9c02f1b9ea4e" />
<img height="400" alt="Screenshot 2025-10-28 at 2 25 03 pm" src="https://github.com/user-attachments/assets/bc77f337-cf5e-4325-9a4b-cc2b1fae4c7e" />

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
