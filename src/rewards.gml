/**
 *   ----------------------------------------
 *
 *      Medals
 *
 *   ----------------------------------------
 */

// TODO those could be just one big strip
rewards_medal_bigstar = sprite_add(directory + "\images\rewards\medal_bigstar.png", 1, false, false, 0, 0);
rewards_medal_canadiumBag = sprite_add(directory + "\images\rewards\medal_canadiumBag.png", 1, false, false, 0, 0);
rewards_medal_contract = sprite_add(directory + "\images\rewards\medal_contract.png", 1, false, false, 0, 0);
rewards_medal_contract1star = sprite_add(directory + "\images\rewards\medal_contract1star.png", 1, false, false, 0, 0);
rewards_medal_contract2star = sprite_add(directory + "\images\rewards\medal_contract2star.png", 1, false, false, 0, 0);
rewards_medal_contract3star = sprite_add(directory + "\images\rewards\medal_contract3star.png", 1, false, false, 0, 0);
rewards_medal_paulaFace = sprite_add(directory + "\images\rewards\medal_paulaFace.png", 1, false, false, 0, 0);
rewards_medal_paulaStatue = sprite_add(directory + "\images\rewards\medal_paulaStatue.png", 1, false, false, 0, 0);

sprite_merge(HaxxyBadgeS, rewards_medal_bigstar)
sprite_merge(HaxxyBadgeS, rewards_medal_canadiumBag)
sprite_merge(HaxxyBadgeS, rewards_medal_contract)
sprite_merge(HaxxyBadgeS, rewards_medal_contract1star)
sprite_merge(HaxxyBadgeS, rewards_medal_contract2star)
sprite_merge(HaxxyBadgeS, rewards_medal_contract3star)
sprite_merge(HaxxyBadgeS, rewards_medal_paulaFace)
sprite_merge(HaxxyBadgeS, rewards_medal_paulaStatue)

sprite_delete(rewards_medal_bigstar)
sprite_delete(rewards_medal_canadiumBag)
sprite_delete(rewards_medal_contract)
sprite_delete(rewards_medal_contract1star)
sprite_delete(rewards_medal_contract2star)
sprite_delete(rewards_medal_contract3star)
sprite_delete(rewards_medal_paulaFace)
sprite_delete(rewards_medal_paulaStatue)

var originalMedalCount;
originalMedalCount = global.HaxxyBadgesLength;

global.HaxxyBadgesLength += 8;
global.HaxxyBadges[originalMedalCount + 0] = 'Cnt_medal_bigstar';
global.HaxxyBadges[originalMedalCount + 1] = 'Cnt_medal_canadiumBag';
global.HaxxyBadges[originalMedalCount + 2] = 'Cnt_medal_contract';
global.HaxxyBadges[originalMedalCount + 3] = 'Cnt_medal_contract1star';
global.HaxxyBadges[originalMedalCount + 4] = 'Cnt_medal_contract2star';
global.HaxxyBadges[originalMedalCount + 5] = 'Cnt_medal_contract3star';
global.HaxxyBadges[originalMedalCount + 6] = 'Cnt_medal_paulaFace';
global.HaxxyBadges[originalMedalCount + 7] = 'Cnt_medal_paulaStatue';


/**
 *   ----------------------------------------
 *
 *      Angels
 *
 *   ----------------------------------------
 */
rewards_angel_paulaStatue = sprite_add(directory + "\images\rewards\angel_paulaStatue.png", 1, false, false, 6, 6);
rewards_angel_fly = sprite_add(directory + "\images\rewards\angel_fly_strip10.png", 10, true, false, 8, 8);
rewards_angel_star1 = sprite_add(directory + "\images\rewards\angel_star1.png", 1, true, false, 8, 8);
rewards_angel_redteam = sprite_add(directory + "\images\rewards\angel_redteam.png", 1, false, false, 8, 8);
rewards_angel_blueteam = sprite_add(directory + "\images\rewards\angel_blueteam.png", 1, false, false, 8, 8);


/**
 *   ----------------------------------------
 *
 *      Gear specs
 *
 *   ----------------------------------------
 */

GEAR_PAULA_BH = "PaulaBH";

