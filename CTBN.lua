--[[
 .____                  ________ ___.    _____                           __                
 |    |    __ _______   \_____  \\_ |___/ ____\_ __  ______ ____ _____ _/  |_  ___________ 
 |    |   |  |  \__  \   /   |   \| __ \   __\  |  \/  ___// ___\\__  \\   __\/  _ \_  __ \
 |    |___|  |  // __ \_/    |    \ \_\ \  | |  |  /\___ \\  \___ / __ \|  | (  <_> )  | \/
 |_______ \____/(____  /\_______  /___  /__| |____//____  >\___  >____  /__|  \____/|__|   
         \/          \/         \/    \/                \/     \/     \/                   
          \_Welcome to LuaObfuscator.com   (Alpha 0.10.8) ~  Much Love, Ferib 

]]--

local StrToNumber = tonumber;
local Byte = string.byte;
local Char = string.char;
local Sub = string.sub;
local Subg = string.gsub;
local Rep = string.rep;
local Concat = table.concat;
local Insert = table.insert;
local LDExp = math.ldexp;
local GetFEnv = getfenv or function()
	return _ENV;
end;
local Setmetatable = setmetatable;
local PCall = pcall;
local Select = select;
local Unpack = unpack or table.unpack;
local ToNumber = tonumber;
local function VMCall(ByteString, vmenv, ...)
	local DIP = 1;
	local repeatNext;
	ByteString = Subg(Sub(ByteString, 5), "..", function(byte)
		if (Byte(byte, 2) == 81) then
			repeatNext = StrToNumber(Sub(byte, 1, 1));
			return "";
		else
			local a = Char(StrToNumber(byte, 16));
			if repeatNext then
				local b = Rep(a, repeatNext);
				repeatNext = nil;
				return b;
			else
				return a;
			end
		end
	end);
	local function gBit(Bit, Start, End)
		if End then
			local Res = (Bit / (2 ^ (Start - 1))) % (2 ^ (((End - 1) - (Start - 1)) + 1));
			return Res - (Res % 1);
		else
			local Plc = 2 ^ (Start - 1);
			return (((Bit % (Plc + Plc)) >= Plc) and 1) or 0;
		end
	end
	local function gBits8()
		local a = Byte(ByteString, DIP, DIP);
		DIP = DIP + 1;
		return a;
	end
	local function gBits16()
		local a, b = Byte(ByteString, DIP, DIP + 2);
		DIP = DIP + 2;
		return (b * 256) + a;
	end
	local function gBits32()
		local a, b, c, d = Byte(ByteString, DIP, DIP + 3);
		DIP = DIP + 4;
		return (d * 16777216) + (c * 65536) + (b * 256) + a;
	end
	local function gFloat()
		local Left = gBits32();
		local Right = gBits32();
		local IsNormal = 1;
		local Mantissa = (gBit(Right, 1, 20) * (2 ^ 32)) + Left;
		local Exponent = gBit(Right, 21, 31);
		local Sign = ((gBit(Right, 32) == 1) and -1) or 1;
		if (Exponent == 0) then
			if (Mantissa == 0) then
				return Sign * 0;
			else
				Exponent = 1;
				IsNormal = 0;
			end
		elseif (Exponent == 2047) then
			return ((Mantissa == 0) and (Sign * (1 / 0))) or (Sign * NaN);
		end
		return LDExp(Sign, Exponent - 1023) * (IsNormal + (Mantissa / (2 ^ 52)));
	end
	local function gString(Len)
		local Str;
		if not Len then
			Len = gBits32();
			if (Len == 0) then
				return "";
			end
		end
		Str = Sub(ByteString, DIP, (DIP + Len) - 1);
		DIP = DIP + Len;
		local FStr = {};
		for Idx = 1, #Str do
			FStr[Idx] = Char(Byte(Sub(Str, Idx, Idx)));
		end
		return Concat(FStr);
	end
	local gInt = gBits32;
	local function _R(...)
		return {...}, Select("#", ...);
	end
	local function Deserialize()
		local Instrs = {};
		local Functions = {};
		local Lines = {};
		local Chunk = {Instrs,Functions,nil,Lines};
		local ConstCount = gBits32();
		local Consts = {};
		for Idx = 1, ConstCount do
			local Type = gBits8();
			local Cons;
			if (Type == 1) then
				Cons = gBits8() ~= 0;
			elseif (Type == 2) then
				Cons = gFloat();
			elseif (Type == 3) then
				Cons = gString();
			end
			Consts[Idx] = Cons;
		end
		Chunk[3] = gBits8();
		for Idx = 1, gBits32() do
			local Descriptor = gBits8();
			if (gBit(Descriptor, 1, 1) == 0) then
				local Type = gBit(Descriptor, 2, 3);
				local Mask = gBit(Descriptor, 4, 6);
				local Inst = {gBits16(),gBits16(),nil,nil};
				if (Type == 0) then
					Inst[3] = gBits16();
					Inst[4] = gBits16();
				elseif (Type == 1) then
					Inst[3] = gBits32();
				elseif (Type == 2) then
					Inst[3] = gBits32() - (2 ^ 16);
				elseif (Type == 3) then
					Inst[3] = gBits32() - (2 ^ 16);
					Inst[4] = gBits16();
				end
				if (gBit(Mask, 1, 1) == 1) then
					Inst[2] = Consts[Inst[2]];
				end
				if (gBit(Mask, 2, 2) == 1) then
					Inst[3] = Consts[Inst[3]];
				end
				if (gBit(Mask, 3, 3) == 1) then
					Inst[4] = Consts[Inst[4]];
				end
				Instrs[Idx] = Inst;
			end
		end
		for Idx = 1, gBits32() do
			Functions[Idx - 1] = Deserialize();
		end
		return Chunk;
	end
	local function Wrap(Chunk, Upvalues, Env)
		local Instr = Chunk[1];
		local Proto = Chunk[2];
		local Params = Chunk[3];
		return function(...)
			local Instr = Instr;
			local Proto = Proto;
			local Params = Params;
			local _R = _R;
			local VIP = 1;
			local Top = -1;
			local Vararg = {};
			local Args = {...};
			local PCount = Select("#", ...) - 1;
			local Lupvals = {};
			local Stk = {};
			for Idx = 0, PCount do
				if (Idx >= Params) then
					Vararg[Idx - Params] = Args[Idx + 1];
				else
					Stk[Idx] = Args[Idx + 1];
				end
			end
			local Varargsz = (PCount - Params) + 1;
			local Inst;
			local Enum;
			while true do
				Inst = Instr[VIP];
				Enum = Inst[1];
				if (Enum <= 28) then
					if (Enum <= 13) then
						if (Enum <= 6) then
							if (Enum <= 2) then
								if (Enum <= 0) then
									local A = Inst[2];
									Stk[A](Stk[A + 1]);
								elseif (Enum == 1) then
									local A = Inst[2];
									local Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
									Top = (Limit + A) - 1;
									local Edx = 0;
									for Idx = A, Top do
										Edx = Edx + 1;
										Stk[Idx] = Results[Edx];
									end
								else
									Stk[Inst[2]]();
								end
							elseif (Enum <= 4) then
								if (Enum == 3) then
									local A = Inst[2];
									local Results, Limit = _R(Stk[A](Stk[A + 1]));
									Top = (Limit + A) - 1;
									local Edx = 0;
									for Idx = A, Top do
										Edx = Edx + 1;
										Stk[Idx] = Results[Edx];
									end
								elseif (Stk[Inst[2]] == Inst[4]) then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							elseif (Enum == 5) then
								local A = Inst[2];
								local Results, Limit = _R(Stk[A](Stk[A + 1]));
								Top = (Limit + A) - 1;
								local Edx = 0;
								for Idx = A, Top do
									Edx = Edx + 1;
									Stk[Idx] = Results[Edx];
								end
							else
								Stk[Inst[2]][Inst[3]] = Inst[4];
							end
						elseif (Enum <= 9) then
							if (Enum <= 7) then
								local A = Inst[2];
								local Results = {Stk[A](Unpack(Stk, A + 1, Top))};
								local Edx = 0;
								for Idx = A, Inst[4] do
									Edx = Edx + 1;
									Stk[Idx] = Results[Edx];
								end
							elseif (Enum == 8) then
								VIP = Inst[3];
							else
								Stk[Inst[2]] = Upvalues[Inst[3]];
							end
						elseif (Enum <= 11) then
							if (Enum > 10) then
								Stk[Inst[2]] = Inst[3];
							else
								local A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							end
						elseif (Enum == 12) then
							Stk[Inst[2]] = Inst[3] ~= 0;
						else
							Stk[Inst[2]] = Upvalues[Inst[3]];
						end
					elseif (Enum <= 20) then
						if (Enum <= 16) then
							if (Enum <= 14) then
								Stk[Inst[2]] = Inst[3] ~= 0;
							elseif (Enum > 15) then
								Stk[Inst[2]] = Env[Inst[3]];
							else
								local NewProto = Proto[Inst[3]];
								local NewUvals;
								local Indexes = {};
								NewUvals = Setmetatable({}, {__index=function(_, Key)
									local Val = Indexes[Key];
									return Val[1][Val[2]];
								end,__newindex=function(_, Key, Value)
									local Val = Indexes[Key];
									Val[1][Val[2]] = Value;
								end});
								for Idx = 1, Inst[4] do
									VIP = VIP + 1;
									local Mvm = Instr[VIP];
									if (Mvm[1] == 20) then
										Indexes[Idx - 1] = {Stk,Mvm[3]};
									else
										Indexes[Idx - 1] = {Upvalues,Mvm[3]};
									end
									Lupvals[#Lupvals + 1] = Indexes;
								end
								Stk[Inst[2]] = Wrap(NewProto, NewUvals, Env);
							end
						elseif (Enum <= 18) then
							if (Enum == 17) then
								Stk[Inst[2]] = Env[Inst[3]];
							else
								local A = Inst[2];
								local Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
								Top = (Limit + A) - 1;
								local Edx = 0;
								for Idx = A, Top do
									Edx = Edx + 1;
									Stk[Idx] = Results[Edx];
								end
							end
						elseif (Enum > 19) then
							Stk[Inst[2]] = Stk[Inst[3]];
						else
							local A = Inst[2];
							Stk[A] = Stk[A]();
						end
					elseif (Enum <= 24) then
						if (Enum <= 22) then
							if (Enum == 21) then
								local A = Inst[2];
								Stk[A](Stk[A + 1]);
							else
								Stk[Inst[2]] = Stk[Inst[3]];
							end
						elseif (Enum > 23) then
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
						else
							Stk[Inst[2]] = Wrap(Proto[Inst[3]], nil, Env);
						end
					elseif (Enum <= 26) then
						if (Enum == 25) then
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
						else
							VIP = Inst[3];
						end
					elseif (Enum == 27) then
						Stk[Inst[2]] = {};
					else
						do
							return;
						end
					end
				elseif (Enum <= 42) then
					if (Enum <= 35) then
						if (Enum <= 31) then
							if (Enum <= 29) then
								local A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
							elseif (Enum > 30) then
								local A = Inst[2];
								Stk[A] = Stk[A](Stk[A + 1]);
							else
								local A = Inst[2];
								local Results = {Stk[A](Stk[A + 1])};
								local Edx = 0;
								for Idx = A, Inst[4] do
									Edx = Edx + 1;
									Stk[Idx] = Results[Edx];
								end
							end
						elseif (Enum <= 33) then
							if (Enum > 32) then
								Stk[Inst[2]] = {};
							else
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							end
						elseif (Enum > 34) then
							local A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
						else
							Stk[Inst[2]] = Wrap(Proto[Inst[3]], nil, Env);
						end
					elseif (Enum <= 38) then
						if (Enum <= 36) then
							if Stk[Inst[2]] then
								VIP = VIP + 1;
							else
								VIP = Inst[3];
							end
						elseif (Enum > 37) then
							do
								return;
							end
						else
							local A = Inst[2];
							local B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
						end
					elseif (Enum <= 40) then
						if (Enum == 39) then
							local A = Inst[2];
							local B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
						elseif not Stk[Inst[2]] then
							VIP = VIP + 1;
						else
							VIP = Inst[3];
						end
					elseif (Enum == 41) then
						local A = Inst[2];
						local Results = {Stk[A](Unpack(Stk, A + 1, Top))};
						local Edx = 0;
						for Idx = A, Inst[4] do
							Edx = Edx + 1;
							Stk[Idx] = Results[Edx];
						end
					elseif not Stk[Inst[2]] then
						VIP = VIP + 1;
					else
						VIP = Inst[3];
					end
				elseif (Enum <= 49) then
					if (Enum <= 45) then
						if (Enum <= 43) then
							Stk[Inst[2]]();
						elseif (Enum > 44) then
							Stk[Inst[2]][Inst[3]] = Inst[4];
						else
							local A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
						end
					elseif (Enum <= 47) then
						if (Enum > 46) then
							local NewProto = Proto[Inst[3]];
							local NewUvals;
							local Indexes = {};
							NewUvals = Setmetatable({}, {__index=function(_, Key)
								local Val = Indexes[Key];
								return Val[1][Val[2]];
							end,__newindex=function(_, Key, Value)
								local Val = Indexes[Key];
								Val[1][Val[2]] = Value;
							end});
							for Idx = 1, Inst[4] do
								VIP = VIP + 1;
								local Mvm = Instr[VIP];
								if (Mvm[1] == 20) then
									Indexes[Idx - 1] = {Stk,Mvm[3]};
								else
									Indexes[Idx - 1] = {Upvalues,Mvm[3]};
								end
								Lupvals[#Lupvals + 1] = Indexes;
							end
							Stk[Inst[2]] = Wrap(NewProto, NewUvals, Env);
						elseif (Stk[Inst[2]] == Inst[4]) then
							VIP = VIP + 1;
						else
							VIP = Inst[3];
						end
					elseif (Enum == 48) then
						local A = Inst[2];
						Stk[A] = Stk[A](Stk[A + 1]);
					else
						local A = Inst[2];
						Stk[A](Unpack(Stk, A + 1, Inst[3]));
					end
				elseif (Enum <= 53) then
					if (Enum <= 51) then
						if (Enum > 50) then
							local A = Inst[2];
							Stk[A] = Stk[A]();
						else
							local A = Inst[2];
							local Results = {Stk[A](Stk[A + 1])};
							local Edx = 0;
							for Idx = A, Inst[4] do
								Edx = Edx + 1;
								Stk[Idx] = Results[Edx];
							end
						end
					elseif (Enum > 52) then
						local A = Inst[2];
						Stk[A](Unpack(Stk, A + 1, Inst[3]));
					else
						local A = Inst[2];
						local C = Inst[4];
						local CB = A + 2;
						local Result = {Stk[A](Stk[A + 1], Stk[CB])};
						for Idx = 1, C do
							Stk[CB + Idx] = Result[Idx];
						end
						local R = Result[1];
						if R then
							Stk[CB] = R;
							VIP = Inst[3];
						else
							VIP = VIP + 1;
						end
					end
				elseif (Enum <= 55) then
					if (Enum > 54) then
						Stk[Inst[2]] = Inst[3];
					elseif Stk[Inst[2]] then
						VIP = VIP + 1;
					else
						VIP = Inst[3];
					end
				elseif (Enum > 56) then
					Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
				else
					local A = Inst[2];
					local C = Inst[4];
					local CB = A + 2;
					local Result = {Stk[A](Stk[A + 1], Stk[CB])};
					for Idx = 1, C do
						Stk[CB + Idx] = Result[Idx];
					end
					local R = Result[1];
					if R then
						Stk[CB] = R;
						VIP = Inst[3];
					else
						VIP = VIP + 1;
					end
				end
				VIP = VIP + 1;
			end
		end;
	end
	return Wrap(Deserialize(), {}, vmenv)(...);
end
return VMCall("LOL!3B3Q00030A3Q006C6F6164737472696E6703043Q0067616D6503073Q00482Q747047657403493Q00682Q7470733A2Q2F6769746875622E636F6D2F64617769642D736372697074732F466C75656E742F72656C65617365732F6C61746573742F646F776E6C6F61642F6D61696E2E6C756103543Q00682Q7470733A2Q2F7261772E67697468756275736572636F6E74656E742E636F6D2F64617769642D736372697074732F466C75656E742F6D61737465722F412Q646F6E732F536176654D616E616765722E6C7561030C3Q0043726561746557696E646F7703053Q005469746C6503063Q0044582048554203083Q005375625469746C65030E3Q0062792075786E7A7874234Q3003083Q005461625769647468026Q00644003043Q0053697A6503053Q005544696D32030A3Q0066726F6D4F2Q66736574025Q00208240025Q00C07C4003073Q00416372796C69632Q0103053Q005468656D6503043Q004461726B030B3Q004D696E696D697A654B657903043Q00456E756D03073Q004B6579436F6465030B3Q004C656674436F6E74726F6C03043Q004D61696E03063Q00412Q6454616203043Q0049636F6E03043Q006D61696E03073Q004C696D6974656403043Q006769667403083Q0053652Q74696E677303083Q0073652Q74696E677303073Q004F7074696F6E7303093Q00412Q64546F2Q676C6503133Q004963656443616E6479204175746F204661726D03173Q00456E61626C65204C696D69746564204175746F4661726D03073Q0044656661756C7403083Q0043612Q6C6261636B030A3Q005365744C69627261727903093Q00536574466F6C64657203073Q0044582F4354424E03123Q004275696C64436F6E66696753656374696F6E03123Q004C6F61644175746F6C6F6164436F6E66696703133Q0049676E6F72655468656D6553652Q74696E6773030C3Q0042696E64546F4F7074696F6E03113Q004C696D6974656447696674546F2Q676C6503063Q004E6F7469667903103Q00466C75656E74205549204C6F6164656403073Q00436F6E74656E74031B3Q0050726F78696D6974792048616E646C65722069732072656164792E03083Q004475726174696F6E026Q00144003023Q005F4703093Q006B2Q6570646F696E67030A3Q0047657453657276696365030A3Q0052756E53657276696365030D3Q0052656E6465725374652Q70656403073Q00436F2Q6E656374006B3Q0012113Q00013Q001211000100023Q002025000100010003001237000300044Q0012000100034Q002C5Q00022Q00333Q00010002001211000100013Q001211000200023Q002025000200020003001237000400054Q0012000200044Q002C00013Q00022Q003300010001000200202500023Q00062Q002100043Q000700300600040007000800300600040009000A0030060004000B000C0012110005000E3Q002Q2000050005000F001237000600103Q001237000700114Q000A0005000700020010190004000D0005003006000400120013003006000400140015001211000500173Q002Q20000500050018002Q200005000500190010190004001600052Q000A0002000400022Q002100033Q000300202500040002001B2Q002100063Q000200300600060007001A0030060006001C001D2Q000A0004000600020010190003001A000400202500040002001B2Q002100063Q000200300600060007001E0030060006001C001F2Q000A0004000600020010190003001E000400202500040002001B2Q002100063Q00020030060006000700200030060006001C00212Q000A000400060002001019000300200004002Q2000043Q0022002Q2000050003001E002025000500050023001237000700244Q002100083Q000300300600080007002500300600080026001300022200095Q0010190008002700092Q000A0005000800020020250006000100282Q001600086Q00310006000800010020250006000100290012370008002A4Q003100060008000100202500060001002B002Q200008000300202Q003100060008000100202500060001002C2Q001500060002000100202500060001002D2Q001500060002000100202500060001002E2Q0016000800053Q0012370009002F4Q003100060009000100202500063Q00302Q002100083Q00030030060008000700310030060008003200330030060008003400352Q0031000600080001001211000600363Q0030060006003700132Q000E000600013Q00060F00070001000100012Q00143Q00063Q000222000800023Q001211000900023Q002025000900090038001237000B00394Q000A0009000B0002002Q2000090009003A00202500090009003B00060F000B0003000100012Q00143Q00084Q00310009000B0001001211000900363Q002Q200009000900370026040009006A0001001300041A3Q006A00012Q0016000900074Q000200090001000100041A3Q006300012Q001C3Q00013Q00043Q00023Q0003023Q005F4703093Q006B2Q6570646F696E6701033Q001211000100013Q001019000100024Q001C3Q00017Q001E3Q0003053Q00706169727303093Q00776F726B7370616365030D3Q00427265616B61626C6549636573030E3Q0047657444657363656E64616E74732Q033Q00497341030F3Q0050726F78696D69747950726F6D7074030C3Q00486F6C644475726174696F6E028Q0003053Q007461626C6503063Q00696E7365727403063Q0050726F6D707403083Q00506F736974696F6E03063Q00506172656E7403023Q005F4703093Q006B2Q6570646F696E67010003043Q0067616D6503073Q00506C6179657273030B3Q004C6F63616C506C6179657203093Q00436861726163746572030E3Q0046696E6446697273744368696C6403103Q0048756D616E6F6964522Q6F745061727403063Q00434672616D652Q033Q006E657703043Q0077616974029A5Q99B93F029A5Q99C93F03133Q006669726570726F78696D69747970726F6D707403043Q007761726E03283Q00436861726163746572206F722048756D616E6F6964522Q6F7450617274206E6F7420666F756E642E004C4Q00217Q001211000100013Q001211000200023Q002Q200002000200030020250002000200042Q0005000200034Q002900013Q000300041A3Q00170001002025000600050005001237000800064Q000A0006000800020006240006001700013Q00041A3Q00170001003006000500070008001211000600093Q002Q2000060006000A2Q001600076Q002100083Q00020010190008000B0005002Q2000090005000D002Q2000090009000C0010190008000C00092Q0031000600080001000634000100080001000200041A3Q000800010012110001000E3Q002Q2000010001000F0026040001001E0001001000041A3Q001E00012Q001C3Q00013Q001211000100014Q001600026Q001E00010002000300041A3Q00490001001211000600113Q002Q20000600060012002Q20000600060013002Q200006000600140006240006004600013Q00041A3Q00460001002025000700060015001237000900164Q000A0007000900020006240007004600013Q00041A3Q00460001002Q20000700060016001211000800173Q002Q20000800080018002Q2000090005000C2Q001F000800020002001019000700170008001211000800194Q000D00095Q0006240009003A00013Q00041A3Q003A00010012370009001A3Q0006280009003B0001000100041A3Q003B00010012370009001B4Q00150008000200010012110008001C3Q002Q2000090005000B2Q00150008000200010012110008001C3Q002Q2000090005000B2Q00150008000200010012110008001C3Q002Q2000090005000B2Q001500080002000100041A3Q004900010012110007001D3Q0012370008001E4Q0015000700020001000634000100220001000200041A3Q002200012Q001C3Q00017Q00123Q0003043Q0067616D65030A3Q004765745365727669636503073Q00506C6179657273030B3Q004C6F63616C506C6179657203093Q004963656443616E647903053Q0056616C7565026Q00244003053Q00706169727303093Q00776F726B7370616365030B3Q004765744368696C6472656E030E3Q0046696E6446697273744368696C642Q033Q00506164030A3Q00412Q746163686D656E74030F3Q0050726F78696D69747950726F6D707403093Q0043686172616374657203103Q0048756D616E6F6964522Q6F745061727403063Q00434672616D6503133Q006669726570726F78696D69747970726F6D7074002F3Q0012113Q00013Q0020255Q0002001237000200034Q000A3Q00020002002Q205Q0004002Q2000013Q0005002Q200001000100060026040001002E0001000700041A3Q002E0001001211000100083Q001211000200093Q00202500020002000A2Q0005000200034Q002900013Q000300041A3Q002C000100202500060005000B0012370008000C4Q000A0006000800020006240006002C00013Q00041A3Q002C000100202500070006000B0012370009000D4Q000A0007000900020006240007002C00013Q00041A3Q002C000100202500080007000B001237000A000E4Q000A0008000A00020006240008002C00013Q00041A3Q002C0001002Q2000093Q000F002Q20000900090010002Q20000A0006001100101900090011000A001211000900124Q0016000A00084Q0015000900020001001211000900124Q0016000A00084Q0015000900020001001211000900124Q0016000A00084Q001500090002000100041A3Q002E00010006340001000F0001000200041A3Q000F00012Q001C3Q00017Q00033Q0003023Q005F4703093Q006B2Q6570646F696E672Q0100073Q0012113Q00013Q002Q205Q00020026043Q00060001000300041A3Q000600012Q000D8Q00023Q000100012Q001C3Q00017Q00", GetFEnv(), ...);
