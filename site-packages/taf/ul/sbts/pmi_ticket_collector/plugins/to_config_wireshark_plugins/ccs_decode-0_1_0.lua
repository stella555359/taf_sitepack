
-- *******************************************************************************
-- @file                  ccs_decode.lua
-- @version               DRAFT/HACK
-- @date                  $LastChangedDate: 2021-10-19 $
-- @author                $Author: gregor.kecht@nokia.com $
-- LUA sample decode CCS services to syscom layer 
-- please do not hesitate to enhance this script
-- but do not forget to return the enhancements to Wireshark LTE&5G
-- https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=776824783
-- to be published there for the sake of other users
-- 
-- V2 : added CCS AaConfig syscom API 
-- V3 : enhanced CCS AaTrace syscom API decoding , added by Morozov, Denis (Nokia - PL/Wroclaw) 
-- Plugin information, added by Wagner, Bruno (Nokia - DE/Ulm)
-- Version rule: first.second.last,   comments from Elmar
--    first position: main changes, keep 0 for prototype state
--    second position: new messages 
--    last position: fixes
-- V0.0.1 : commented out undefined subtree, Schmidberger, Elmar (Nokia - DE/Ulm)
-- V0.1.0 : -Add the AaTraceAggregatedMonIndMsg,
--          -Fix the syscom_id's length, Huang Hao (Nokia - CH/HZ)
-- 
-- ******************************************************************************* 

-- Set LuaShark Plugin Information
local luashark_info = {
  version = "0.1.0",
  requires = "Wireshark_LTE&5G_v2.4.5.lte.1803.01 (or newer)",
  author = "Gregor Kecht, Wireshark LTE&5G team",
  description = "This plugin dissects ICOM payloads contained in SICP (syscom) and BIP messages",
}
set_plugin_info(luashark_info)

do

sic_table = DissectorTable.get ("sic.msgid")

-- ******************************************************************************* 
-- ******************************************************************************* 
-- ******************** CCS AATRACE  ********************************************* 
-- ******************************************************************************* 
-- ******************************************************************************* 


local p_AATRACE_CTRL_MSG = Proto("AATRACE_CTRL_MSG","AATRACE_CTRL_MSG");
local p_AATRACE_CTRL_RESP_MSG = Proto("AATRACE_CTRL_RESP_MSG","AATRACE_CTRL_RESP_MSG");
local p_AATRACE_MON_IND = Proto("AATRACE_MON_IND","AATRACE_MON_IND");
local p_AATRACE_AGGREGATED_MON_IND = Proto("AATRACE_AGGREGATED_MON_IND","AATRACE_AGGREGATED_MON_IND");

local f_routingTarget = ProtoField.uint32("TRACE_CONFIG.routingTarget","routingTarget",base.HEX);

local f_messageId = ProtoField.uint32("TCFG.messageID","messageID",base.HEX);

local f_isRange = ProtoField.uint8("TRACE_CONFIG.isRange","isRange",base.HEX);

local f_syscom_ID = ProtoField.uint16("MON_IND.syscomID","syscomID",base.HEX);

local f_monMsgCount = ProtoField.uint32("TRAC_AGGR.monMsgCount","monMsgCount",base.DEC);

local f_data = ProtoField.bytes("MON_IND.data", "data");
 
p_AATRACE_CTRL_MSG.fields = { f_messageId , f_routingTarget , f_isRange  };

p_AATRACE_CTRL_RESP_MSG.fields = { f_return_code  };

p_AATRACE_MON_IND.fields = { f_syscom_ID, f_data};
p_AATRACE_AGGREGATED_MON_IND.fields = { f_monMsgCount };


local function dissectTraceConfig(buffer1,buffer2,buffer_range ,tree)
	local offset = 0
	local messageID

	local subtree = tree:add(tree, buffer)
	subtree:set_text("msg id config ")
	subtree:add (f_messageId, buffer1)
	subtree:add (f_messageId, buffer2)
  subtree:add (f_isRange, buffer_range)
	
end

