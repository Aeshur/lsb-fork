-----------------------------------
-- Scholar Artifact
-----------------------------------
-- Loussaire           (Bastok Markets [S])        : !pos -248.677 -8.523 -125.734 87
-- Indescript Markings (Fort Karugo-Narugo [S])    : !pos 17.307 -19.000 709.963 96
-- Indescript Markings (Meriphataud Mountains [S]) : !pos -358.657 -8.012 98.512 97
-- Indescript Markings (Pashhow Marshlands [S])    : !pos 488.559 24.999 511.700 90
-- Indescript Markings (Pashhow Marshlands [S])    : !pos 374.099 25.143 -101.182 90
-- Indescript Markings (Vunkerl Inlet [S])         : !pos -629.179 -49.002 -429.104 83
-- Indescript Markings (Grauberg [S])              : !pos -471.837 -167.040 222.193 89
-----------------------------------
local pashhowID  = zones[xi.zone.PASHHOW_MARSHLANDS_S]
local graubergID = zones[xi.zone.GRAUBERG_S]
-----------------------------------

local quest = HiddenQuest:new('SchArtifact')

local artifactOptions =
{
    loafers = 1,
    pants   = 2,
    gown    = 3,
}

local scholarArtifacts =
{
    [artifactOptions.loafers] =
    {
        item = xi.item.SCHOLARS_LOAFERS,
        keyItems =
        {
            xi.ki.RAFFLESIA_DREAMSPIT,
            xi.ki.DROGAROGAN_BONEMEAL,
        },
    },

    [artifactOptions.pants] =
    {
        item = xi.item.SCHOLARS_PANTS,
        keyItems =
        {
            xi.ki.SLUG_MUCUS,
            xi.ki.DJINN_EMBER,
        },
    },

    [artifactOptions.gown] =
    {
        item = xi.item.SCHOLARS_GOWN,
        keyItems =
        {
            xi.ki.PEISTE_DUNG,
            xi.ki.SAMPLE_OF_GRAUBERG_CHERT,
        },
    },
}

local previewOptions =
{
    [2] = artifactOptions.loafers,
    [4] = artifactOptions.pants,
    [6] = artifactOptions.gown,
}

local selectionOptions =
{
    [1] = artifactOptions.loafers,
    [3] = artifactOptions.pants,
    [5] = artifactOptions.gown,
}

local rewardCutscenes =
{
    [0] = 51,
    [1] = 52,
    [2] = 54,
}

local fortKarugoPositions =
{
    { -72.612, -27.5,  671.24 }, -- G-5 NE
    { -158,    -61.5,  268    }, -- G-7
    { -2,      -52,    235    }, -- H-8
    { 224,     -32.25, -22    }, -- I-10
    { 210,     -42.75, -78    }, -- I-9
    { -176,    -37,    617    }, -- G-5 SW
    { 29,      -13.5,  710    }, -- H-5
}

local pashhowPantsPositions =
{
    {  508, 22, 586 }, -- K-5 N
    {  543, 22, 478 }, -- K-5 SE
    {  484, 24, 502 }, -- K-5
    {  371, 24, 420 }, -- J-6
    {  226, 25, 316 }, -- I-6
    {   92, 24, 140 }, -- I-7
    { -226, 25, 428 }, -- G-6 NW
    { -135, 24, 374 }, -- G-6 E
}

local pashhowGownPositions =
{
    { 404, 24,   53 }, -- K-8
    { 421, 24, -101 }, -- K-9, south of Cavernous Maw
    { 380, 25, -116 }, -- J-9, just east of the Telepoint
    { 411, 25, -292 }, -- K-10
    { 353, 25, -218 }, -- J-10, just south of the Veridical Conflux
    { 245, 25, -258 }, -- I-10, border of I and J, just south of the road
    { -76, 25, -203 }, -- H-10, NW corner, just south of the road
    {  32, 25, -238 }, -- H-10, between road and wall edge
    {  59, 25, -326 }, -- H-10, SE corner, just south of the road
}

local graubergPositions =
{
    { -517, -167, 209 },
    { -492, -168, 190 },
    { -464, -166, 241 },
    { -442, -156, 182 },
    { -433, -151, 162 },
    { -416, -143, 146 },
    { -535, -167, 227 },
    { -513, -170, 255 },
}

local markingData =
{
    fortKarugo =
    {
        option = artifactOptions.loafers,
        keyItem = xi.ki.RAFFLESIA_DREAMSPIT,
        removeSneak = true,
        positions = fortKarugoPositions,
    },

    meriphataud =
    {
        option = artifactOptions.loafers,
        keyItem = xi.ki.DROGAROGAN_BONEMEAL,
        removeSneak = true,
    },

    pashhowPants =
    {
        option = artifactOptions.pants,
        keyItem = xi.ki.SLUG_MUCUS,
        hide = 900,
        positions = pashhowPantsPositions,
    },

    pashhowGown =
    {
        option = artifactOptions.gown,
        keyItem = xi.ki.PEISTE_DUNG,
        positions = pashhowGownPositions,
    },

    vunkerl =
    {
        option = artifactOptions.pants,
        keyItem = xi.ki.DJINN_EMBER,
        removeSneak = true,
        hide = 60,
    },

    grauberg =
    {
        option = artifactOptions.gown,
        keyItem = xi.ki.SAMPLE_OF_GRAUBERG_CHERT,
        removeSneak = true,
        positions = graubergPositions,
    },
}

