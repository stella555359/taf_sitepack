# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: DevWro1
:maintainer: 5GSWEngWro
:contact: I_TA5G_SUPPORT <I_TA5G_SUPPORT@internal.nsn.com>
"""


class LteRrc(object):
    def __init__(self):
        self.LTE_MOBILITY_GERAN_WITHOUT_SYSINFO = (
            "lte-rrc.mobilityFromEUTRACommand_element && !lte-rrc.SystemInfoListGERAN_item"
        )
        self.LTE_MOBILITY_GERAN_WITH_SYSINFO = (
            "lte-rrc.mobilityFromEUTRACommand_element && lte-rrc.SystemInfoListGERAN_item"
        )
        self.RRC_MOBILITY_TO_UTRA = "lte-rrc.purpose==handover&&lte-rrc.targetRAT_Type==utra"
        self.UE_INFORMATION_REQUEST = "lte-rrc.c1 == 9"
        self.UE_CAPABILITY_RESPONSE = "lte-rrc.c1 == 7 && ip.src == 10.0.2.1"
        self.RRC_CONNECTION_SETUP = "lte-rrc.c1 == 3"
        self.RRC_CONNECTION_SETUP_COMPLETE = "lte-rrc.c1 == 4"
        self.RRC_CONNECTION_RECONFIGURATION = "lte-rrc.rrcConnectionReconfiguration_element"
        self.RRC_CONNECTION_RECONFIGURATION_AFTER_INTRA_HO = (
            "lte-rrc.rrcConnectionReconfiguration_element && "
            "!lte-rrc.targetPhysCellId && !lte-rrc.measObjectEUTRA_element"
        )
        self.RRC_CONNECTION_RECONFIGURATION_AFTER_INTER_ENB_HO = (
            "lte-rrc.quantityConfig_element && !lte-rrc.targetPhysCellId"
        )
        self.RRC_CONNECTION_RECONFIGURATION_HO_COMMAND = "lte-rrc.targetPhysCellId"
        self.RRC_CONNECTION_RECONFIGURATION_COMPLETE = "lte-rrc.c1 == 2"
        self.RRC_CONNECTION_RECONFIGURATION_DE_ACTIVATE_BEARER = "nas_eps.nas_msg_esm_type == 0xcd"
        self.RRC_CONNECTION_RECONFIGURATION_TRANSMISSION_MODE_1 = "lte-rrc.transmissionMode_r10 == 0"
        self.RRC_CONNECTION_RECONFIGURATION_ADD_RSCFS_MEASUREMENT = (
            "lte-rrc.measObjectToAddModList&&lte-rrc.cdma2000_Type"
        )
        self.RRC_CONNECTION_RECONFIGURATION_REMOVE_RSCFS_MEASUREMENT = "lte-rrc.measGapConfig == 0"
        self.RRC_CONNECTION_RELEASE = "lte-rrc.rrcConnectionRelease_element"
        self.RRC_CONNECTION_RELEASE_IDLE_MODE_MOBILITY_CONTROL_INFO = "lte-rrc.idleModeMobilityControlInfo_element"
        self.RRC_CONNECTION_RELEASE_CAUSE = "lte-rrc.releaseCause == 1"
        self.RRC_CONNECTION_RELEASE_CSFB_REDIR = "lte-rrc.utra_FDD"
        self.RRC_CONNECTION_REESTABLISHMENT_COMPLETE = "lte-rrc.c1 == 3"
        self.RRC_INTRA_LTE_HANDOVER = "lte-rrc.handoverType == 0"
        self.TARGET_CELL = "lte-rrc.targetPhysCellId"
        self.UE_INITIAL_POWER_FROM_SIB2 = "lte-rrc.preambleInitialReceivedTargetPower"
        self.UE_EMERGENCY_ATTACH_REQUEST = "nas_eps.esm_request_type == 4"
        self.IMMCI_EUTRA_PRESENT = "lte-rrc.releaseCause == 1 && lte-rrc.freqPriorityListEUTRA == 1"
        self.IMMCI_EUTRA_PRESENT_2_ITEMS = "lte-rrc.releaseCause == 1 && lte-rrc.freqPriorityListEUTRA == 2"
        self.IMMCI_EUTRA_PRESENT_3_ITEMS = "lte-rrc.releaseCause == 1 && lte-rrc.freqPriorityListEUTRA == 3"
        self.IMMCI_FREQ_PRIO_LIST_EUTRA = "lte-rrc.freqPriorityListEUTRA == 1"
        self.RRC_MEAS_CONFIG_LTE_RSC_WITH_FREQ = "lte-rrc.purpose == 0 && lte-rrc.carrierFreq"
        self.RRC_MEAS_CONFIG_1XRTT_RSCFS = "lte-rrc.purpose == 1 && lte-rrc.measQuantityCDMA2000 == 0"
        self.RRC_MEAS_REPORT_CDMA2000 = "lte-rrc.measResultNeighCells == 3"
        self.RRC_CDMA2000_BAND_CLASS = "lte-rrc.bandClass"
        self.RRC_CDMA2000_ARFCN = "lte-rrc.arfcn"
        self.RRC_MEAS_REP_PERIODICAL = "lte-rrc.triggerType == 1"
        self.RRC_MAX_REPORT_CELLS = "lte-rrc.maxReportCells"
        self.RRC_1H_REP_INTERVAL = "lte-rrc.reportInterval == 12"
        self.RRC_REPORT_AMOUNT_R1 = "lte-rrc.reportAmount == 0"
        self.RRC_SEARCH_WIN_SIZE = "lte-rrc.searchWindowSize"
        self.RRC_CDMA2000_TYPE_1XRTT = "lte-rrc.cdma2000_Type == 0"
        self.RRC_CONNECTION_RECONFIGURATION_B2_RSRQ_MEAS_CONFIG = (
            "lte-rrc.reportConfigToAddModList&&lte-rrc.b2_Threshold1&&(lte-rrc.b2_Threshold1 == threshold-RSRQ)"
        )
        self.RRC_CONNECTION_RECONFIGURATION_B2_RSRP_MEAS_CONFIG = (
            "lte-rrc.reportConfigToAddModList&&lte-rrc.b2_Threshold1&&(lte-rrc.b2_Threshold1 == threshold-RSRP)"
        )
        self.RRC_SCELL_TO_ADD = "lte-rrc.sCellToAddModList_r10"
        self.RRC_SCELL_TO_RELEASE = "lte-rrc.sCellToReleaseList_r10"
        self.RRC_REMOVE_ALL_POSSIBLE_MEAS_IDS = "lte-rrc.measIdToRemoveList == 32"
        self.TRANSMISSION_MODE_R10_TM4_WITH_CSR = (
            'lte-rrc.transmissionMode_r10 == tm4 && lte-rrc.codebookSubsetRestriction_r10 == ff:ff:ff:ff:ff:ff:ff:ff'
        )
        self.TRANSMISSION_MODE_R10_TM4_MIMO_4x2 = (
            'lte-rrc.transmissionMode_r10 == tm4 && lte-rrc.codebookSubsetRestriction_r10 == 00:00:00:00:ff:ff:ff:ff'
        )
        self.NO_MAX_LAYERS_MIMO_R10 = '!lte-rrc.maxLayersMIMO_r10'
        self.MAX_FOUR_LAYERS_MIMO_R10 = 'lte-rrc.maxLayersMIMO_r10 == fourLayers'
        self.RRC_CONNECTION_REESTABLISHMENT = 'lte-rrc.rrcConnectionReestablishment_element'
        self.NO_ANTENNA_INFO_R10 = '!lte-rrc.antennaInfo_r10'
        self.NO_FULL_CONFIG = '!lte-rrc.fullConfig_r9'
        self.HANDOVER_COMMAND = 'lte-rrc.handoverCommandMessage'
        self.LOGGED_MEASUREMENTS_AVAILABLE = "lte-rrc.logMeasAvailable_r10 == 0"
        self.RLF_INFO_AVAILABLE = "lte-rrc.rlf_InfoAvailable_r10 == 0"
        self.MIB = "lte-rrc.sourceMasterInformationBlock_element"
        self.SIB1 = "lte-rrc.c1 == 1"
        self.SIB2 = "lte-rrc.sib_TypeAndInfo_item == 0"
        self.SIB5 = "lte-rrc.sib_TypeAndInfo_item == 3"
        self.CELL_BARRED = "lte-rrc.cellBarred == 0"
        self.CELL_NOT_BARRED = "lte-rrc.cellBarred == 1"
        self.RRC_DRX_CONFIG = "lte-rrc.drx_Config"
        self.RRC_DRX_INACT_TIMER = "lte-rrc.drx_InactivityTimer"
        self.RRC_SHORTDRX_CYCLE = "lte-rrc.shortDRX_Cycle"
        self.RRC_SCELL_TO_REL = "lte-rrc.sCellToReleaseList_r10"
        self.RRC_DL_CARRIER_FREQUENCY = "lte-rrc.dl_CarrierFreq_r10"
        self.RRC_UL_CARRIER_FREQUENCY = "lte-rrc.ul_CarrierFreq_r10"
        self.RRC_PHYSICAL_CELL_ID = "lte-rrc.physCellId_r10"
        self.RRC_CARRIER_FREQUENCY = "lte-rrc.dl_CarrierFreq_r10&&lte-rrc.ul_CarrierFreq_r10"
        self.RRC_ADDITIONAL_SPECTRUM_EMISSION_SCELL = "lte-rrc.additionalSpectrumEmissionSCell_r10"
        self.RRC_DL_CARRIER_FREQUENCY_V1090 = "lte-rrc.dl_CarrierFreq_v1090"
        self.RRC_UL_CARRIER_FREQUENCY_V1090 = "lte-rrc.ul_CarrierFreq_v1090"
        self.RRC_A6_ENABLED_AND_BLACKLIST = (
            "lte-rrc.blackCellsToAddModList&&lte-rrc.eventId==5&&lte-rrc.measId==3&&lte-rrc.reportConfigId==4"
        )
        self.RRC_A6_ENABLED_AFTER_REAUTH = "lte-rrc.measObjectId==3&&lte-rrc.measId==3&&lte-rrc.reportConfigId==4"
        self.RRC_A6_ENABLED_AND_BLACKLIST_THIRD_FREQ = (
            "lte-rrc.blackCellsToAddModList&&lte-rrc.eventId==4&&lte-rrc.measId==2&&lte-rrc.reportConfigId==4"
        )
        self.RRC_A6_ENABLED = "lte-rrc.measId==3&&lte-rrc.reportConfigId==4"
        self.RRC_TWO_A6_ENABLED_AND_BLACKLIST = (
            "lte-rrc.blackCellsToAddModList&&lte-rrc.eventId==5&&"
            "lte-rrc.measId==3&&lte-rrc.measId==4&&lte-rrc.reportConfigId==4"
        )
        self.RRC_A6_MEASUREMENT = "lte-rrc.measId==3&&lte-rrc.rsrpResult==97&&lte-rrc.rsrqResult==34"
        self.RRC_HO_INTRALTE = "lte-rrc.handoverType"
        self.PHY_SCELL_ID = "lte-rrc.physCellId "
        self.PHY_CELL_ID = "lte-rrc.physCellId_r10 "
        self.RRC_RELEASED_SCELL_INDEX = "lte-rrc.SCellIndex_r10"
        self.RRC_RELEASED_SCELLS_INDEX = "(lte-rrc.sCellIndex_r10 == 2) && (lte-rrc.sCellIndex_r10 == 1)"
        self.SRS_CONFIGURED_IN_SCELL = "lte-rrc.soundingRS_UL_ConfigDedicated_r10 == 1"
        self.CATM_UE_CAPABILITIES = (
            "lte-rrc.ce_ModeA_r13 == 0 && lte-rrc.accessStratumRelease == 5 && "
            "lte-rrc.ue_CategoryDL_v1310 == 1 && lte-rrc.ue_CategoryUL_v1310 == 1 && "
            "lte-rrc.ue_Category == 5"
        )
        self.TRANSMISSION_MODE_R10_TM4_MIMO_4x2_FL17SP_NEWER = (
            "lte-rrc.transmissionMode_r10 == tm4 && lte-rrc.codebookSubsetRestriction_r10 == ff:ff:ff:ff:ff:ff:ff:ff"
        )
        self.WIDEBAND_SRS = "lte-rrc.srs_Bandwidth == 2"
        self.UE_INFORMATION_RESPONSE = "lte-rrc.c1 == 11"
        self.UE_CONNECTION_RELEASE_NB = "lte-rrc.c1 == 2"

        self.UE_INFORMATION_REQUEST_WITH_LOG_MEAS_REPORT_REQ = (
            self.UE_INFORMATION_REQUEST + " && lte-rrc.logMeasReportReq_r10 == 0"
        )
        self.UE_INFORMATION_REQUEST_WITH_RACH_REPORT_REQ = (
            self.UE_INFORMATION_REQUEST + " && lte-rrc.rach_ReportReq_r9 == 1"
        )
        self.UE_INFORMATION_REQUEST_WITH_RLF_REPORT_REQ = (
            self.UE_INFORMATION_REQUEST + " && lte-rrc.rlf_ReportReq_r9 == 1"
        )
        self.UE_INFORMATION_RESPONSE_WITH_LOG_MEAS_REPORT = (
            self.UE_INFORMATION_RESPONSE + " && lte-rrc.logMeasReport_r10_element"
        )
        self.UE_INFORMATION_RESPONSE_WITH_RACH_REPORT = (
            self.UE_INFORMATION_RESPONSE + " && lte-rrc.rach_Report_r9_element"
        )
        self.UE_INFORMATION_RESPONSE_WITH_RLF_REPORT = (
            self.UE_INFORMATION_RESPONSE + " && lte-rrc.rlf_Report_r9_element"
        )
        self.UE_INFORMATION_REQUEST_WITH_LOG_MEAS_REPORT_REQ_FROM_ENB_IP = (
            self.UE_INFORMATION_REQUEST_WITH_LOG_MEAS_REPORT_REQ + " && ip.dst == 10.0.1.2"
        )