local function dissectMessageConfig(buffer, tree)
	local offset = 0
	local range_offset = 0
	local buf1 
	local buf2
	local buf_range
	local num_of_configs = 64;

	local subtree = tree:add(tree, buffer)
	subtree:set_text("Trace config ")

	range_offset = num_of_configs*4*2;
	for i = 1,num_of_configs
	do
	
		buf1  = buffer(offset, 4)
		offset = offset + 4
		buf2  = buffer(offset, 4)
		offset = offset + 4
		buf_range = buffer(range_offset,1)
		range_offset = range_offset + 1
		dissectTraceConfig(buf1,buf2,buf_range ,tree)		
	end
	
	
	offset = offset + 1*1*num_of_configs
	
	
	
	return offset
end

function p_AATRACE_CTRL_MSG.dissector(buf,pkt,root)

            pkt.cols.info = "AATRACE_CTRL_MSG"

            local subtree = root:add(p_AATRACE_CTRL_MSG, buf())
            local offset = 0            
            local local_offset = 0            


            -- mode and type 
            offset = offset + 4
            offset = offset + 4

			-- filter 
			offset  = offset + dissectMessageConfig(buf(offset),subtree)

			
			-- heavy load filter 


            offset = offset + 4*8
            offset = offset + 4*8
			
            local routingTarget = buf(offset, 4)
            subtree:add (f_routingTarget, routingTarget)
            offset = offset + 4
                    
end

function p_AATRACE_CTRL_RESP_MSG.dissector(buf,pkt,root)

            -- pkt.cols.info = "AATRACE_CTRL_RESP_MSG"

            local subtree = root:add(p_AATRACE_CTRL_RESP_MSG, buf())
            local offset = 0            

            local mask = buf(offset,4)
            local returnCode = mask:bitfield(0,32)
            pkt.cols.info = string.format("%s , AATRACE_CTRL_RESP_MSG return code : 0x%x",pkt.cols.info,returnCode)
            subtree:add (f_return_code, returnCode)

                    
end

local syscom_dis = Dissector.get("syscom")

function p_AATRACE_MON_IND.dissector(buf,pkt,root)

            pkt.cols.info = "AATRACE_MON_IND"

            local subtree = root:add(p_AATRACE_MON_IND, buf())
            local offset = 0            
			 -- EMonitorType type;   /**< See EMonitorType.h. */
            offset = offset + 4
			 -- EMonitorMode mode;   /**< See EMonitorMode.h. */
            offset = offset + 4
			 -- u32 sequence;        /**< Running number for a monitoring instance
            local sequence = buf(offset, 4)
            --subtree:add (f_sequence_nr, sequence)
            offset = offset + 4
			  -- u32 extra[AATRACE_MAX_MONITOR_EXTRA];  /**< Case (type, mode) specific
            --local time_h = buf(offset, 4).uint()
            offset = offset + 4
            --local time_l = buf(offset, 4).uint()
            offset = offset + 4
            offset = offset + 4
            offset = offset + 4
            --local timestamp = UInt64(time_h, time_l).tonumber()
            --subtree:add (f_time, os.date("%X",timestamp))

			  -- u32 dataLen;         /**< Number of octets appended. */
            offset = offset + 4
			
            local syscom_ID = buf(offset+2, 2)
            subtree:add (f_syscom_ID, syscom_ID)
			
			local remainingBytes = buf:len() - offset
        
            syscom_dis:call(buf(offset,remainingBytes):tvb(), pkt, root)
end


function p_AATRACE_AGGREGATED_MON_IND.dissector(buf,pkt,root)

            pkt.cols.info = "AATRACE_AGGREGATED_MON_IND"
            local subtree = root:add(p_AATRACE_AGGREGATED_MON_IND, buf())
            
            local offset = 0            
            local num_of_msg = buf(0,4):le_uint()
			subtree:add (f_monMsgCount, num_of_msg)
            offset = offset + 4
			offset = offset + 4
            
	    for i = 1,num_of_msg
	    do
		    local startOffset = offset
            offset = offset + 4
            offset = offset + 4
            offset = offset + 4
            offset = offset + 4
            offset = offset + 4
            offset = offset + 4
            offset = offset + 4
			local dataLenInd = buf(offset, 4):le_uint()
			local subtreeMonInd = subtree:add(p_AATRACE_MON_IND, buf(startOffset, dataLenInd+32)) 
			offset = offset + 4
			
			local subtreeData = subtreeMonInd:add(f_data, buf(offset, dataLenInd))
			
			syscom_dis:call(buf(offset,dataLenInd):tvb(), pkt, subtreeData)
			offset = offset + dataLenInd
	    end
			
