
--[[
    Lua运行主入口
    
    完成游戏库的初始化、基础配置设置。
--]]


-- global
---@class coli
---@field public serviceManager ServiceManager
_G.coli = {}; -- 统一命名空间，防止命名污染
_G.Unity = CS.UnityEngine; -- 缩短调用CS.UnityEngine
_G.Tweening = CS.DG.Tweening; -- 缩短调用CS.DG.Tweening
_G.EasyTouch = CS.HedgehogTeam.EasyTouch.EasyTouch; -- 缩短调用CS.HedgehogTeam.EasyTouch.EasyTouch
_G.Runtime = CS.Runtime; -- 缩短调用CS.Runtime
_G.Localization = require("libs.localization"); -- 本地化库
_G.ClientHelper = CS.ClientHelper
_G.LuaTool = CS.LuaTool
if ClientHelper.IsWebGL() then
    _G.cjson = require ("rapidjson");
    print("rapidjson   ",_G.cjson);
else
    _G.cjson = require ("cjson");
    print("cjson   ",_G.cjson);
end
_G.ColiSDK = CS.ColiSDK;

-- 添加Lua文件搜索路径
LuaTool.AddSearchPath("logics");

--[[
    init
--]]

if Runtime.Platform.IsEditor()then
    local emmyLuaPath = os.getenv("EmmyLuaPath")
    if emmyLuaPath then
        package.cpath = package.cpath .. ";"..emmyLuaPath..'/debugger/emmy/windows/x64/?.dll'
        local dbg = require('emmy_core')
        dbg.tcpListen('localhost', 9966)
    end
end

require("utils.class");
require("utils.log");
require("utils.utils");
require("utils.tableex");
require("utils.stringex");
require("utils.mathex");
require("libs.es.es");
require("libs.ui.ui");
require("libs.ui.ui_color");
require("utils.res_manager");
require("utils.res_sprite_atlas");
require("utils.pbutils");
require("utils.net_service");
require("utils.scheduler");  -- 定时器
require("utils.audio_manager");
require("utils.database");
require("utils.async_image_download");
require("utils.checker");
require("utils.resolution");
require("utils.tip_manager")
require("utils.timing");
require("utils.promise");
require("utils.cardtype_download");
require("utils.pop_msg_manager");
require("utils.red_dot_manager");
require("utils.protocolLoding");
require("utils.net_server_status_detector");

-- 服务管理
require("services.service_manager");

-- logics consts
require("consts.default_consts");
require("consts.events");
require("consts.assetbundle");
require("consts.assetbundle_path");
require("consts.audios");
require("consts.backcmds");

-- SDK 
require("sdk.sdk_main");
require("sdk.sdk_event_info");

require("utils.Helpers.UnityHelper")

require("CS2Lua")

require("GameRequire")

-- cs协程
local cs_coroutine = require("utils.cs_coroutine");
coli.cs_coroutine = cs_coroutine;
local pauseTime; -- 应用暂停时间

-- 由CS发起的事件通知都会调用该函数
_G.on_handle_internal_event = function(event, params)
    print("on_handle_internal_event", event, params);
    if event == "E_Sys_LowMemoryWarning" then -- 出现内存警告，强制进行一次GC
        print("E_Sys_LowMemoryWarning GC")
        Runtime.ResourceModule.GC(true);
    elseif event == "E_Sys_SwitchLanguage" then
        Localization.changeLanguage();
    elseif event == "E_Sys_OpenURL" then
        print("AppLinks url", params);
    elseif event == "E_Editor_PlayModeChanged" then
        print("E_Editor_PlayModeChanged", params);
        if params == "ExitingPlayMode" then
            local connector = coli.netService.getDefaultConnector();
            if connector and connector:isConnected() then
                connector:close();
            end
        end
    end
end

-- 定义用于搜索多语言替换文本
_G._ = function(str) return str; end;

-- 替换print
_G.print = coli.log.debug;

-- 私有访问权限
xlua.private_accessible(Runtime.LocalizationText);
xlua.private_accessible(Runtime.LuaFSVListView);
xlua.private_accessible(Runtime.LuaFSVListViewCell);
xlua.private_accessible(Runtime.LuaFSVPageView);
xlua.private_accessible(Runtime.LuaFSVPageViewCell);
xlua.private_accessible(Runtime.LuaFSVGridView);
xlua.private_accessible(Runtime.LuaFSVGridViewCell);

--[[
    main
--]]
function awake()
end

