; Kanto Challenge Mode level scaling (stored in wKantoChallengeLevel)
;
; The value IS the number of extra levels added per Kanto badge owned when a
; battle takes place on one of the 8 Kanto gym maps (0 = OFF, 1-7 = +1..+7
; levels/badge). Kanto gym LEADERS additionally load a harder party (with
; extra Pokemon) whenever this value is nonzero.
DEF NUM_KANTO_CHALLENGE_LEVELS EQU 8 ; OFF, +1 .. +7

; Level of each gym's lowest-level leader Pokemon at 0 Kanto badges.
DEF KANTO_GYM_BASE_LEVEL EQU 45
