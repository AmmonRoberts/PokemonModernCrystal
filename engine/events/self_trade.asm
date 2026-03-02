; Self-Trade: allows the player to evolve a Pokémon that normally
; requires trading, without needing a link cable partner.

SelfTrade::
; Ask the player if they want to trade-evolve a Pokémon
	ld hl, SelfTradeIntroText
	call PrintText

	call YesNoBox
	jr c, .refused

; Open the party menu to select a Pokémon
	ld b, PARTYMENUACTION_GIVE_MON
	farcall SelectTradeOrDayCareMon
	jr c, .cancelled

; Temporarily set wLinkMode so the evolution engine's trade check passes.
; EvolvePokemon (in bank $10) reads the evo data from EvosAttacksPointers
; (also in bank $10), so we don't need to check it ourselves.
	ld a, LINK_TRADECENTER
	ld [wLinkMode], a

; Set wForceEvolution to 0 so level/happiness evos don't accidentally trigger.
	xor a
	ld [wForceEvolution], a

; Disable sprite updates so the NPC sprite doesn't render over the
; evolution screen.
	call DisableSpriteUpdates

; Call EvolvePokemon — it reads wCurPartyMon and attempts evolution.
; If the mon has EVOLVE_TRADE, the evolution animation plays automatically.
	farcall EvolvePokemon

; Restore wLinkMode to normal.
	xor a
	ld [wLinkMode], a

; Restore the overworld graphics, sprites, and textbox that the
; evolution animation clobbered.
	call ReturnToMapWithSpeechTextbox

; Check if evolution actually happened.
; wMonTriedToEvolve is 1 if the mon had a matching evo entry (even if
; the player cancelled). If it's 0, the mon can't evolve by trade at all.
	ld a, [wMonTriedToEvolve]
	and a
	jr z, .cant_evolve

; The mon matched a trade evo. Check if the player cancelled it.
	ld a, [wEvolutionCanceled]
	and a
	jr nz, .evo_cancelled

; Evolution happened — restart map music (EvolvePokemon skips this
; when wLinkMode is nonzero, so we handle it here).
	call RestartMapMusic

	ld hl, SelfTradeSuccessText
	call PrintText
	ret

.evo_cancelled
	call RestartMapMusic

	ld hl, SelfTradeEvoCancelledText
	call PrintText
	ret

.cant_evolve
	ld hl, SelfTradeCantEvolveText
	call PrintText
	ret

.cancelled
	ld hl, SelfTradeCancelText
	call PrintText
	ret

.refused
	ld hl, SelfTradeRefusedText
	call PrintText
	ret

SelfTradeIntroText:
	text "I've developed a"
	line "technique to make"
	cont "#MON evolve"

	para "even without a"
	line "trade partner!"

	para "Want me to try it"
	line "on one of your"
	cont "#MON?"
	done

SelfTradeCantEvolveText:
	text "Hmm, that #MON"
	line "can't evolve by"
	cont "trading."

	para "Make sure it isn't"
	line "holding an"
	cont "EVERSTONE and"

	para "that it has the"
	line "right held item"
	cont "if it needs one!"
	done

SelfTradeCancelText:
	text "Changed your mind?"
	line "Come back anytime!"
	done

SelfTradeEvoCancelledText:
	text "Looks like it"
	line "didn't want to"
	cont "evolve."

	para "Feel free to try"
	line "again anytime!"
	done

SelfTradeRefusedText:
	text "No? Well, if you"
	line "ever need help"
	cont "evolving a "

	para "#MON, you"
	line "know where to"
    cont "find me!"
	done

SelfTradeSuccessText:
	text "There you go!"

	para "Your #MON has"
	line "evolved! Pretty"
	cont "neat, huh?"
	done
