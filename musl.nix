import (fetchGit ./.) { localSystem = (import ./lib).systems.examples.musl64; config = { allowUnfree = false; }; }
