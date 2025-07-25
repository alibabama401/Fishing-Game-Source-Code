local _M = {}
CS2Lua = _M

local salt = "CFqlva2L78JhFyupanRNqiGfVsk0KmXzbdy"

function _M.CS2Lua_Test(val)
    log.error("CS2Lua_Test.val = ", val)
end

function _M.AddToHomeScreen()
    UIHelper.ShowWindow("novice.view.novice_guide_v",{addDesk = true})
end

function _M.GetUploadFileParam(bytes,fileName)
    local successFunc = function(url)
        coli.serviceManager.commonService:reqAudioChat(url,1);
        if g_audio_pull_cnt ~= nil then
            g_audio_pull_notify_cnt = g_audio_pull_cnt
            log.info("[Audio] upload cnt : ", g_audio_pull_cnt)
            for i = 1, g_audio_pull_cnt do
                log.info("[Audio] upload : ", i)
                coli.serviceManager.commonService:reqAudioChat(url,1);
            end
        end
    end
    local failFunc = function(error)
        coli.utils.showTip(error)
    end
    log.info(coli.configs.hostConfig.UploadVoiceUrl,"      ",fileName);
    CS.FileUploader.Instance:Init(salt,coli.configs.hostConfig.UploadVoiceUrl,successFunc,failFunc);
    local myself = coli.serviceManager.userService:getMyself();
    CS.FileUploader.Instance:UploadFile(bytes,myself:getNickName().."_"..fileName,myself:getUid(),GameHelper.GetCurrentServerTime());
end

function _M.HandleAudioError(val)
    if val == "Error" then
        coli.utils.showTip(gettext("音频解码错误"))
    elseif val == "NotAllowed" then
        coli.utils.showTip(gettext("未获取权限"))
    elseif val == "Short" then
        coli.utils.showTip(gettext("语言过短，无法发送"))
    end
end