function start()
    -- 防止手机自动锁屏
    Unity.Screen.sleepTimeout = Unity.SleepTimeout.NeverSleep;

    -- 防止切换场景被删除
    Unity.Object.DontDestroyOnLoad(self.gameObject);

    -- 初始化日志系统
    coli.log.init();

    coli.netServerStatusDetector = NetServerStatusDetector.new()

    -- 加载所有protobuf文件
    coli.cs_coroutine.start(function()
        Localization.changeLanguage();

        -- 加载音频
        log.info("加载音频");
        coroutine.yield(coli.audioManager.loadCommonAudios());

        log.info("加载通用资源");
        -- 加载通用资源
        coroutine.yield(coli.resManager.loadCommonRes());
        
        log.info("加载Proto");
        local loader = coli.resManager.loadAssetBundleAsync(coli.ab.E_Proto_Prefabs);
        while not loader.IsCompleted do
            coroutine.yield(nil);
        end

        log.info("加载Proto完成");

        if loader.IsSuccess then
            log.info("加载协议....");
            coli.pbutils.loadAllProtos({
                "dz.proto.bytes",
                "head.proto.bytes",
                "XGameComm.proto.bytes",
                "CommonCode.proto.bytes",
                "CommonStruct.proto.bytes",
                "login.proto.bytes",
                "XGameKo.proto.bytes",
                "UserInfo.proto.bytes",
                "XGameQs.proto.bytes",
                "XGamePr.proto.bytes",
                "XGameAi.proto.bytes",
                "config.proto.bytes",
                "Friends.proto.bytes",
                "Chat.proto.bytes",
                "RankBoard.proto.bytes",
                "mail.proto.bytes",
                "mall.proto.bytes",
                "match.proto.bytes",
                "SignIn.proto.bytes",
                "Lottery.proto.bytes",
                "Task.proto.bytes",
                "XGameHttp.proto.bytes",
                "GameRecord.proto.bytes",
                "push.proto.bytes",
                "Order.proto.bytes",
                "UserState.proto.bytes",
                "nickname.proto.bytes",
                "hall.proto.bytes",
                "XGameSNG.proto.bytes", -- SNG 单人锦标赛房间协议
                "XGameMTT.proto.bytes", -- MTT 多人锦标赛房间协议
                "safes.proto.bytes",    -- 保险箱
                "scratch.proto.bytes",  -- 活动服相关协议-刮刮乐、SNG成就信息
                "activity.proto.bytes", -- 活动服相关协议-宝箱
                "Club.proto.bytes", -- 俱乐部
            });
            
            -- 加载配置
            log.info("加载配置");
            coroutine.yield(Unity.WaitForEndOfFrame());
            require("configs.config_init");

            CS.FileUploader.Instance.url = coli.configs.hostConfig.UploadVoiceUrl;

            -- 注册所有服务
            log.info("注册所有服务");
            local CommonService = require("services.common_service");
            local GameQsService = require("services.gameqs_service");
            local GamePrService = require("services.gamepr_service");
            local GameAiService = require("services.gameai_service");
            local SNGService = require("services.sng_service");
            local MTTService = require("services.mtt_service");

            local GameRecordService = require("services.game_record_service");
            local GamePlayService = require("services.gameplay_service");
            local ArenaService = require("services.arena_service");
            local KoService = require("services.ko_service");

            local LoginService = require("services.login_service");
            local UserService = require("services.user_service");
            local ConfigService = require("services.config_service");
            local FriendService = require("services.friend_service");
            local ChatService = require("services.chat_service");
            local RankService = require("services.rank_service");
            local MailService = require("services.mail_service");
            local ShopService = require("services.shop_service");
            local SignInService = require("services.signin_service");
            local LotteryService = require("services.lottery_service");
            local TaskService = require("services.task_service");
            local HttpService = require("services.http_service");
            local PushService = require("services.push_service");
            local BillingService = require("services.billing_service");
            local StateService = require("services.state_service");
            local NickNameService = require("services.nickname_service");
            local hallService = require("services.hall_service");
            local GuagualeService = require("services.guaguale_service");
            local ClubService = require("services.club_service");

            coli.serviceManager.registerService(CommonService.new(), "commonService");
            -- game service
            coli.serviceManager.registerService(GameQsService.new(), "qsService");
            coli.serviceManager.registerService(GamePrService.new(), "prService");
            coli.serviceManager.registerService(GameAiService.new(), "aiService");
            coli.serviceManager.registerService(SNGService.new(), "hsngService");
            coli.serviceManager.registerService(MTTService.new(), "hmttService");

            coli.serviceManager.registerService(GamePlayService.new(), "gameplayService");
            coli.serviceManager.registerService(GameRecordService.new(), "gameRecordService");
            coli.serviceManager.registerService(ArenaService.new(), "arenaService");
            coli.serviceManager.registerService(KoService.new(), "koService");

            -- other service
            coli.serviceManager.registerService(LoginService.new(), "loginService");
            coli.serviceManager.registerService(UserService.new(), "userService");
            coli.serviceManager.registerService(ConfigService.new(), "configService");
            coli.serviceManager.registerService(FriendService.new(), "friendService");
            coli.serviceManager.registerService(ChatService.new(), "chatService");
            coli.serviceManager.registerService(RankService.new(), "rankService");
            coli.serviceManager.registerService(MailService.new(), "mailService");
            coli.serviceManager.registerService(ShopService.new(), "shopService");
            coli.serviceManager.registerService(SignInService.new(), "signinService");
            coli.serviceManager.registerService(LotteryService.new(), "lotteryService");
            coli.serviceManager.registerService(TaskService.new(), "taskService");
            coli.serviceManager.registerService(PushService.new(), "pushService");
            coli.serviceManager.registerService(BillingService.new(), "billingService");
            coli.serviceManager.registerService(StateService.new(), "stateService");
            coli.serviceManager.registerService(NickNameService.new(), "nicknameService");
            coli.serviceManager.registerService(hallService.new(), "hallService");
            coli.serviceManager.registerService(GuagualeService.new(), "gglService");
            coli.serviceManager.registerService(ClubService.new(), "clubService");

            -- HttpService
            coli.serviceManager.httpService = HttpService;

            -- 设置默认连接器ID
            local serverInfo = Runtime.AppConfiguration.Instance:GetServerInfo();
            log.info(serverInfo.host, serverInfo.port);
            coli.netService.createConnect("0.0.0.0", 0000, true);

            local connector = coli.netService.getDefaultConnector();
            connector:onMessage(function(datas)
                local ret, packData = connector:unpack(datas);
                while true do
                    if ret then
                        coli.serviceManager.handlePacakge(packData);
                        ret, packData = connector:unpack();
                    else
                        break; -- 没包可读就马上退出循环
                    end
                end
            end);
            connector:onClose(function() 
                coli.log.debug("network connector onClose");
                print("connector info: ", connector:host(), connector:port())
                coli.utils.hideNetLoadingImmediately();
                --coli.utils.showTip(gettext("网络连接已断线"));
            end);

            -- 构建全局上下文
            require("context");
            -- UI Queue
            require("ui_queue");
            coli.uiqueue = ui.Queue.new();

            -- 运行一个场景
            local LoginScene = require("login.login_scene");
            --local HallScene = require("hall.hall_scene");
            -- coroutine.yield(Unity.WaitForSeconds(1));
            RunScene(LoginScene.new());
            log.info("进入登陆界面")
        end

        log.info("加载失败....");
    end);
