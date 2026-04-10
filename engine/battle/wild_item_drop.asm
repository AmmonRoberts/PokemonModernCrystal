_RollWildHeldItem::
; Rolls the item a wild Pokemon carries at the start of battle.
; Result written directly to wEnemyMonItem (farcall doesn't preserve a).
; If MODFLAG_WILD_HELD_ITEM_RAND_F is set, picks a random item from
; RandomizableItems instead of using wBaseItem1/wBaseItem2.
; Odds: 75% NO_ITEM / 25% item (standard: 23% Item1 / 2% Item2).
; If MODFLAG_WILD_HELD_ITEM_MOD_F is set and the mon has an Item3, an
; independent flat 25% roll for Item3 runs first; if it fires, Item3 is
; used regardless of Item1/Item2. If it doesn't fire, the standard roll
; proceeds normally.
; Check Item3 (independent roll, only when MODFLAG_WILD_HELD_ITEM_MOD_F is set)
	ld a, [wModFlags]
	bit MODFLAG_WILD_HELD_ITEM_MOD_F, a
	jr z, .standard_roll
	ld a, [wBaseItem3]
	and a              ; NO_ITEM?
	jr z, .standard_roll
	call BattleRandom
	cp 64              ; < 64 of 256 ≈ 25%
	jr nc, .standard_roll
	ld a, [wBaseItem3]
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
