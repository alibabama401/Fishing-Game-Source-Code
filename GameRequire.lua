--[[
    注册脚本
--]]
require("libs.ui.ui_color")

require("utils.game")
require("utils.enum")
require("utils.panel_config_utils")
require("utils.panel_config")
require("utils.Helpers.UIHelper")
require("utils.Helpers.language_helper")
require("utils.Helpers.panel_helper")
require("utils.Helpers.game_helper")
require("utils.Helpers.prop_helper")
require("utils.Helpers.player_prefs_helper")

require("logics.loading.LoadingConfig")

--require("activity.view.type_cell_v")
--require("activity.view.signin_cell_v")
--require("activity.view.treasure.treasure_type_cell_v")
--require("activity.view.treasure.treasure_rule_cell_v")
--require("activity.view.leaguematch.leaguematch_cell_v")
require("friends.view.friends_my_cell")
require("gameplay.view.gameplay_record_cell")
require("novice.view.recharge_record_cell")
require("shopping.view.shopping_cell")

--TODO 测试代码引入
coli.isOpenTest = Runtime.Platform.IsEditor()
if coli.isOpenTest then
    require("services.mock.mock_require")
end

require("services.model.room_info_m")
require("services.model.game_info_m")
require("services.model.sng_info_m")
require("services.model.hall_room_info_m")
require("services.model.hall_room_infos.hall_room_info_base_m")
require("services.model.hall_room_infos.hall_room_info_normal_m")
require("services.model.hall_room_infos.hall_room_info_fast_m")
require("services.model.hall_room_infos.hall_room_info_private_m")
require("services.model.hall_room_infos.hall_room_info_sng_m")

require("gameplay.core.gameplay_utils");

require("gameplay.core.assemble_functions.i_gameplay_assemble")
require("gameplay.core.assemble_functions.gameplay_pool")
require("gameplay.core.assemble_functions.gameplay_show_player_result")

require("gameplay.view.sng.gameplay_sng_info_blind_cell")

require("gameplay_minigame.igame")
require("gameplay_minigame.default_game.game.default_game")
require("gameplay_minigame.minigame_cash.game.minigame_cash")

require("gameplay_minigame.minigame_cash.game.core.minigame_gameplay_desk")
require("gameplay_minigame.minigame_cash.game.core.minigame_bet_pool")

require("gameplay_minigame.minigame_cash.game.core.assemble_functions.i_minigame_assemble")
require("gameplay_minigame.minigame_cash.game.core.assemble_functions.minigame_deal_cards")
require("gameplay_minigame.minigame_cash.game.core.assemble_functions.minigame_insurance")
require("gameplay_minigame.minigame_cash.game.core.assemble_functions.minigame_mode_sitout")
require("gameplay_minigame.minigame_cash.game.core.assemble_functions.minigame_mode_basegame")
require("gameplay_minigame.minigame_cash.game.core.assemble_functions.minigame_mode_normalgame")
require("gameplay_minigame.minigame_cash.game.core.assemble_functions.minigame_mode_plus6game")
require("gameplay_minigame.minigame_cash.game.core.assemble_functions.minigame_mode_quickgame")
require("gameplay_minigame.minigame_cash.game.core.assemble_functions.minigame_mode_snggame")
require("gameplay_minigame.minigame_cash.game.core.assemble_functions.minigame_mode_privategame")
require("gameplay_minigame.minigame_cash.game.core.assemble_functions.minigame_auto_show_buyin")
require("gameplay_minigame.minigame_cash.game.core.assemble_functions.minigame_waitbigblind")
require("gameplay_minigame.minigame_cash.game.core.assemble_functions.minigame_sit_not_enough_to_buy_gold")
require("gameplay_minigame.minigame_cash.game.core.assemble_functions.minigame_peek_cards")
require("gameplay_minigame.minigame_cash.game.core.assemble_functions.minigame_activity")
require("gameplay_minigame.minigame_cash.game.core.assemble_functions.minigame_pool")
require("gameplay_minigame.minigame_cash.game.core.assemble_functions.minigame_show_player_result")

require("gameplay_minigame.minigame_cash.game.controller.minigame_cash_desk_c")
require("gameplay_minigame.minigame_cash.game.controller.minigame_cash_base_ui_c")
require("gameplay_minigame.minigame_cash.game.view.minigame_cash_desk_v")
require("gameplay_minigame.minigame_cash.game.view.minigame_cash_base_ui_v")
require("gameplay_minigame.minigame_cash.game.view.minigame_cash_card_v")

require("gameplay_minigame.minigame_cash.panels.home.view.home_desktype_cell");
require("gameplay_minigame.minigame_cash.panels.home.view.home_singletable_cell");
require("gameplay_minigame.minigame_cash.panels.home.view.home_friendbureau_cell")
require("gameplay_minigame.minigame_cash.panels.match.view.quick_game_matching_player_head_cp")
require("gameplay_minigame.minigame_cash.panels.sng_panels.view.sng_matching_player_head_cp")