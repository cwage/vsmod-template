MODINFO := modinfo.json
MODID := $(shell grep '"modid"' $(MODINFO) | sed 's/.*: *"//;s/".*//')
VERSION := $(shell grep '"version"' $(MODINFO) | sed 's/.*: *"//;s/".*//')
CSPROJ := $(shell ls *.csproj 2>/dev/null | head -1)
DLL_NAME := $(basename $(CSPROJ))

.PHONY: setup build package clean new-mod

setup:
	@if [ -z "$(GAME_PATH)" ]; then echo "Usage: make setup GAME_PATH=/path/to/VintageStory"; exit 1; fi
	@echo "Copying API DLLs from $(GAME_PATH) ..."
	cp $(GAME_PATH)/VintagestoryAPI.dll lib/
	cp $(GAME_PATH)/VintagestoryAPI.pdb lib/ 2>/dev/null || true
	cp $(GAME_PATH)/VintagestoryAPI.xml lib/ 2>/dev/null || true
	cp $(GAME_PATH)/Mods/VSSurvivalMod.dll lib/ 2>/dev/null || true
	cp $(GAME_PATH)/Mods/VSEssentials.dll lib/ 2>/dev/null || true
	cp $(GAME_PATH)/Mods/VSCreativeMod.dll lib/ 2>/dev/null || true
	cp $(GAME_PATH)/Lib/cairo-sharp.dll lib/ 2>/dev/null || true
	@echo "Done. DLLs copied to lib/"

build:
	docker compose run --rm build

package: build
	@mkdir -p releases
	docker compose run --rm --entrypoint sh build -c "\
		rm -f releases/$(MODID)_$(VERSION).zip && \
		zip releases/$(MODID)_$(VERSION).zip modinfo.json && \
		cd bin/Release && zip -g ../../releases/$(MODID)_$(VERSION).zip $(DLL_NAME).dll && \
		cd ../../assets && zip -r ../releases/$(MODID)_$(VERSION).zip $(MODID)/"
	@echo "Package created: releases/$(MODID)_$(VERSION).zip"

clean:
	rm -rf bin/ obj/ releases/

new-mod:
	@if [ -z "$(NAME)" ]; then echo "Usage: make new-mod NAME=CoolMod"; exit 1; fi
	$(eval LOWER := $(shell echo $(NAME) | tr A-Z a-z))
	@echo "Renaming MyMod -> $(NAME), mymod -> $(LOWER)"
	mv MyMod.csproj $(NAME).csproj
	mv assets/mymod assets/$(LOWER)
	sed -i.bak 's/MyMod/$(NAME)/g' $(NAME).csproj src/MyModSystem.cs modinfo.json README.md
	sed -i.bak 's/mymod/$(LOWER)/g' $(NAME).csproj src/MyModSystem.cs modinfo.json README.md
	find . -name '*.bak' -delete
	mv src/MyModSystem.cs src/$(NAME)System.cs
	@echo "Done. Project renamed to $(NAME)."