rewards_paulahead_default = sprite_add(directory + "\images\rewards\paulahead_gear\PaulaHeadDefaultS.png", 1, false, false, 4, 8);
rewards_paulahead_demoman = sprite_add(directory + "\images\rewards\paulahead_gear\PaulaHeadDemomanS.png", 1, false, false, 4, 8);
rewards_paulahead_sandwich = sprite_add(directory + "\images\rewards\paulahead_gear\PaulaHeadOmnomnomnomS_strip32.png", 32, false, false, 4, 8);
rewards_paulahead_pyro = sprite_add(directory + "\images\rewards\paulahead_gear\PaulaHeadPyroS.png", 1, false, false, 4, 8);
rewards_paulahead_pyrotaunt = sprite_add(directory + "\images\rewards\paulahead_gear\PaulaHeadPyroTauntS_strip10.png", 10, false, false, 4, 8);
rewards_paulahead_scout = sprite_add(directory + "\images\rewards\paulahead_gear\PaulaHeadScoutS.png", 1, false, false, 4, 8);
rewards_paulahead_soldiertaunt = sprite_add(directory + "\images\rewards\paulahead_gear\PaulaHeadSoldierTauntS_strip16.png", 16, false, false, 4, 8);
rewards_paulahead_spy = sprite_add(directory + "\images\rewards\paulahead_gear\PaulaHeadSpyS.png", 1, false, false, 4, 8);

var gearSpec, i;
gearSpec = gearSpecCreate();
gearSpecDefaultOverlay(gearSpec, Contracts.rewards_paulahead_default, Contracts.rewards_paulahead_default, 0);
gearSpecClassOverlay(gearSpec, CLASS_PYRO, Contracts.rewards_paulahead_pyro, Contracts.rewards_paulahead_pyro, 0);
gearSpecClassOverlay(gearSpec, CLASS_SCOUT, Contracts.rewards_paulahead_scout, Contracts.rewards_paulahead_scout, 0);
gearSpecClassOverlay(gearSpec, CLASS_DEMOMAN, Contracts.rewards_paulahead_demoman, Contracts.rewards_paulahead_demoman, 0);
gearSpecClassOverlay(gearSpec, CLASS_SPY, Contracts.rewards_paulahead_spy, Contracts.rewards_paulahead_spy, 0);

for(i=0; i<=7; i+=1) {
    gearSpecFrameOverlay(gearSpec, CLASS_PYRO, "Taunt", i, Contracts.rewards_paulahead_pyrotaunt, Contracts.rewards_paulahead_pyrotaunt, i);
}

gearSpecClassOverlayOffset(gearSpec, CLASS_SOLDIER, 0, 4);
for(i=0; i<=15; i+=1) {
    gearSpecFrameOverlay(gearSpec, CLASS_SOLDIER, "Taunt", i, Contracts.rewards_paulahead_soldiertaunt, Contracts.rewards_paulahead_soldiertaunt, i);
}
for(i=6; i<=8; i+=1) {
    gearSpecFrameOverlayOffset(gearSpec, CLASS_SOLDIER, "Taunt", i, 1, 4); // damn xscale
}

gearSpecClassOverlayOffset(gearSpec, CLASS_HEAVY, 0, 2);
for(i=0; i<=30; i+=1) {
    gearSpecFrameOverlay(gearSpec, CLASS_HEAVY, "Omnomnomnom", i, Contracts.rewards_paulahead_sandwich, Contracts.rewards_paulahead_sandwich, i);
}
gearSpecFrameOverlayOffset(gearSpec, CLASS_HEAVY, "Omnomnomnom", 6, 0, 0);
gearSpecFrameOverlayOffset(gearSpec, CLASS_HEAVY, "Omnomnomnom", 7, 0, 0);
gearSpecFrameOverlayOffset(gearSpec, CLASS_HEAVY, "Omnomnomnom", 12, 0, 0);
gearSpecFrameOverlayOffset(gearSpec, CLASS_HEAVY, "Omnomnomnom", 13, 0, 0);
gearSpecFrameOverlayOffset(gearSpec, CLASS_HEAVY, "Omnomnomnom", 18, 0, 0);
gearSpecFrameOverlayOffset(gearSpec, CLASS_HEAVY, "Omnomnomnom", 19, 0, 0);
gearSpecFrameOverlayOffset(gearSpec, CLASS_HEAVY, "Omnomnomnom", 24, 0, 0);
gearSpecFrameOverlayOffset(gearSpec, CLASS_HEAVY, "Omnomnomnom", 25, 0, 0);

