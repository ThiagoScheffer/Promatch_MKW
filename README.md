# Promatch — Advanced Fun Mod for Call of Duty 4: Modern Warfare

**Promatch** is a long-running **Call of Duty 4: Modern Warfare** mod built in **GSC (Game Script Code)**. It started as a competitive-style Promod/Promatch project and later evolved into a feature-rich fun mod with custom weapons, player systems, menus, game modes, progression, and a heavily extended bot AI layer.

The project ran on my own server for more than **8 years**, with real players using, testing, and stress-testing the mod across many versions. That live-server environment shaped the project: features were not only written, but repeatedly debugged, balanced, and improved under real gameplay conditions.

> This repository represents years of scripting, gameplay design, debugging, balancing, UI/menu work, texture/audio editing, and AI behavior experimentation inside the COD4 engine.

---

## Why This Project Matters

Promatch is more than a content mod. It is a complete gameplay systems project built within the limitations of an older engine and scripting environment. It demonstrates practical experience in:

- Game scripting and gameplay systems design
- Bot AI behavior, navigation, and objective logic
- Debugging complex runtime behavior from logs and spectator tools
- Refactoring legacy code into clearer module ownership
- Designing player-facing menus and HUD systems
- Balancing weapons, damage, progression, and team-based mechanics
- Maintaining a long-running live server project

For game development or technical job applications, the strongest part of this project is the combination of **AI systems**, **navigation debugging**, **gameplay engineering**, and **real production iteration**.

---

## Technical Highlights

### AI and Bot Systems

The bot system started from the open-source **Bot Warfare** project and was deeply adapted for this mod.

Original bot base:

https://github.com/ineedbots/iw3_bot_warfare

The current Promatch bot layer includes extensive custom behavior on top of the original foundation:

- Objective-aware bot behavior for Search & Destroy scenarios
- Bomb carrier planning, plant approach logic, recovery handling, and post-plant behavior
- Defender retake logic with defuse selection and contract-based objective ownership
- Route and waypoint traversal using A* pathfinding
- Smart unstuck and waypoint recovery logic
- Bot role assignment for attack, defense, support, retake, escort, post-plant, and recovery states
- Bot medic behavior for healing and reviving players
- Bot rank and difficulty behavior tied to progression
- Debug output for route state, movement authority, objective state, and AI decisions


### Experimental Local LLM AI Planning Layer

A newer experimental layer adds **local LLM-assisted tactical planning** through `BotSD_AIPlan_Monitor`. The goal is not to replace the real-time bot logic with an LLM, but to use a local model as a higher-level tactical adviser for Search & Destroy rounds.

This makes the project more relevant to current AI/game-development work because it combines traditional game AI with modern AI-assisted decision support:

- Local LLM planning monitor for S&D tactical analysis
- Round-state interpretation from bot/debug data
- AI-assisted suggestions for attack, defense, retake, and post-plant behavior
- Separation between high-level AI planning and low-level deterministic movement execution
- Safe fallback to normal bot logic when no LLM recommendation is available
- Experimental architecture for hybrid AI: scripted behavior + pathfinding + tactical model guidance

The important engineering point is that the LLM layer is treated as an **advisor**, while movement, combat, route execution, planting, defusing, and safety behavior remain deterministic inside the game script.

### New AI Navigation and Objective System

A major recent focus of the project has been improving the bot AI architecture. The navigation system was refactored toward a cleaner separation of responsibilities:

```text
Objective Resolver -> Movement Intent -> Route Planner -> Route State -> Movement Executor -> Movement Actuator
```

This was designed to fix older problems where multiple systems tried to control bot movement at the same time. The refactor improves clarity around **who owns movement**, **which objective the bot should follow**, and **when recovery logic is allowed to override normal route traversal**.

Key improvements include:

- Centralized movement intent handling
- Safer objective goal validation
- Better separation between S&D objective logic and low-level movement
- Stronger ownership rules for active A* routes
- Better handling of bomb carrier plant goals
- Smart waypoint recovery that avoids fighting valid objective routes
- Terminal route cleanup that avoids blocking valid re-planning
- Debug fields for movement authority, route ownership, stuck recovery, and objective resolution

This kind of work is directly relevant to game AI engineering because it deals with common real-world AI problems: goal selection, path following, local recovery, invalid state cleanup, and competing behavior systems.

---

## Core Features

### 1. Advanced Weapon Configuration

Promatch includes extensive weapon customization:

- Custom damage values per weapon
- Adjustable fire rates
- Reload speed tuning
- Ammo count customization
- Special ammo types such as FMJ, HP Ammo, and subsonic bullets
- Additional weapons including Springfield, Colt45, WA2000, AN94, MSR, Magnum500, and R516

