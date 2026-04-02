; Nuzlocke first encounter modes (stored in wNuzlockeMode)
;
; DISABLED (default)
;   No first-encounter restrictions. Balls work normally.
;   Old saves read 0 here and are treated as DISABLED.
;
; FORGIVING
;   Classic Nuzlocke duplicate clause: if the encountered species' evo line has
;   already been caught anywhere, the area stays OPEN and the "!" indicator is
;   not shown — the player may keep looking for a different species.
;   If the wild Pokemon flees on its own (random flee or whirlwind/roar), the
;   area is also reopened so the player gets another chance.
;   Running away yourself, knocking out the Pokemon, or the battle ending as a
;   draw (other than wild flee) locks the area as FAILED.
;
; STRICT
;   The very first wild Pokemon in each area locks that area — no duplicate
;   clause. Even if the player already owns that species, they must attempt to
;   catch it or lose the area. If the evo line was already caught the ball throw
;   is still blocked (no second chance via duplicates).
;   Wild fleeing does NOT reopen the area.
;
; Common to both active modes:
;   - Rules do not apply until EVENT_GAVE_MYSTERY_EGG_TO_ELM is set (i.e. after
;     the player returns the egg to Elm and receives the 5 starter Pokeballs).
;   - Areas are tracked per landmark (96 slots, indexed by landmark ID).
;   - Shiny Pokemon bypass the ball-throw block in both modes.
;   - The "!" battle indicator is shown whenever wNuzlockeFirstEncounter is set.
;   - Catching a Pokemon marks the area CAUGHT and records the evo line.
DEF NUZLOCKE_DISABLED  EQU 0
DEF NUZLOCKE_FORGIVING EQU 1
DEF NUZLOCKE_STRICT    EQU 2
DEF NUM_NUZLOCKE_MODES EQU 3

; wNuzlockeAreas per-slot values
DEF NUZLOCKE_AREA_OPEN   EQU $00 ; no encounter yet (0 = safe default for zero-init)
DEF NUZLOCKE_AREA_CAUGHT EQU $FC ; first encounter was caught
DEF NUZLOCKE_AREA_FAILED EQU $FD ; encounter used but no catch (KO, run, etc.)
; $01-$FB   = species ID of the first encountered Pokemon (area is active/pending)
