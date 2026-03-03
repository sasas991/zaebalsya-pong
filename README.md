# 🏓 zaebalsya-pong

![Banner](banner.png)

A two-player Pong game built with Flutter, designed for Android.

![Screenshot](screenshot.png)

---

## Gameplay

Two players share one device in **landscape mode**.

| Side | Player | Control |
|------|--------|---------|
| Left | P1 | Drag the left half of the screen |
| Right | P2 | Drag the right half of the screen |

Both players can move simultaneously — full multi-touch support.

---

## Features

- Smooth 60 fps game loop via Flutter `Ticker`
- Ball speed increases ~4% on every paddle hit
- Bounce angle varies based on where the ball hits the paddle
- Score tracked live at the top of the screen
- Custom ball image asset
- Immersive fullscreen (no status bar)
- Forces landscape orientation on launch

---

## Project Structure

```
lib/
  main.dart          # entire game
assets/
  ball.png           # ball sprite (64×64 PNG)
android/
  app/src/main/
    AndroidManifest.xml   # app name & icon config
    res/mipmap-*/         # launcher icons (all densities)
```

---

## Build & Run

```bash
flutter pub get
flutter run
```

Requires a connected Android device or emulator.

---

## Controls

```
┌─────────────────────────────────────────┐
│  P1  │                         │  P2   │
│  ▌   │     ●                   │    ▐  │
│  ▌   │           ─ ─ ─         │    ▐  │
│  ▌   │                         │    ▐  │
└─────────────────────────────────────────┘
 drag left                       drag right
```