local function hasBothKeyItems(player, option)
    local keyItems = scholarArtifacts[option].keyItems

    return player:hasKeyItem(keyItems[1]) and player:hasKeyItem(keyItems[2])
end

local function hasCompletedArtifact(player, option)
    return utils.mask.getBit(quest:getVar(player, 'Completed'), option - 1)
end

local function uncoverMarking(player, npc, marking)
    if marking.removeSneak then
        player:delStatusEffect(xi.effect.SNEAK)
    end

    if
        quest:getVar(player, 'Option') ~= marking.option or
        player:hasKeyItem(marking.keyItem)
    then
        return
    end

    if marking.hide then
        npc:hideNPC(marking.hide)
    end

    if marking.positions then
        local newPosition = npcUtil.pickNewPosition(npc:getID(), marking.positions)
        npc:setPos(newPosition.x, newPosition.y, newPosition.z)
    end

    return quest:keyItem(marking.keyItem)
end

local function selectArtifact(player, csid, option, npc)
    local previewOption = previewOptions[option]
    local selectedOption = selectionOptions[option]

    if previewOption then
        local keyItems = scholarArtifacts[previewOption].keyItems

        player:updateEvent(option, keyItems[1], keyItems[2], 0, 0, 0, 0, 0)
    elseif selectedOption and not hasCompletedArtifact(player, selectedOption) then
        quest:setVar(player, 'Option', selectedOption)
    end
end

local function giveArtifact(player, csid, option, npc)
    local questOption = quest:getVar(player, 'Option')

    if questOption == 0 then
        return
    end

    local artifact = scholarArtifacts[questOption]

    if npcUtil.giveItem(player, artifact.item) then
        player:delKeyItem(artifact.keyItems[1])
        player:delKeyItem(artifact.keyItems[2])
        quest:setVarBit(player, 'Completed', questOption - 1)
        quest:setVar(player, 'Option', 0)
    end
end

quest.sections =
{
    {
        check = function(player, questVars, vars)
            return player:hasCompletedQuest(xi.questLog.CRYSTAL_WAR, xi.quest.id.crystalWar.DOWNWARD_HELIX) and
                questVars.Completed ~= 7
        end,

        [xi.zone.BASTOK_MARKETS_S] =
        {
            ['Loussaire'] =
            {
                onTrigger = function(player, npc)
                    local option = quest:getVar(player, 'Option')

                    if option > 0 and not hasBothKeyItems(player, option) then
                        local artifact = scholarArtifacts[option]

                        return quest:progressEvent(50, artifact.item, artifact.keyItems[1], artifact.keyItems[2])
                    elseif
                        player:getMainJob() == xi.job.SCH and
                        player:getMainLvl() >= xi.settings.main.AF2_QUEST_LEVEL
                    then
                        if option > 0 then
                            local completedCount = utils.mask.countBits(quest:getVar(player, 'Completed'), 3)
                            local rewardEventId = rewardCutscenes[completedCount]

                            return quest:progressEvent(rewardEventId, scholarArtifacts[option].item)
                        else
                            local menuEvent = quest:getVar(player, 'Prog') == 0 and 49 or 53

                            return quest:progressEvent(menuEvent, quest:getVar(player, 'Completed'))
                        end
                    end
                end,
            },

            onEventUpdate =
            {
                [49] = selectArtifact,
                [53] = selectArtifact,
            },

            onEventFinish =
            {
                [49] = function(player, csid, option, npc)
                    if option == 0 then
                        quest:setVar(player, 'Prog', 1)
                    end
                end,

                [51] = giveArtifact,
                [52] = giveArtifact,
                [54] = giveArtifact,
            },
        },
    },

    {
        check = function(player, questVars, vars)
            return questVars.Option > 0
        end,

        [xi.zone.FORT_KARUGO_NARUGO_S] =
        {
            ['Indescript_Markings'] =
            {
                onTrigger = function(player, npc)
                    return uncoverMarking(player, npc, markingData.fortKarugo)
                end,
            },
        },

        [xi.zone.MERIPHATAUD_MOUNTAINS_S] =
        {
            ['Indescript_Markings'] =
            {
                onTrigger = function(player, npc)
                    return uncoverMarking(player, npc, markingData.meriphataud)
                end,
            },
        },

        [xi.zone.PASHHOW_MARSHLANDS_S] =
        {
            ['Indescript_Markings'] =
            {
                onTrigger = function(player, npc)
                    local offset = npc:getID() - pashhowID.npc.INDESCRIPT_MARKINGS_OFFSET

                    if offset == 1 then
                        return uncoverMarking(player, npc, markingData.pashhowPants)
                    elseif offset == 2 then
                        return uncoverMarking(player, npc, markingData.pashhowGown)
                    end
                end,
            },
        },

        [xi.zone.VUNKERL_INLET_S] =
        {
            ['Indescript_Markings'] =
            {
                onTrigger = function(player, npc)
                    return uncoverMarking(player, npc, markingData.vunkerl)
                end,
            },
        },

        [xi.zone.GRAUBERG_S] =
        {
            ['Indescript_Markings'] =
            {
                onTrigger = function(player, npc)
                    -- The second Grauberg markings are a battlefield entrance.
                    if npc:getID() == graubergID.npc.INDESCRIPT_MARKINGS then
                        return uncoverMarking(player, npc, markingData.grauberg)
                    end
                end,
            },
        },
    },
}

return quest
