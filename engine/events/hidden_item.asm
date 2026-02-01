HiddenItemScript::
	callasm .RandomizeIfEnabled
	opentext
	readmem wHiddenItemID
	getitemname STRING_BUFFER_3, USE_SCRIPT_VAR
	writetext .PlayerFoundItemText
	giveitem ITEM_FROM_MEM
	iffalse .bag_full
	callasm SetMemEvent
	specialsound
	itemnotify
	sjump .finish

.bag_full
	promptbutton
	writetext .ButNoSpaceText
	waitbutton

.finish
	closetext
	end

.RandomizeIfEnabled:
	; Check if item randomizer is enabled
	ld a, [wItemRandomizer]
	and a
	ret z
	; Randomizer enabled: pick a random item
	ld a, NUM_RANDOMIZABLE_ITEMS
	call RandomRange
	ld e, a
	ld d, 0
	ld hl, RandomizableItems
	add hl, de
	ld a, BANK(RandomizableItems)
	call GetFarByte
	ld [wHiddenItemID], a
	ret

.PlayerFoundItemText:
	text_far _PlayerFoundItemText
	text_end

.ButNoSpaceText:
	text_far _ButNoSpaceText
	text_end

SetMemEvent:
	ld hl, wHiddenItemEvent
	ld a, [hli]
	ld d, [hl]
	ld e, a
	ld b, SET_FLAG
	call EventFlagAction
	ret
