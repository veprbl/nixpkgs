import (fetchGit ./.) { localSystem = (import ./lib).systems.examples.musl64; }