end

sic_table:add(0x1819, p_AATRACE_CTRL_MSG)
sic_table:add(0x1813, p_AATRACE_CTRL_RESP_MSG)
sic_table:add(0x2991, p_AATRACE_MON_IND)
sic_table:add(0x0bf9, p_AATRACE_AGGREGATED_MON_IND)

-- ******************************************************************************* 
-- ******************************************************************************* 
-- ******************** CCS AACONFIG  ********************************************* 
-- ******************************************************************************* 
-- ******************************************************************************* 


local p_AACONFIG_SET_PARAMS_REQ = Proto("AACONFIG_SET_PARAMS_REQ","AACONFIG_SET_PARAMS_REQ");
local p_AACONFIG_SET_PARAMS_RESP = Proto("AACONFIG_SET_PARAMS_RESP","AACONFIG_SET_PARAMS_RESP");
local p_AACONFIG_GET_PARAMS_REQ = Proto("AACONFIG_GET_PARAMS_REQ","AACONFIG_GET_PARAMS_REQ");
local p_AACONFIG_GET_PARAMS_RESP = Proto("AACONFIG_GET_PARAMS_RESP","AACONFIG_GET_PARAMS_RESP");

function p_AACONFIG_SET_PARAMS_REQ.dissector(buf,pkt,root)

            pkt.cols.info = "AACONFIG_SET_PARAMS_REQ"
end
function p_AACONFIG_SET_PARAMS_RESP.dissector(buf,pkt,root)

            pkt.cols.info = "AACONFIG_SET_PARAMS_RESP"
end
function p_AACONFIG_GET_PARAMS_REQ.dissector(buf,pkt,root)

            pkt.cols.info = "AACONFIG_GET_PARAMS_REQ"
end
function p_AACONFIG_GET_PARAMS_RESP.dissector(buf,pkt,root)

            pkt.cols.info = "AACONFIG_GET_PARAMS_RESP"
end

sic_table:add(0x2011, p_AACONFIG_SET_PARAMS_REQ)
sic_table:add(0x2012, p_AACONFIG_SET_PARAMS_RESP)
sic_table:add(0x2013, p_AACONFIG_GET_PARAMS_REQ)
sic_table:add(0x2014, p_AACONFIG_GET_PARAMS_RESP)

-- ********************************
-- new API introduced with LBT2332
-- ********************************


local p_AACONFIG_SET_PARAMS_EXT_REQ = Proto("AACONFIG_RAD_PARAMS_EXT_SET_REQ_MSG","AACONFIG_RAD_PARAMS_EXT_SET_REQ_MSG");
local p_AACONFIG_SET_PARAMS_EXT_RESP = Proto("AACONFIG_RAD_PARAMS_EXT_SET_RESP_MSG","AACONFIG_RAD_PARAMS_EXT_SET_RESP_MSG");
local p_AACONFIG_GET_PARAMS_EXT_REQ = Proto("AACONFIG_RAD_PARAMS_EXT_GET_REQ_MSG","AACONFIG_RAD_PARAMS_EXT_GET_REQ_MSG");
local p_AACONFIG_GET_PARAMS_EXT_RESP = Proto("AACONFIG_RAD_PARAMS_EXT_GET_RESP_MSG","AACONFIG_RAD_PARAMS_EXT_GET_RESP_MSG");

local scope_vals = {
  [0x0] = "Invalid scope", 
  [0x1] = "Local scope", 
  [0x1000000] = "Local scope", 
  [0x2] = "global scope", 
  [0x2000000] = "global scope"
}