end

function update()
    local dt = Unity.Time.deltaTime;

    -- 更新网络连接
    local connector = coli.netService.getDefaultConnector();
    if connector ~= nil then
        connector:tick(dt);
    end

    -- 更新调度器
    coli.scheduler.run(dt);

    -- UI Queue
    if coli.uiqueue then
        coli.uiqueue:run();
    end
end

function onApplicationFocus(isFocus)
    --if not isFocus then
    --    -- 先处理网络状态
    --    local connector = coli.netService.getDefaultConnector();
    --    if connector ~= nil then
    --        connector:onApplicationPause();
    --    end
    --
    --    pauseTime = os.time(); -- 记录暂停时间
    --    coli.eventManager.notify(coli.Events.E_Application_Pause, pauseTime);
    --    log.info("游戏暂停");
    --else
    --    if not pauseTime then return end
    --
    --    -- 先处理网络状态
    --    local connector = coli.netService.getDefaultConnector();
    --    if connector ~= nil then
    --        connector:onApplicationRecover();
    --    end
    --
    --    local costTime =  os.time() - pauseTime ; -- 计算出花费时间(秒)
    --    coli.eventManager.notify(coli.Events.E_Application_Recover, costTime);
    --    log.info("游戏恢复");
    --end
end

function onApplicationPause(isPause)
    if isPause then
        -- 先处理网络状态
        local connector = coli.netService.getDefaultConnector();
        if connector ~= nil then
            connector:onApplicationPause();
        end

        pauseTime = os.time(); -- 记录暂停时间
        coli.eventManager.notify(coli.Events.E_Application_Pause, pauseTime);
        log.info("游戏暂停");
    else
        -- 先处理网络状态
        local connector = coli.netService.getDefaultConnector();
        if connector ~= nil then
            connector:onApplicationRecover();
        end

        local costTime =  os.time() - pauseTime ; -- 计算出花费时间(秒)
        coli.eventManager.notify(coli.Events.E_Application_Recover, costTime);
        log.info("游戏恢复");
    end
end

