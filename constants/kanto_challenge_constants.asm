; Kanto Challenge Mode level scaling (stored in wKantoChallengeLevel)
;
; The value IS the number of extra levels added per Kanto badge owned
; (0 = OFF, 1-7). It applies on the Kanto gym maps and, after the Elite Four,
; to wild Pokemon and trainers elsewhere in Kanto. Kanto gym LEADERS
; additionally load a harder party (with extra Pokemon) whenever it is nonzero.
DEF NUM_KANTO_CHALLENGE_LEVELS EQU 8 ; OFF, 1 .. 7 levels per badge

; Level of each gym's lowest-level leader Pokemon at 0 Kanto badges.
DEF KANTO_GYM_BASE_LEVEL EQU 45

; Outside the gyms, levels are clamped to [floor, cap] at 0 badges, then get
; the badge bonus. Caps sit below the gym baseline: wild lower than trainers.
DEF KANTO_WILD_CAP      EQU KANTO_GYM_BASE_LEVEL - 10
DEF KANTO_WILD_FLOOR    EQU KANTO_WILD_CAP - 10
DEF KANTO_TRAINER_CAP   EQU KANTO_GYM_BASE_LEVEL - 5
DEF KANTO_TRAINER_FLOOR EQU KANTO_TRAINER_CAP - 10