### 2. Custom Damage System

The mod includes custom damage and health behavior:

- Dynamic damage scaling based on distance and weapon type
- Custom health mechanics
- Weapon-specific balancing
- Player status-based damage adjustments

### 3. Player Progression and Abilities

Promatch adds RPG-like and teamplay systems:

- Custom health and armor values
- Player abilities
- Upgrade systems
- Rank-based progression
- Medal and achievement-style feedback
- Medic system for reviving fallen teammates

### 4. Bot AI

The bot layer includes both general and mode-specific behavior:

- Movement and combat behavior
- Weapon usage
- Medic bots that can heal and revive
- Rank/difficulty-based behavior
- Search & Destroy role logic
- Bomb carrier, support, retake, and post-plant behavior
- Smart waypoint recovery and anti-stuck behavior
- Debug-driven navigation improvements

### 5. Search & Destroy Objective AI

The recent S&D AI system is one of the strongest technical parts of the project.

Implemented or improved systems include:

- Bomb carrier route planning
- Dynamic plant-goal prioritization
- Defender retake behavior
- Defuse contract ownership
- Support/escort role movement
- Post-plant hold positioning
- Objective-aware route recovery
- Navigation state debugging
- Protection against movement authority conflicts

This system demonstrates practical game AI work because it requires bots to reason about objectives, roles, route safety, timing, and recovery when movement fails.

### 6. Score, Stats, and HUD Systems

Promatch includes custom player feedback systems:

- Custom score tracking
- Real-time stats
- HUD elements for player performance
- Rank and progression display
- Final killcam integration

### 7. Custom Menus and Interface Work

The mod includes several custom menu systems:

- Quick Music Menu (`quickmusic.menu`)
- Server Info Menu (`serverinfo.menu`)
- Spray Menu (`spray.menu`)
- Vote Menu (`vote.menu`)
- Class Change Menu (`changeclass_mw.menu`)
- Quick Buy Menu (`quickbuy.menu`)
- Emblems and badges menu (`emblemas.menu`)
- Film tweaks menu (`filmtweaks.menu`)

### 8. Multimedia and Asset Work

The project also involved asset creation and editing:

- Photoshop with DDS/DX plugins for textures
- Audacity and Adobe Audition for audio editing
- Custom menu visuals
- Custom icons, emblems, and UI assets

---

## AI System Architecture

The newest bot architecture is organized around clearer module responsibility.

```text
_bot_sd.gsc
  Handles Search & Destroy roles, objectives, plant/defuse decisions, retake behavior, post-plant logic, and the BotSD_AIPlan_Monitor hook for local LLM-assisted tactical planning.

_bot_navigation.gsc
  Handles movement intent, route admission, A* route execution, SmartWP recovery, movement authority, and cursor handling.

_bot_actions.gsc
  Handles low-level bot input actions such as stance, ADS, use, grenade buttons, and smoke/flash/frag inputs.

_bot_waypoints.gsc
  Handles waypoint loading and waypoint data ownership.

_bot_lifecycle.gsc
  Handles lifecycle and safety checks that should not live inside utility helpers.

_bot_grenade.gsc
  Handles grenade planning, throw-plan ownership, and grenade behavior.

_bot_spectator_debug.gsc
  Provides runtime debug output for AI state, movement, route cursor, objective ownership, and recovery behavior.
```

This refactor reduced coupling in the helper layer and made the AI code easier to audit, test, and improve.

---

## Selected Engineering Problems Solved

These are the kinds of problems this project addresses, which are valuable for game development and technical job searches:


### Hybrid AI Planning With Local LLM Support

`BotSD_AIPlan_Monitor` was added as an experimental planning layer for Search & Destroy. It can observe tactical state and support higher-level planning decisions while leaving real-time execution to deterministic game logic.

This is useful from a hiring perspective because it demonstrates a practical hybrid AI architecture:

- The local LLM can reason about tactical context and round flow.
- GSC systems remain responsible for hard real-time decisions.
- The bot can continue using normal scripted behavior if the LLM output is unavailable, delayed, or unsafe.
- The architecture avoids putting pathfinding, weapon handling, or plant/defuse execution directly under probabilistic control.

This is the kind of AI integration pattern that is increasingly relevant in games, simulation, NPC behavior tools, and agentic gameplay prototyping.

### Movement Authority Conflicts

Older bot behavior could break when several systems tried to control movement at the same time. The refactor introduced clearer rules for when movement should come from:

- Objective route
- A* next waypoint
- Direct movement fallback
- SmartWP recovery
- Combat/survival override
- Plant/defuse interaction

### A* Route and Cursor Handling

The bot navigation work includes debugging and improving cases such as:

