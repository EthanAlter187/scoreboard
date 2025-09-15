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
- **Supabase** (PostgresSQL)
- **State Management**: Provider / ChangeNotifier
- **Platform**: Mobile + Web

---

## 📖 Code Structure & Class Overview

This project is structured around Flutter widgets for UI, data model classes for persistence, and a central state manager (`MyAppData`) backed by Supabase. The project includes a collection of classes that are split into separate dart files within the [`/lib`](lib) directory.

---

## 🎮 Running the App

Scoreboard can be run by double clicking the Scoreboard executable. This can be found within the ['Scoreboard.zip'](Scoreboard.zip) file. Simply download the file and run the executable from within the folder.

---

### 🖼️ UI / Screens
- **`MyApp`** *(StatelessWidget)* – Root of the app; sets up `ChangeNotifierProvider<MyAppData>`, theme, and `AuthWrapper`.
- **`LoginPage`** *(StatelessWidget)* – Email/password sign-in & sign-up using Supabase.
- **`HomePage`** *(StatelessWidget)* – Landing screen with Continue/Create/Join League options and a sign-out button.
- **`CreateLeague`** *(StatelessWidget)* – Page wrapper for creating a league.
- **`CreateCard`** *(StatefulWidget)* – Form UI for creating a league (league name, team count).
- **`JoinLeague`** *(StatefulWidget)* – UI for joining an existing league by invite code.
- **`SettingsPage`** *(StatefulWidget)* – Edit league name, game settings, and copy invite code.
- **`Scorekeeping`** *(StatefulWidget)* – Live game screen with clock, quarter, timeouts, fouls, player stats, and box score.
- **`MainMenu`** – Hub for league actions (create schedule, start game, stats/standings, settings).  
- **`LeagueView`** – League overview after creation.  
- **`BoxScore`** – Read-only view of a finished game. 
---

### 📊 Data Models
- **`League`** – Represents a league (id, name, inviteCode).  
- **`TeamData`** – Represents a team (id, leagueId, name, color, wins, losses, totals, point differential).  
- **`Player`** – Represents a player (id, teamId, name, jersey, age, cumulative stats).  
- **`PlayerStats`** – Per-game stats (points, rebounds, assists, fouls).  
- **`Game`** – Represents a game (teams, date, status flags, scores, quarter, clock, team timeouts/fouls, per-player stats).  
- **`ScheduleSlate`** – A scheduled week/slate of games (id, leagueId, name).  

---

### ⚙️ State / Services
- **`MyAppData`** *(ChangeNotifier)* – Central state manager and Supabase data layer:
  - Handles league/team/player/game CRUD
  - Manages authentication-aware state
  - Updates game settings & schedules
  - Rolls up player stats after games finish   

---

📂 Main entry point: [`/lib/main.dart`](lib/main.dart)  
📂 Source folder: [`/lib`](lib)

