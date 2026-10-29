# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: DevWro1
:maintainer: 5GSWEngWro
:contact: I_TA5G_SUPPORT <I_TA5G_SUPPORT@internal.nsn.com>
"""


class X2AP(object):
    def __init__(self):
        self.X2AP = "x2ap"
        self.X2AP_HANDOVER_REQUEST = "x2ap.procedureCode == 0"
        self.X2AP_HANDOVER_PREPARATION_FAILURE_NO_RESOURCES_AVAILABLE = "x2ap.radioNetwork == 12"
        self.X2AP_HANDOVER_PREPARATION_FAILURE_NOT_SUPPORTED_QCI = "x2ap.radioNetwork == 27"
        self.X2AP_RLF_INDICATION = "x2ap.RLFIndication_element"
        self.X2AP_RRCCONNSETUPINDICATOR = "x2ap.RRCConnSetupIndicator"
        self.SN_STATUS_TRANSFER = "x2ap.procedureCode == 4"
        self.X2AP_HANDOVER_RESTRICTION_LIST = "x2ap.handoverRestrictionList_element"
        self.MOBILITY_SETTINGS_CHANGE = "x2ap.procedureCode == 12"
        self.MOBILITY_SETTINGS_CHANGE_ACK = "x2ap.MobilityChangeAcknowledge_element"
        self.MOBILITY_SETTINGS_CHANGE_FAILURE = "x2ap.MobilityChangeFailure_element"
        self.RESOURCE_STATUS_UPDATE = "x2ap.procedureCode == 10"
        self.X2_SETUP_REQUEST = "x2ap.ENDCX2SetupRequest_element"
        self.X2_SETUP_RESPONSE_SUCCESSFUL = "x2ap.ENDCX2SetupResponse_element"
        self.X2_CONFIGURATION_UPDATE = "x2ap.procedureCode == 8"
        self.RSU_ABS_MUTINGPATTERN_0 = "x2ap.usable_abs_pattern_info == 00:00:00:00:00"
        self.RSU_ABS_MUTINGPATTERN_6 = "x2ap.usable_abs_pattern_info == 77:77:77:77:77"
        self.X2_CONFIG_UPDATE_ACK = "x2ap.ENBConfigurationUpdateAcknowledge_element && ip.src == 10.0.1.1"
        self.X2_CONFIG_UPDATE_TO_GNB = (
            "x2ap.ENBConfigurationUpdate_element && ip.src == 10.0.1.2 && ip.dst == 10.0.1.5"
        )
        self.X2AP_UE_CONTEXT_RELEASE = "x2ap.UEContextRelease_element"
        self.X2AP_SGNB_RELEASE_REQUEST = "x2ap.procedureCode == 31 && x2ap.id == 5"
        self.X2AP_SGNB_CHANGE_REQUIRED = "x2ap.SgNBChangeRequired_element"
        self.X2AP_SGNB_CHANGE_CONFIRM = "x2ap.SgNBChangeConfirm_element"
        self.X2AP_SGNB_CHANGE_REFUSE = "x2ap.SgNBChangeRefuse_element"
        self.X2AP_SGNB_ADDITION_REQUEST = "x2ap.SgNBAdditionRequest_element"
        self.X2AP_SGNB_ADDITION_REQUEST_ACKNOWLEDGE = "x2ap.SgNBAdditionRequestAcknowledge_element"
        self.X2AP_SGNB_RECONFIGURATION_COMPLETE = "x2ap.SgNBReconfigurationComplete_element"
        self.X2AP_SGNB_RELEASE_CONFIRM = "x2ap.SgNBReleaseConfirm_element"
        self.X2AP_SGNB_RELEASE_REQUIRED = "x2ap.SgNBReleaseRequired_element"
        self.X2AP_SGNB_MODIFICATION_CONFIRM = "x2ap.SgNBModificationConfirm_element"
        self.X2AP_SGNB_MODIFICATION_REQUIRED = "x2ap.SgNBModificationRequired_element"
        self.X2AP_SGNB_MODIFICATION_REQUEST_ACKNOWLEDGE = "x2ap.SgNBModificationRequestAcknowledge_element"
        self.X2AP_SGNB_MODIFICATION_REQUEST = "x2ap.SgNBModificationRequest_element"
        self.X2AP_SGNB_RELEASE_ACKNOWLEDGE = "x2ap.SgNBReleaseRequestAcknowledge_element"