gearSpecClassOverlayOffset(gearSpec, CLASS_ENGINEER, 0, 2);
gearSpecClassOverlayOffset(gearSpec, CLASS_SPY, 2, 2);

gearSpecApply(gearSpec, Contracts.GEAR_PAULA_BH);
gearSpecDestroy(gearSpec);



GEAR_DUMB_HAT = "DumbHat";
rewards_dumbhat = sprite_add(directory + "\images\rewards\hat_dumb.png", 1, false, false, 6, 2);
gearSpec = gearSpecCreate();
gearSpecDefaultOverlay(gearSpec, Contracts.rewards_dumbhat, Contracts.rewards_dumbhat, 0);
gearSpecClassOverlayOffset(gearSpec, CLASS_QUOTE, 8, -8);
gearSpecApply(gearSpec, Contracts.GEAR_DUMB_HAT);
gearSpecDestroy(gearSpec);

GEAR_FLOWER_BROOCH = "FlowerBrooch";
rewards_flower_brooch = sprite_add(directory + "\images\rewards\flower_brooch.png", 1, true, false, 4, 4);
gearSpec = gearSpecCreate();
gearSpecDefaultOverlay(gearSpec, Contracts.rewards_flower_brooch, Contracts.rewards_flower_brooch, 0);
gearSpecClassOverlayOffset(gearSpec, CLASS_QUOTE, 4, -2);
gearSpecApply(gearSpec, Contracts.GEAR_FLOWER_BROOCH);
gearSpecDestroy(gearSpec);


GEAR_PUMPKIN_EPIC = "EpicPumpkinHead";
rewards_pumpkinepic = sprite_add(directory + "\images\rewards\pumpkinheads\epic.png", 1, true, false, 2, 6);
rewards_pumpkinepic_topless = sprite_add(directory + "\images\rewards\pumpkinheads\epic_topless.png", 1, true, false, 2, 6);
rewards_pumpkinepic_open = sprite_add(directory + "\images\rewards\pumpkinheads\epic_open.png", 1, true, false, 2, 6);
gearSpec = gearSpecCreate();
gearSpecDefaultOverlay(gearSpec, Contracts.rewards_pumpkinepic, Contracts.rewards_pumpkinepic, 0);
gearSpecClassOverlayOffset(gearSpec, CLASS_SCOUT, 0, -2);
gearSpecClassOverlayOffset(gearSpec, CLASS_PYRO, 2, 0);
gearSpecClassOverlayOffset(gearSpec, CLASS_SOLDIER, 0, 0);
gearSpecClassOverlayOffset(gearSpec, CLASS_HEAVY, 0, 0);
gearSpecClassOverlayOffset(gearSpec, CLASS_DEMOMAN, 0, -2);
gearSpecClassOverlayOffset(gearSpec, CLASS_ENGINEER, 0, -2);
gearSpecClassOverlayOffset(gearSpec, CLASS_SPY, 2, 0);
gearSpecFrameOverlay(gearSpec, CLASS_HEAVY, "Omnomnomnom", 6, Contracts.rewards_pumpkinepic_open, Contracts.rewards_pumpkinepic_open, 0);
gearSpecFrameOverlay(gearSpec, CLASS_HEAVY, "Omnomnomnom", 7, Contracts.rewards_pumpkinepic_open, Contracts.rewards_pumpkinepic_open, 0);
gearSpecFrameOverlay(gearSpec, CLASS_HEAVY, "Omnomnomnom", 12, Contracts.rewards_pumpkinepic_open, Contracts.rewards_pumpkinepic_open, 0);
gearSpecFrameOverlay(gearSpec, CLASS_HEAVY, "Omnomnomnom", 13, Contracts.rewards_pumpkinepic_open, Contracts.rewards_pumpkinepic_open, 0);
gearSpecFrameOverlay(gearSpec, CLASS_HEAVY, "Omnomnomnom", 18, Contracts.rewards_pumpkinepic_open, Contracts.rewards_pumpkinepic_open, 0);
gearSpecFrameOverlay(gearSpec, CLASS_HEAVY, "Omnomnomnom", 19, Contracts.rewards_pumpkinepic_open, Contracts.rewards_pumpkinepic_open, 0);
gearSpecFrameOverlay(gearSpec, CLASS_HEAVY, "Omnomnomnom", 24, Contracts.rewards_pumpkinepic_open, Contracts.rewards_pumpkinepic_open, 0);
gearSpecFrameOverlay(gearSpec, CLASS_HEAVY, "Omnomnomnom", 25, Contracts.rewards_pumpkinepic_open, Contracts.rewards_pumpkinepic_open, 0);
gearSpecClassOverlay(gearSpec, CLASS_SNIPER, Contracts.rewards_pumpkinepic_topless, Contracts.rewards_pumpkinepic_topless, 0);
gearSpecApply(gearSpec, Contracts.GEAR_PUMPKIN_EPIC);
gearSpecDestroy(gearSpec);


