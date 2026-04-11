_RollWildHeldItem::
; Rolls the item a wild Pokemon carries at the start of battle.
; Result written directly to wEnemyMonItem (farcall doesn't preserve a).
;
; Standard roll (always runs unless the mod roll fires):
;   75% NO_ITEM  /  ~23% Item1  /  ~2% Item2
;   If MODFLAG_WILD_HELD_ITEM_RAND_F is set, Item1/Item2 are replaced
;   with a random item drawn from RandomizableItems.
;
; Mod roll (MODFLAG_WILD_HELD_ITEM_MOD_F, only when Item3 != NO_ITEM):
;   Runs independently before the standard roll. If it produces an item,
;   the standard roll is skipped entirely; otherwise the standard roll
;   proceeds as normal.
;   75% skip  /  ~15% Item3  /  ~10% Item4
; Check Item3/Item4 (mod roll, only when MODFLAG_WILD_HELD_ITEM_MOD_F is set)
	ld a, [wModFlags]
	bit MODFLAG_WILD_HELD_ITEM_MOD_F, a
	jr z, .standard_roll
	ld a, [wBaseItem3]
	and a              ; NO_ITEM? (skip mod roll if no Item3)
	jr z, .standard_roll
	call BattleRandom
	cp 75 percent + 1  ; < 193: skip mod roll (~75%)
	jr c, .standard_roll
	call BattleRandom
	cp 40 percent      ; ~10% Item4, ~15% Item3
	ld a, [wBaseItem3]
	jr nc, .mod_done   ; Item3 on most rolls
	ld a, [wBaseItem4]
.mod_done:
	ld [wEnemyMonItem], a
	ret
.standard_roll:
	call BattleRandom
	cp 75 percent + 1
	jr nc, .roll_item  ; >= 25%: give item
	xor a              ; NO_ITEM
	ld [wEnemyMonItem], a
	ret
.roll_item:
	ld a, [wModFlags]
	bit MODFLAG_WILD_HELD_ITEM_RAND_F, a
	jr nz, .rand_item
	; Standard: ~2% Item2, ~23% Item1
	call BattleRandom
	cp 8 percent       ; 8% of 25% = 2% Item2
	ld a, [wBaseItem1]
	jr nc, .done       ; Item1 on most rolls
	ld a, [wBaseItem2]
	jr .done
.rand_item:
	call BattleRandom
	; Reduce to [0, NUM_RANDOMIZABLE_ITEMS) via subtraction loop
	ld e, a
.clamp:
	ld a, e
	cp NUM_RANDOMIZABLE_ITEMS
	jr c, .index_ok
	sub NUM_RANDOMIZABLE_ITEMS
	ld e, a
	jr .clamp
.index_ok:
	ld d, 0
	ld hl, RandomizableItems
	add hl, de
	ld a, BANK(RandomizableItems)
	call GetFarByte
.done:
	ld [wEnemyMonItem], a
	ret

_TryDropWildItemCore::
; If MODFLAG_WILD_ITEM_DROP_F is set and the wild #MON held an item,
; add that item to the player's bag (or PC if the bag is full).
; Called via farcall from TryDropWildItem (home bank).
	ld a, [wModFlags]
	bit MODFLAG_WILD_ITEM_DROP_F, a
	ret z
	ld a, [wEnemyMonItem]
	and a                         ; NO_ITEM = 0
	ret z
	ld [wCurItem], a
	ld [wNamedObjectIndex], a
	call GetItemName              ; puts item name into wStringBuffer1
	ld a, 1
	ld [wItemQuantityChange], a
	ld hl, wNumItems
	call ReceiveItem              ; try bag first
	jr c, .got_bag
	ld hl, wNumPCItems
	call ReceiveItem              ; bag full — try PC
	jr c, .got_pc
	ld hl, BattleText_WildItemDropFull ; bag and PC both full — notify
	jp StdBattleTextbox
.got_bag:
	ld hl, BattleText_WildItemDropBag
	jp StdBattleTextbox
.got_pc:
	ld hl, BattleText_WildItemDropPC
	jp StdBattleTextbox
