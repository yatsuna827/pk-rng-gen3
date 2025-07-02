# Pokemon 3rd Generation RNG Library (MoonBit Port)

A MoonBit implementation of the Pokemon 3rd generation (Ruby, Sapphire, Emerald, FireRed, LeafGreen) random number generation system.

## Overview

This project is a MoonBit port of the C# `Pokemon3genRNGLibrary`. It implements RNG algorithms for generating wild Pokemon encounters, individual values, natures, and other gameplay mechanics.

## Project Structure

```
src/
├── types/           # Basic type definitions (IVs, Nature, Gender, PokemonResult)
├── lcg32/          # 32-bit Linear Congruential Generator implementation
├── ivs-generator/  # Individual value generator collection
├── format-hex/     # Hexadecimal display utilities
└── lib/            # Main library

docs/               # C# implementation analysis documents
original/           # Original C# implementation (for reference)
```

## Build & Run

```bash
# Build
moon build

# Run tests
moon test

# Type check
moon check

# Format
moon fmt

# Execute
moon run
```

## License

Apache License 2.0. See [LICENSE](LICENSE) for details.
