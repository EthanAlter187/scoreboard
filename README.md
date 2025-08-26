# Scoreboard

A Flutter-based basketball scoreboard and stat-tracking application designed for local leagues.  
The app provides real-time scorekeeping, stat collection, and schedule management, with Supabase (PostgreSQL) as the backend for authentication and data storage.

---

## 🚀 Features
- Live game scoreboard with customizable quarter length and timeouts.
- Player stat tracking (points, rebounds, assists, fouls).
- Schedule creation and weekly matchup display.
- Team and player management (names, jersey numbers, colors).
- Supabase integration for backend storage and user authentication.
- Clean UI with navigation for teams, schedules, and games.
- Email & Password account system for creating leagues and storing data.
- Dispersable invite code for adding viewers to a league.

---

## 🛠️ Tech Stack
- **Flutter** (Dart)
- **Supabase** (Postgres + Auth)
- **State Management**: Provider / ChangeNotifier
- **Platform**: Mobile + Web

---

## 📂 Code Structure
The main entry point of the app is here:  
[`lib/main.dart`](./lib/main.dart)

The app is split up into a large collection of class files within the [`lib/`](./lib) directory.
