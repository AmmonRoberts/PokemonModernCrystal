; Overflow handlers for new-game option toggles.
; Resides in "Crystal Features 1 Ext" (bank $21) because "Crystal Features 1"
; (bank $12) is full.  All routines here are called via farcall from CF1.

WildItemDropOptionHandler::
; Toggles wModFlags MODFLAG_WILD_ITEM_DROP_F.
	ldh a, [hJoyPressed]
	bit B_PAD_LEFT, a
	jr nz, .Toggle
	bit B_PAD_RIGHT, a
	jr z, .NonePressed
.Toggle:
	ld hl, wModFlags
	ld a, [hl]
	xor 1 << MODFLAG_WILD_ITEM_DROP_F
	ld [hl], a
.NonePressed:
	ld a, [wModFlags]
	bit MODFLAG_WILD_ITEM_DROP_F, a
	jr nz, .Enabled
	ld de, .Disabled
	jr .Display
.Enabled:
	ld de, .Enabled_str
.Display:
	hlcoord 8, 14
	call PlaceString
	ret
.Disabled:    db "DISABLED@"
.Enabled_str: db "ENABLED @"

EnemyDamageMultiplierOptionHandler::
; Cycles wEnemyDamageMultiplier: x0.50 / x0.75 / x1.00 / x1.25 / x1.50 / x2.00
	ldh a, [hJoyPressed]
	bit B_PAD_RIGHT, a
	jr nz, .Right
	bit B_PAD_LEFT, a
	jr nz, .Left
	jr .Display
.Right:
	ld a, [wEnemyDamageMultiplier]
	cp 5
	jr z, .WrapToMin
	inc a
	ld [wEnemyDamageMultiplier], a
	jr .Display
.WrapToMin:
	xor a
	ld [wEnemyDamageMultiplier], a
	jr .Display
.Left:
	ld a, [wEnemyDamageMultiplier]
	and a
	jr z, .WrapToMax
	dec a
	ld [wEnemyDamageMultiplier], a
	jr .Display
.WrapToMax:
	ld a, 5
	ld [wEnemyDamageMultiplier], a
.Display:
	ld a, [wEnemyDamageMultiplier]
	ld e, a
	ld d, 0
	ld hl, .Strings
	add hl, de
	add hl, de
	ld a, [hli]
	ld d, [hl]
	ld e, a
	hlcoord 8, 10
	call PlaceString
	ret
.Strings:
	dw .str_050
	dw .str_075
	dw .str_100
	dw .str_125
	dw .str_150
	dw .str_200
.str_050: db "x0.50@"
.str_075: db "x0.75@"
.str_100: db "x1.00@"
.str_125: db "x1.25@"
.str_150: db "x1.50@"
.str_200: db "x2.00@"

StaticRandOptionHandler::
; Toggles wStaticRandMode between STATIC_RAND_STANDARD and STATIC_RAND_RANDOMIZED.
	ldh a, [hJoyPressed]
	bit B_PAD_RIGHT, a
	jr nz, .Toggle
	bit B_PAD_LEFT, a
	jr z, .Display
.Toggle
	ld a, [wStaticRandMode]
	xor 1                      ; toggle between 0 (STANDARD) and 1 (RANDOMIZED)
	ld [wStaticRandMode], a
.Display
	ld a, [wStaticRandMode]
	and a
	ld de, .Standard
	jr z, .PlaceStr
	ld de, .Randomized
.PlaceStr
	hlcoord 8, 12
	call PlaceString
	ret
.Standard:   db "STANDARD  @"
.Randomized: db "RANDOMIZED@"

KantoChallengeOptionHandler::
; Cycles wKantoChallengeLevel through OFF, +1 .. +7 (right / left in reverse).
; Nonzero values scale Kanto gym trainer levels by badges owned and add
; extra Pokemon to each gym leader's team.
	ldh a, [hJoyPressed]
	bit B_PAD_RIGHT, a
	jr nz, .Right
	bit B_PAD_LEFT, a
	jr nz, .Left
	jr .Display
.Right:
	ld a, [wKantoChallengeLevel]
	inc a
	cp NUM_KANTO_CHALLENGE_LEVELS
	jr c, .set
	xor a
	jr .set
.Left:
	ld a, [wKantoChallengeLevel]
	and a
	jr z, .WrapLeft
	dec a
	jr .set
.WrapLeft:
	ld a, NUM_KANTO_CHALLENGE_LEVELS - 1
.set:
	ld [wKantoChallengeLevel], a
.Display:
	ld a, [wKantoChallengeLevel]
	ld e, a
	ld d, 0
	ld hl, .Strings
	add hl, de
	add hl, de
	ld a, [hli]
	ld d, [hl]
	ld e, a
	hlcoord 8, 4
	call PlaceString
	ret
.Strings:
	dw .str_off
	dw .str_1
	dw .str_2
	dw .str_3
	dw .str_4
	dw .str_5
	dw .str_6
	dw .str_7
.str_off: db "OFF @"
.str_1:   db "LV 1@"
.str_2:   db "LV 2@"
.str_3:   db "LV 3@"
.str_4:   db "LV 4@"
.str_5:   db "LV 5@"
.str_6:   db "LV 6@"
.str_7:   db "LV 7@"