- Cursor stuck on a reached waypoint
- Next waypoint and second waypoint disagreement
- Terminal route cleanup incorrectly blocking re-planning
- Same-goal route rejection causing idle behavior
- Multi-node route traversal being mistaken for a terminal route

### Search & Destroy Objective Behavior

The S&D bot logic handles complex role-based behavior:

- Bomb carrier must prioritize dynamic plant goals
- Non-carrier attackers must still receive valid stage goals
- Defenders must detect when no active defuser exists
- Retake support can be promoted into a defuse role
- Post-plant holders must stay close enough to the planted bomb

### Smart Recovery Without Breaking Valid Routes

SmartWP recovery was improved to avoid fighting valid route traversal, especially in:

- Vertical stair transitions
- Bomb carrier plant approach
- Active multi-node A* routes
- Cases where the bot is already making progress

---

## Skills Demonstrated

This repository demonstrates practical experience with:

- Gameplay scripting in GSC
- Legacy code refactoring
- Game AI state machines
- Search & Destroy tactical AI
- Hybrid scripted AI + local LLM planning integration
- AI planner monitoring with deterministic execution fallback
- Pathfinding integration
- A* route execution
- Bot navigation debugging
- Runtime log analysis
- HUD and menu scripting
- Live gameplay balancing
- Weapon tuning
- Player progression systems
- Server-side mod development
- Long-term project maintenance

---

## Portfolio / Job-Search Highlights

For recruiters, game studios, or technical reviewers, the strongest parts of this repository are:

1. **Hybrid AI architecture** — traditional scripted bot AI extended with `BotSD_AIPlan_Monitor` for local LLM-assisted tactical planning.
2. **Game AI systems** — role assignment, objective selection, plant/defuse behavior, support logic, retake logic, and post-plant behavior.
3. **Navigation engineering** — A* route execution, waypoint cursor handling, SmartWP recovery, vertical/stair transition handling, and movement-authority debugging.
4. **Runtime debugging discipline** — spectator debug logs expose route state, objective ownership, stuck recovery, movement authority, and tactical decisions.
5. **Legacy-code refactoring** — large GSC systems were reorganized into clearer ownership layers such as actions, waypoints, navigation, lifecycle, grenade logic, and S&D planning.
6. **Live production iteration** — the mod ran for years on a real server, so systems were tested through real gameplay rather than only isolated scripts.

The project is especially relevant for roles involving gameplay programming, technical game design, AI gameplay engineering, NPC behavior, simulation, scripting, and legacy system refactoring.

---

## File Structure

A simplified view of the project structure:

```text
Promatch/
├── maps/mp/bots/
│   ├── _bot.gsc                     # Bot entry point and initialization
│   ├── _bot_script.gsc              # Main bot behavior integration
│   ├── _bot_sd.gsc                  # Search & Destroy bot objective AI
│   ├── _bot_navigation.gsc          # Bot movement, A*, route execution, SmartWP recovery
│   ├── _bot_actions.gsc             # Low-level bot input wrappers
│   ├── _bot_waypoints.gsc           # Waypoint loading and waypoint ownership
│   ├── _bot_lifecycle.gsc           # Bot lifecycle checks
│   ├── _bot_grenade.gsc             # Grenade logic and throw planning
│   ├── _bot_combat.gsc              # Bot combat behavior
│   ├── _bot_aim.gsc                 # Bot aim behavior
│   ├── _bot_perception.gsc          # Perception and awareness logic
│   └── _bot_spectator_debug.gsc     # Spectator debug output for bot AI
├── scripts/
│   ├── _globalinit.gsc              # Global initialization settings
│   ├── _guidcs.gsc                  # Player data persistence and management
│   ├── _scoresystem.gsc             # Score tracking and leaderboard
│   ├── _finalkillcam.gsc            # Custom final killcam system
│   ├── _ranksystem.gsc              # Player rank system
│   ├── _realtimestats.gsc           # Real-time stats tracking
│   ├── _carepackage.gsc             # Care package system
│   └── _vote.gsc                    # Vote system for maps/modes
├── ui/
│   ├── main.menu                    # Main menu interface
│   ├── quickmusic.menu              # Music control during gameplay
│   ├── serverinfo.menu              # Server info display
│   ├── spray.menu                   # Spray and player tag customization
│   ├── quickbuy.menu                # Quick buy menu
│   ├── emblemas.menu                # Emblem and badge customization
│   ├── changeclass_mw.menu          # Class change menu
│   ├── filmtweaks.menu              # Film tweaks menu
│   ├── squadmenu.inc                # Squad/team menu interface
│   ├── upgradetree.inc              # Player upgrade system
│   └── medalsinfo.inc               # Medals system for player achievements
├── Media/                           # Screenshots, menus, logos, and visual assets
├── README.md
└── License.txt
```

