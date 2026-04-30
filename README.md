# Smart Cache Management Simulator

A C++17 simulator demonstrating an intelligent cache eviction system driven by a **Greedy Algorithm** that maximises cache utility.

---

## Table of Contents
1. [Project Overview](#project-overview)
2. [Directory Structure](#directory-structure)
3. [Build & Run](#build--run)
4. [Architecture](#architecture)
5. [Greedy Algorithm — Design Rationale](#greedy-algorithm--design-rationale)
6. [Utility Formula](#utility-formula)
7. [Comparison with FIFO & LRU](#comparison-with-fifo--lru)
8. [Complexity Analysis](#complexity-analysis)
9. [Sample Output](#sample-output)

---

## Project Overview

Modern applications cache frequently accessed data to avoid expensive recomputations or I/O operations.  When the cache is **full**, deciding *which item to remove* (eviction policy) directly impacts performance.

This simulator:
- Models a cache with **fixed KB capacity**.
- Assigns every item a dynamic **utility score** (hybrid of access frequency and recency).
- Uses a **greedy eviction strategy**: always evict the item with the lowest utility-per-KB, maximising total retained value.
- Tracks **cache hits / misses** and reports a **hit-ratio** after each simulation scenario.

---

## Directory Structure

```
SmartCacheSimulator/
├── include/
│   ├── DataItem.h          # Data item with utility scoring
│   └── CacheManager.h      # Cache controller (greedy eviction)
├── src/
│   ├── DataItem.cpp
│   ├── CacheManager.cpp
│   └── main.cpp            # Three simulation scenarios
├── docs/
│   └── design.md           # Extended design notes
├── CMakeLists.txt           # CMake build (recommended)
├── Makefile                 # GNU Make alternative
└── README.md
```

---

## Build & Run

### Option A — CMake (recommended)

```bash
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build
./build/SmartCacheSimulator
```

### Option B — GNU Make

```bash
make          # compiles to ./SmartCacheSimulator
make run      # compile + execute
make clean    # remove build artefacts
```

### Requirements
- **g++ ≥ 9** or **clang++ ≥ 10** (C++17 support required)
- CMake ≥ 3.16 (for CMake build)

---

## Architecture

### `DataItem`
| Member | Type | Description |
|---|---|---|
| `key_` | `std::string` | Unique cache key |
| `value_` | `std::string` | Stored payload |
| `sizeKB_` | `double` | Memory footprint |
| `frequency_` | `int` | Times accessed |
| `lastAccess_` | `std::time_t` | UNIX timestamp of last hit |

Key method: `computeUtility(alpha, now)` — returns the greedy score.

### `CacheManager`
| Member | Type | Description |
|---|---|---|
| `cache_` | `std::map<string, DataItem>` | O(log n) keyed store |
| `evictLog_` | `std::vector<string>` | History of evicted keys |
| `hits_ / misses_` | `int` | Statistics counters |

Key methods:

| Method | Description |
|---|---|
| `access(key)` | Hit/miss check; updates frequency on hit |
| `insert(item)` | Inserts item; triggers `greedyEvict` if needed |
| `greedyEvict(requiredKB)` | Builds min-heap by utility; pops until space freed |
| `simulateAccessSequence(seq)` | Runs a pre-built workload |
| `printStatistics()` | Displays hit ratio, eviction count, etc. |

---

## Greedy Algorithm — Design Rationale

### Problem framing
Given a cache of capacity **C KB** and a set of candidate items, we want to select a subset that **maximises total utility** subject to the capacity constraint.  This is a variant of the **0-1 Knapsack problem**, which is NP-hard in general.

### Greedy approximation
We relax it to the **Fractional Knapsack** setting: instead of asking "keep all or nothing", we rank items by **utility density** (`utility / sizeKB`) and evict from the lowest end until space is freed.  For fractional knapsack this is provably optimal; for the integer variant it is a good heuristic.

**Eviction rule** (greedy choice):

> *At each eviction step, remove the item with the **minimum utility score**.*

This is locally optimal: we sacrifice the least-valuable item first, preserving maximum aggregate utility in the cache.

### STL data structures used
- `std::map<string, DataItem>` — O(log n) keyed access for the cache store.
- `std::priority_queue` (min-heap via `std::greater`) — O(n log n) build, O(log n) per pop for the eviction queue.
- `std::vector<string>` — O(1) append for the eviction log.

---

## Utility Formula

```
utility(item, now) =
    alpha  × (frequency / sizeKB)
  + (1 - alpha) × exp(−λ × age_seconds)
```

| Parameter | Default | Role |
|---|---|---|
| `alpha` | 0.6 | Weight: frequency (0) ↔ recency (1) |
| `λ` | 1/3600 | Recency decay — half-life ≈ 41 min |

- **High frequency + small size** → high score → stays in cache.
- **Old, rarely-used large item** → low score → first to be evicted.

---

## Comparison with FIFO & LRU

| Strategy | Eviction criterion | Considers size? | Considers frequency? | Optimal? |
|---|---|---|---|---|
| **FIFO** | Oldest insertion | ✗ | ✗ | ✗ |
| **LRU** | Least-recently used | ✗ | Indirect | Better than FIFO |
| **Greedy (this)** | Lowest utility/KB | ✓ | ✓ | Approximately optimal |

**FIFO** can evict a hot item that simply happened to be inserted early.  
**LRU** is better but evicts based on a single timestamp, ignoring how *many* times an item was used or how large it is.  
**Greedy** combines frequency, recency, and size into one score, choosing the eviction candidate that wastes the least "value per KB".

---

## Complexity Analysis

| Operation | Time | Space |
|---|---|---|
| `access(key)` | O(log n) | O(1) |
| `insert(item)` — no eviction | O(log n) | O(1) |
| `insert(item)` — with eviction | O(n log n) | O(n) |
| `greedyEvict` | O(n log n) build + O(k log n) pops | O(n) |
| `simulateAccessSequence(m ops)` | O(m · n log n) worst case | O(n) |
| `printState` | O(n log n) | O(n) |

Where **n** = items currently in cache, **k** = number of items evicted in one call, **m** = length of access sequence.

In typical workloads k ≪ n, so the amortised cost per `insert` is close to O(log n).

---

## Sample Output (abbreviated)

```
╔══════════════════════════════════════════════════════════╗
║       SMART CACHE MANAGEMENT SIMULATOR v1.0             ║
╚══════════════════════════════════════════════════════════╝

==============================================================
  SCENARIO 1 — Manual Insertion & Greedy Eviction Demo
==============================================================
  [INSERT] key="config"  size=4.00 KB  used=4.00/30.00 KB
  ...
  [EVICT_START] Need 12.00 KB ...
    [EVICT]  key="image:bg"  utility=0.1042  size=8.00 KB
    [EVICT]  key="user:1002" utility=0.2500  size=3.00 KB
  [INSERT] key="dataset:X"  size=12.00 KB  used=28.00/30.00 KB

╔══════════════════════════════════════════════════════════╗
║              CACHE STATISTICS                           ║
║  Hit Ratio      :  62.50 %                              ║
╚══════════════════════════════════════════════════════════╝
```
