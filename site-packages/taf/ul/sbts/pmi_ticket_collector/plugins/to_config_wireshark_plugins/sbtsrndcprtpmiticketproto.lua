---------------------------------------------------------------------------------------------------------------------
-- Check version
---------------------------------------------------------------------------------------------------------------------
local required_version = "WiresharkLTE&5G_v3.4.9.lte.2112.01 (or newer)"
local function check_version()
    -- Get Wireshark version
    local wireshark_version = get_version()
    v1, v2, v3, v4, v5, v6 = string.match(wireshark_version, "(%d+).(%d+).(%d+).(%w+).(%w+).(%w+)")
    if v1 == nil or v2 == nil or v3 == nil or v4 == nil or v5 == nil or v6 == nil then
        error("Your wireshark version '"..wireshark_version.."' is not supported! "..
                "Please use Nokia internal "..required_version..".")
    end
    r1, r2, r3, r4, r5, r6 = string.match(required_version, "(%d+).(%d+).(%d+).(%w+).(%w+).(%w+)")

    -- combine v1/v2/v3 and r1/r2/r3
    v1_2_3 = tonumber(v1) * 10000 + tonumber(v2) * 100 + tonumber(v3)
    r1_2_3 = tonumber(r1) * 10000 + tonumber(r2) * 100 + tonumber(r3)

    -- combine v5/v6 and r5/r6
    v5_6 = tonumber(v5) * 100 + tonumber(v6)
    r5_6 = tonumber(r5) * 100 + tonumber(r6)

    if not (v1 and v2 and v3 and v4 and v5 and v6) then
        error("Wireshark version '"..wireshark_version.."' is not supported. "..
                "Please use "..required_version..".")
    else
        if not (tonumber(v1_2_3) >= tonumber(r1_2_3) and
                tostring(v4) == tostring(r4) and
                tonumber(v5_6) >= tonumber(r5_6)) then
            error("WiresharkLTE&5G version '"..wireshark_version.."' is not supported. "..
                "Please use "..required_version..".")
        end
    end
end
--check_version()


-- CpRtPmiTicket protocol example
-- declare our protocol
local SBTS_proto = Proto("sbts.rnd.cprtpmiticket.proto", "SBTSRNDCpRtPmiTicketproto", "CpRtPmiTicket Protocol")
local protobuf_dissector = Dissector.get("protobuf")

local multi_dissector = Dissector.get("message_entry_itf_rnd_cprtpmiticket")
-- packet dissector
function SBTS_proto.dissector(buf, pinfo, tree)
	local offset=0
	local len = buf:len()
	--protobuf_dissector:call(buf(offset+8, len-8):tvb(), pinfo, tree)
	--protobuf_dissector:call(buf(offset, len):tvb(), pinfo, tree)
	multi_dissector:call(buf(offset, len):tvb(), pinfo, tree)

	protobuf_dissector:call(buf(offset+8, len-8):tvb(), pinfo, tree)
    return true
end

local syscom_ids_table = DissectorTable.get("sic.msgid")
syscom_ids_table:add(56696, SBTS_proto)

---------------------------------------------------------------------------------------------------------------------
-- Begin code for register protocol
---------------------------------------------------------------------------------------------------------------------