local variant_vals = {
  [0x0] = "Invalid variant", 
  [0x1] = "actual variant", 
  [0x1000000] = "actual variant", 
  [0x2] = "Factory variant", 
  [0x2000000] = "Factory variant",
  [0x3] = "FactoryDomain variant", 
  [0x3000000] = "FactoryDomain variant", 
  [0x4] = "FactoryAll variant", 
  [0x4000000] = "FactoryAll variant"
}

local types = {
  EAaConfigRadSetVariant = ProtoField.uint32("EAaConfigRadSetVariant", "scope", base.HEX,variant_vals),
  EAaConfigRadParamSetMask = ProtoField.uint32("EAaConfigRadParamSetMask", "mask", base.HEX),
  EAaConfigRadSetScope = ProtoField.uint32("EAaConfigRadSetScope", "scope", base.HEX,scope_vals)
}

p_AACONFIG_SET_PARAMS_EXT_REQ.fields = types;

function p_AACONFIG_SET_PARAMS_EXT_REQ.dissector(buf,pkt,root)

            pkt.cols.info = "AACONFIG_RAD_PARAMS_EXT_SET_REQ_MSG"
            local subtree = root:add(p_AACONFIG_SET_PARAMS_EXT_REQ, buf())
            local offset = 0                        
            
            local variant = buf(offset,4)
            local variant_bf = variant:bitfield(0,32)                   
            pkt.cols.info = string.format("%s , %s",pkt.cols.info,variant_vals[variant_bf])
            subtree:add(types.EAaConfigRadSetVariant, buf(offset,4))
            offset = offset + 4   
                        
            -- mask 
            local mask = buf(offset,4)
            local current_bf = mask:bitfield(7,1) + mask:bitfield(31,1)
            local onereset_bf = mask:bitfield(6,1) + mask:bitfield(30,1)
            local persistent_bf = mask:bitfield(5,1) + mask:bitfield(29,1)
            pkt.cols.info = string.format("%s ,[MASK: CURRENT:%d, ONERESET:%d, PERSISTENT:%d]",pkt.cols.info,current_bf,onereset_bf,persistent_bf)

            subtree:add(types.EAaConfigRadParamSetMask, mask)
                        
            offset = offset + 4   

            local scope = buf(offset,4)
            local scope_bf = scope:bitfield(0,32)                   
            pkt.cols.info = string.format("%s , %s",pkt.cols.info,scope_vals[scope_bf])
            offset = offset + 4   
                        
            subtree:add(types.EAaConfigRadSetScope, scope)

            
end

function p_AACONFIG_SET_PARAMS_EXT_RESP.dissector(buf,pkt,root)

            pkt.cols.info = "AACONFIG_RAD_PARAMS_EXT_SET_RESP_MSG"
            local subtree = root:add(p_AACONFIG_SET_PARAMS_EXT_RESP, buf())
            local offset = 0                        
end

function p_AACONFIG_GET_PARAMS_EXT_REQ.dissector(buf,pkt,root)

            pkt.cols.info = "AACONFIG_RAD_PARAMS_EXT_GET_REQ_MSG"
            local subtree = root:add(p_AACONFIG_GET_PARAMS_EXT_REQ, buf())
            local offset = 0                        
end

function p_AACONFIG_GET_PARAMS_EXT_RESP.dissector(buf,pkt,root)

            pkt.cols.info = "AACONFIG_RAD_PARAMS_EXT_GET_RESP_MSG"
            local subtree = root:add(p_AACONFIG_GET_PARAMS_EXT_RESP, buf())
            local offset = 0                        
end

sic_table:add(0x43DE, p_AACONFIG_SET_PARAMS_EXT_REQ)
sic_table:add(0x43DF, p_AACONFIG_SET_PARAMS_EXT_RESP)
sic_table:add(0x43DA, p_AACONFIG_GET_PARAMS_EXT_REQ)
sic_table:add(0x43DC, p_AACONFIG_GET_PARAMS_EXT_REQ)
sic_table:add(0x43DB, p_AACONFIG_GET_PARAMS_EXT_RESP)
sic_table:add(0x43DD, p_AACONFIG_GET_PARAMS_EXT_RESP)


end         
