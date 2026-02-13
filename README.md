# MyMod — Vintage Story Mod Template

A reusable template for creating Vintage Story mods. Fully dockerized build tooling.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) with Compose
- Make (optional — raw Docker commands listed below)
- A Vintage Story installation (for API DLLs)

## Quick Start

```bash
# 1. Copy game API DLLs into lib/
make setup GAME_PATH=/path/to/VintageStory

# 2. Build the mod
make build

# 3. Package into a release zip
make package
```

The release zip will appear in `releases/`.

## Creating a New Mod from This Template

```bash
# Clone the template
git clone <this-repo> MyCoolMod
cd MyCoolMod

# Rename all placeholders
make new-mod NAME=MyCoolMod

# Copy game DLLs and build
make setup GAME_PATH=/path/to/VintageStory
make build
```

`make new-mod` renames the `.csproj`, asset directories, namespaces, and mod IDs from `MyMod`/`mymod` to your chosen name.

## Project Structure

```
├── Dockerfile              # .NET 8 SDK build environment
├── docker-compose.yml      # Build service
├── Makefile                # Build/setup/packaging targets
├── MyMod.csproj            # .NET project file
├── modinfo.json            # Mod metadata (id, version, dependencies)
├── src/
│   └── MyModSystem.cs      # ModSystem entry point
├── assets/
│   └── mymod/              # Game assets (textures, blocktypes, etc.)
├── lib/                    # Game API DLLs (gitignored)
└── releases/               # Built zip output (gitignored)
```

## Make Targets

| Target | Description |
|--------|-------------|
| `make setup GAME_PATH=...` | Copy API DLLs from game install into `lib/` |
| `make build` | Compile via Docker container |
| `make package` | Build and create release zip in `releases/` |
| `make clean` | Remove `bin/`, `obj/`, `releases/` |
| `make new-mod NAME=X` | Rename all placeholders to your mod name |

### `make setup`

`GAME_PATH` is required — point it at your Vintage Story installation directory (wherever `VintagestoryAPI.dll` lives):

```bash
make setup GAME_PATH=/path/to/VintageStory
```

Copies `VintagestoryAPI.dll` (required) plus optional `VSSurvivalMod.dll`, `VSEssentials.dll`, `VSCreativeMod.dll`, and `cairo-sharp.dll` (for GUI/HUD work).

## Without Make

If you don't have `make`, you can run the Docker commands directly:

```bash
# Build
docker compose run --rm build

# Package (after building)
mkdir -p releases
docker compose run --rm --entrypoint sh build -c "\
  zip releases/mymod_1.0.0.zip modinfo.json && \
  cd bin/Release && zip -g ../../releases/mymod_1.0.0.zip MyMod.dll && \
  cd ../../assets && zip -r ../releases/mymod_1.0.0.zip mymod/"
```

Replace `mymod`, `1.0.0`, and `MyMod.dll` with your mod's actual values from `modinfo.json` and your `.csproj` name.

## Adding Assets

Place game assets under `assets/mymod/` following the standard Vintage Story directory structure:

- `assets/mymod/blocktypes/` — Block definitions
- `assets/mymod/itemtypes/` — Item definitions
- `assets/mymod/textures/` — Textures
- `assets/mymod/lang/` — Translations

See the [Vintage Story modding wiki](https://wiki.vintagestory.at/Modding) for details.

## Testing

1. Run `make package`
2. Copy the zip from `releases/` into your game's `Mods/` directory
3. Launch Vintage Story

## Updating Game DLLs

When upgrading to a new Vintage Story version, re-run setup pointing at the new install:

```bash
make setup GAME_PATH=/path/to/new/VintageStory
```