GEAR_PUMPKIN_LEGENDARY = "LegendaryPumpkinHead";
rewards_pumpkinlegendary = sprite_add(directory + "\images\rewards\pumpkinheads\legendary.png", 1, true, false, 2, 6);
rewards_pumpkinlegendary_topless = sprite_add(directory + "\images\rewards\pumpkinheads\legendary_topless.png", 1, true, false, 2, 6);
rewards_pumpkinlegendary_open = sprite_add(directory + "\images\rewards\pumpkinheads\legendary_open.png", 1, true, false, 2, 6);
gearSpec = gearSpecCreate();
gearSpecDefaultOverlay(gearSpec, Contracts.rewards_pumpkinlegendary, Contracts.rewards_pumpkinlegendary, 0);
gearSpecClassOverlayOffset(gearSpec, CLASS_SCOUT, 0, -2);
gearSpecClassOverlayOffset(gearSpec, CLASS_PYRO, 2, 0);
gearSpecClassOverlayOffset(gearSpec, CLASS_SOLDIER, 0, 0);
gearSpecClassOverlayOffset(gearSpec, CLASS_HEAVY, 0, 0);
gearSpecClassOverlayOffset(gearSpec, CLASS_DEMOMAN, 0, -2);
gearSpecClassOverlayOffset(gearSpec, CLASS_ENGINEER, 0, -2);
gearSpecClassOverlayOffset(gearSpec, CLASS_SPY, 2, 0);
gearSpecFrameOverlay(gearSpec, CLASS_HEAVY, "Omnomnomnom", 6, Contracts.rewards_pumpkinlegendary_open, Contracts.rewards_pumpkinlegendary_open, 0);
gearSpecFrameOverlay(gearSpec, CLASS_HEAVY, "Omnomnomnom", 7, Contracts.rewards_pumpkinlegendary_open, Contracts.rewards_pumpkinlegendary_open, 0);
gearSpecFrameOverlay(gearSpec, CLASS_HEAVY, "Omnomnomnom", 12, Contracts.rewards_pumpkinlegendary_open, Contracts.rewards_pumpkinlegendary_open, 0);
gearSpecFrameOverlay(gearSpec, CLASS_HEAVY, "Omnomnomnom", 13, Contracts.rewards_pumpkinlegendary_open, Contracts.rewards_pumpkinlegendary_open, 0);
gearSpecFrameOverlay(gearSpec, CLASS_HEAVY, "Omnomnomnom", 18, Contracts.rewards_pumpkinlegendary_open, Contracts.rewards_pumpkinlegendary_open, 0);
gearSpecFrameOverlay(gearSpec, CLASS_HEAVY, "Omnomnomnom", 19, Contracts.rewards_pumpkinlegendary_open, Contracts.rewards_pumpkinlegendary_open, 0);
gearSpecFrameOverlay(gearSpec, CLASS_HEAVY, "Omnomnomnom", 24, Contracts.rewards_pumpkinlegendary_open, Contracts.rewards_pumpkinlegendary_open, 0);
gearSpecFrameOverlay(gearSpec, CLASS_HEAVY, "Omnomnomnom", 25, Contracts.rewards_pumpkinlegendary_open, Contracts.rewards_pumpkinlegendary_open, 0);
gearSpecClassOverlay(gearSpec, CLASS_SNIPER, Contracts.rewards_pumpkinlegendary_topless, Contracts.rewards_pumpkinlegendary_topless, 0);
gearSpecApply(gearSpec, Contracts.GEAR_PUMPKIN_LEGENDARY);
gearSpecDestroy(gearSpec);


