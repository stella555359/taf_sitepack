# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: DevWro1
:maintainer: 5GSWEngWro
:contact: I_TA5G_SUPPORT <I_TA5G_SUPPORT@internal.nsn.com>
"""


class S1AP(object):
    def __init__(self):
        self.S1AP_DETACH_COMPLETE = "s1ap.procedureCode == 23 && s1ap.S1AP_PDU == 0"
        self.S1AP_HANDOVER_REQUEST = "s1ap.procedureCode == 1"
        self.S1AP_HANDOVER_PREPARATION = "s1ap.procedureCode == 0"
        self.S1AP_HANDOVER_PREPARATION_FAILURE_NO_RESOURCES_AVAILABLE = "s1ap.radioNetwork == 12"
        self.S1AP_HANDOVER_PREPARATION_FAILURE_NOT_SUPPORTED_QCI = "s1ap.radioNetwork == 37"
        self.S1AP_HANDOVER_SUCCESSFUL = "s1ap.radioNetwork == 2"
        self.S1AP_HANDOVER_RESTRICTION_LIST = "s1ap.HandoverRestrictionList_element"
        self.INITIAL_CONTEXT_SETUP_REQUEST = "s1ap.procedureCode == 9 && ip.src == 10.0.1.1"
        self.SUCC_S1_SETUP_RESPONSE = "s1ap.procedureCode == 17 && s1ap.S1AP_PDU == 1"
        self.S1_SETUP_REQUEST = "s1ap.procedureCode == 17 && s1ap.S1AP_PDU == 0"
        self.S1_MME_CONFIGURATION_UPDATE_SUCC_OUTCOME = "s1ap.procedureCode == 30 && s1ap.S1AP_PDU == 1"
        self.S1_UE_CONTEXT_MODIFICATION = "s1ap.procedureCode == 21"
        self.S1_UE_CONTEXT_RELEASE_REQUEST = "s1ap.procedureCode == 18"
        self.S1_UE_CONTEXT_RELEASE = "s1ap.procedureCode == 23"
        self.S1_UE_CONTEXT_RELEASE_COMMAND = "s1ap.UEContextReleaseCommand_element"
        self.S1_UE_CONTEXT_RELEASE_COMPLETE = "s1ap.S1AP_PDU == 1 && s1ap.procedureCode == 23"
        self.S1_UE_CAPABILITY_INFO_INDICATION = "s1ap.procedureCode == 22"
        self.ENB_CONFIGURATION_TRANSFER = "s1ap.procedureCode == 40"
        self.MME_CONFIGURATION_TRANSFER = "s1ap.procedureCode == 41"
        self.S1AP_UE_CONTEXT_RELEASE_COMPLETE = "s1ap.UEContextReleaseComplete_element"
        self.S1AP_INITIAL_CONTEXT_SETUP = "s1ap.InitialContextSetupResponse_element"
        self.S1AP_MAXIMUM_BIT_RATE_UL = "s1ap.uEaggregateMaximumBitRateUL"
        self.S1AP_MAXIMUM_BIT_RATE_DL = "s1ap.uEaggregateMaximumBitRateDL"
        self.S1AP_ERAB_SETUP_REQUEST = "s1ap.procedureCode == 5"
        self.S1AP_CONNECTION_ESTABLISHMENT_INDICATION = "s1ap.procedureCode == 54"
        self.UE_RELEASE_CAUSED_BY_USER_INACTIVITY = "s1ap.radioNetwork == 20"
        self.NAS_NON_DELIVERY_INDICATION_FILTER = "s1ap.procedureCode == 16"
        self.S1AP_UPLINK_NAS_TRANSPORT = "s1ap.procedureCode == 13"
        self.S1AP_REROUTE_NAS_REQUEST = "s1ap.RerouteNASRequest_element"
        self.SRS_CONFIGURED_IN_PCELL = "lte-rrc.soundingRS_UL_ConfigDedicated == 1"
        self.EDRX_ALLOWED_FILTER = "lte-rrc.eDRX_Allowed_r13 == 0"
        self.S1AP_INITIAL_UE_MESSAGE = "s1ap.procedureCode == 12"
        self.S1_CONFIGURATION_UPDATE = "s1ap.procedureCode == 29"
        self.S1AP_CAUSE_DETACH = "s1ap.nas == 2"
        self.S1AP_PATH_SWITCH_REQUEST_ACKNOWLEDGE = "s1ap.PathSwitchRequestAcknowledge_element"
        self.S1AP_E_RAB_MODIFY_RESPONSE = "s1ap.procedureCode == 6"
        self.S1AP_E_RAB_MODIFICATION_INDICATION = "s1ap.E_RABModificationIndication_element"
        self.S1AP_E_RAB_MODIFICATION_CONFIRM = "s1ap.E_RABModificationConfirm_element"