---

## Development Process

The project was built through long-term live iteration:

1. Build a feature or gameplay system.
2. Test it on a real COD4 server.
3. Watch how real players and bots interact with it.
4. Collect bugs, logs, and gameplay feedback.
5. Patch and rebalance the system.
6. Repeat over many versions.

For the bot AI, this process includes spectator debug logs, route-state inspection, movement authority analysis, and staged refactoring to avoid breaking unrelated behavior.

---

## Tools Used

- **GSC (Game Script Code)** for gameplay scripting
- **Notepad++** for most code editing
- **Photoshop** with DDS/DX plugins for textures and UI assets
- **Audacity** and **Adobe Audition** for audio work
- COD4 dedicated server testing
- Spectator debug logs for AI behavior analysis

---

## Images

### 2017

- **Menu2017-a.bmp**

![Menu2017-a](Media/Menu2017-a.bmp)

### 2018

- **Menu2018-a.jpg**

![Menu2018-a](Media/Menu2018-a.jpg)

- **Menu2018-b.jpg**

![Menu2018-b](Media/Menu2018-b.jpg)

- **Menu2018-c.jpg**

![Menu2018-c](Media/Menu2018-c.jpg)

- **Menu2018-d.jpg**

![Menu2018-d](Media/Menu2018-d.jpg)

### 2019

- **Menu2019-a.png**

![Menu2019-a](Media/Menu2019-a.png)

- **Menu2019-b.png**

![Menu2019-b](Media/Menu2019-b.png)

- **Menu2019-c.png**

![Menu2019-c](Media/Menu2019-c.png)

- **Menu2019-d.png**

![Menu2019-d](Media/Menu2019-d.png)

- **Menu2019-e.png**

![Menu2019-e](Media/Menu2019-e.png)

- **Menu2019-f.png**

![Menu2019-f](Media/Menu2019-f.png)

- **Menu2019-g.png**

![Menu2019-g](Media/Menu2019-g.png)

- **Menu2019-h.png**

![Menu2019-h](Media/Menu2019-h.png)

### 2020

- **Menu2020-a.png**

![Menu2020-a](Media/Menu2020-a.png)

### Logo

- **VSSnewlogo.png**

![VSSnewlogo](Media/VSSnewlogo.png)

### 2024

- **Menu2024-a.jpg**

![Menu2024-a](Media/Menu2024-a.jpg)

- **Menu2024-b.jpg**

![Menu2024-b](Media/Menu2024-b.jpg)

- **Menu2024-c.jpg**

![Menu2024-c](Media/Menu2024-c.jpg)

- **Menu2024-d.jpg**

![Menu2024-d](Media/Menu2024-d.jpg)

- **Menu2024-e.jpg**

![Menu2024-e](Media/Menu2024-e.jpg)



### 2026

- **Menu2026-a.jpg**

![Menu2026-a](Media/Menu2026-a.jpg)

- **Menu2026-b.jpg**

![Menu2026-b](Media/Menu2026-b.jpg)

- **Menu2026-c.jpg**

![Menu2026-c](Media/Menu2026-c.jpg)

- **Menu2026-d.jpg**

![Menu2026-d](Media/Menu2026-d.jpg)

- **Menu2026-e.jpg**

![Menu2026-e](Media/Menu2026-e.jpg)


- **DIAGRAM**

![DIAGRAM](Media/mermaid-diagram.jpg)

- **CONFLICT MAP**

![CONFLICT](Media/waypoint_conflict_map.jpg)


- **work-a**

![work-a](Media/work-a.jpg)

- **work-b**

![work-b](Media/work-b.jpg)


---

## Contribution

This project was originally developed solo, but suggestions, fixes, and improvements are welcome. Feel free to open an issue or submit a pull request.

---

## License

**Promatch** is released under the **MIT License**.

Important notes:

- **Call of Duty 4: Modern Warfare**, including its original assets, sounds, graphics, engine, and intellectual property, belongs to **Activision** and **Infinity Ward**.
- Promatch is an unofficial fan-made mod and is not affiliated with or endorsed by Activision or Infinity Ward.
- This repository does not grant any rights to distribute Call of Duty 4 or official game assets.
- You may modify, redistribute, and use the Promatch source code according to the MIT License, but you may not redistribute official COD4 assets.

---

## Acknowledgements

- **Infinity Ward** and **Activision** for Call of Duty 4: Modern Warfare
- **GSC scripting** for enabling deep gameplay customization
- **Bot Warfare** by ineedbots as the original bot foundation
- The players and friends who tested, played, and helped shape the mod over many years