/**
 *   ----------------------------------------
 *
 *      Hooks and scripts
 *
 *   ----------------------------------------
 */

updatePlayerRewardsScript = '
    var player, current_rewards, total_rewards;
    player = argument0;
    
    if (string_length(player.contracts__rewards_string) <= 0) {
        exit;
    }
    
    current_rewards = unparseRewards(player.rewards);
    if (string_length(current_rewards) > 0) {
        total_rewards = current_rewards + ":" + player.contracts__rewards_string;
    } else {
        total_rewards = player.contracts__rewards_string;
    }
    
    if (current_rewards != total_rewards) {    
        sendEventUpdateRewards(player, total_rewards);
        doEventUpdateRewards(player, total_rewards);
    }
';


object_event_add(Player, ev_create, 0, '
    contracts__rewards_string = "";
');
with(Player) {
    contracts__rewards_string = "";
}

object_event_add(RewardAuthChecker, ev_create, 0, '
    contracts__was_doing_player = noone;
');
with(RewardAuthChecker) {
    contracts__was_doing_player = noone;
}
object_event_add(RewardAuthChecker, ev_step, ev_step_normal, '
    if (contracts__was_doing_player == noone) exit;
    if (currentPlayer == noone) {
        // just finished doing it for this player
        execute_string(Contracts.updatePlayerRewardsScript, contracts__was_doing_player);
    }
    contracts__was_doing_player = currentPlayer;
');

/**
 *   ----------------------------------------
 *
 *      Apply rewards
 *
 *   ----------------------------------------
 */

object_event_add(Character, ev_create, 0, '
    if(
       !hasClassReward(player, "BH") and !hasClassReward(player, "TopHatMonocle_") and !hasClassReward(player, "TopHat_")
    ) {
		if (hasClassReward(player, "Cnt_PH") and player.class != CLASS_QUOTE) {
			ds_list_insert(gearList, 0, Contracts.GEAR_PAULA_BH);
		} else if (hasClassReward(player, "Cnt_Pumpkin2") and player.class != CLASS_QUOTE) {
			ds_list_insert(gearList, 0, Contracts.GEAR_PUMPKIN_LEGENDARY);
		} else if (hasClassReward(player, "Cnt_Pumpkin1") and player.class != CLASS_QUOTE) {
			ds_list_insert(gearList, 0, Contracts.GEAR_PUMPKIN_EPIC);
		} else if (hasReward(player, "Cnt_DumbHat") and player.class == CLASS_QUOTE) {
			ds_list_insert(gearList, 0, Contracts.GEAR_DUMB_HAT);
		}
    }
	if (hasReward(player, "Cnt_FlowerBrooch") and player.class == CLASS_QUOTE) {
		ds_list_insert(gearList, 0, Contracts.GEAR_FLOWER_BROOCH);
		ds_list_add(gearList, Contracts.GEAR_FLOWER_BROOCH);
	}
	
    if (hasReward(player, "Cnt_angel_pstatue"))
    {
        demon = Contracts.rewards_angel_paulaStatue;
    }
    else if (hasReward(player, "Cnt_angel_star1"))
    {
        demon = Contracts.rewards_angel_star1;
    }
    else if (hasReward(player, "Cnt_angel_fly"))
    {
        demon = Contracts.rewards_angel_fly;
    }
    else if (hasReward(player, "Cnt_angel_teamicon"))
    {
		if (player.team == TEAM_RED) {
			demon = Contracts.rewards_angel_redteam;
		} else {
			demon = Contracts.rewards_angel_blueteam;
		}
    }
');