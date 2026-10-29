# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: DevWro1
:maintainer: 5GSWEngWro
:contact: I_TA5G_SUPPORT <I_TA5G_SUPPORT@internal.nsn.com>
"""


class F1AP(object):
    def __init__(self):
        self.F1AP_UE_CONTEXT_SETUP_REQUEST = "f1ap.UEContextSetupRequest_element"
        self.F1AP_UE_CONTEXT_SETUP_RESPONSE = "f1ap.UEContextSetupResponse_element"
        self.F1AP_UE_CONTEXT_RELEASE_REQUEST = "f1ap.UEContextReleaseRequest_element"
        self.F1AP_UE_CONTEXT_RELEASE_COMMAND = "f1ap.UEContextReleaseCommand_element"
        self.F1AP_UE_CONTEXT_RELEASE_COMPLETE = "f1ap.UEContextReleaseComplete_element"
        self.F1AP_PAGING = "f1ap.Paging_element"
        self.F1AP_RESET = "f1ap.Reset_element"
        self.F1AP_RESET_ACKNOWLEDGE = "f1ap.ResetAcknowledge_element"
        self.F1AP_DL_RRC_MESSAGE_TRANSFER = "f1ap.DLRRCMessageTransfer_element"
        self.F1AP_INITIAL_UL_RRC_MESSAGE_TRANSFER = "f1ap.InitialULRRCMessageTransfer_element"
        self.F1AP_UL_RRC_MESSAGE_TRANSFER = "f1ap.ULRRCMessageTransfer_element"
        self.F1AP_GNB_CONFIGURATION_UPDATE = "f1ap.GNBDUConfigurationUpdate_element"
        self.F1AP_GNB_CONFIGURATION_UPDATE_ACKNOWLEDGE = "f1ap.GNBDUConfigurationUpdateAcknowledge_element"
        self.F1AP_GNB_CU_CONFIGURATION_UPDATE = "f1ap.GNBCUConfigurationUpdate_element"
        self.F1AP_GNB_CU_CONFIGURATION_UPDATE_ACKNOWLEDGE = "f1ap.GNBCUConfigurationUpdateAcknowledge_element"
        self.F1AP_UE_CONTEXT_MODIFICATION_REQUEST = "f1ap.UEContextModificationRequest_element"
        self.F1AP_UE_CONTEXT_MODIFICATION_RESPONSE = "f1ap.UEContextModificationResponse_element"
        self.F1AP_UE_ID = "f1ap.GNB_CU_UE_F1AP_ID"
        self.F1AP_WRITE_REPLACE_WARNING_REQUEST = "f1ap.WriteReplaceWarningRequest_element"
        self.F1AP_WRITE_REPLACE_WARNING_RESPONSE = "f1ap.WriteReplaceWarningResponse_element"
        self.DRBS_TO_BE_MODIFIED_LIST = "f1ap.DRBs_ToBeModified_List"
        self.F1AP_NETWORK_ACCESS_RATE_REDUCTION = "f1ap.NetworkAccessRateReduction_element"
        self.F1AP_GNBDU_STATUS_INDICATION_ELEMENT = "f1ap.GNBDUStatusIndication_element"
        # enumeration from 3gpp f1 ap protocol specification release 15, enumeration: cause -> causeRadioNetwork -> ...
        self.F1AP_UNSPECIFIED = "f1ap.radioNetwork == 0"
        self.F1AP_NORMAL_RELEASE = "f1ap.radioNetwork == 10"
        self.AMF_INITIATED_ABNORMAL_RELEASE = "f1ap.radioNetwork == 15"
