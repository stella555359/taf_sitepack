# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: 5G_SW_WRO
:maintainer: 5G_SW_WRO
:contact: I_TA5G_SUPPORT <I_TA5G_SUPPORT@internal.nsn.com>
"""


class E1AP(object):
    def __init__(self):
        self.E1AP_BEARER_CONTEXT_MODIFICATION_REQUIRED = "e1ap.BearerContextModificationRequired_element"
        self.E1AP_BEARER_CONTEXT_MODIFICATION_REQUEST = "e1ap.BearerContextModificationRequest_element"
        self.E1AP_BEARER_CONTEXT_MODIFICATION_RESPONSE = "e1ap.BearerContextModificationResponse_element"
        self.E1AP_BEARER_CONTEXT_MODIFICATION_CONFIRM = "e1ap.BearerContextModificationConfirm_element"
        self.E1AP_BEARER_CONTEXT_SETUP_REQUEST = "e1ap.BearerContextSetupRequest_element"
        self.E1AP_BEARER_CONTEXT_SETUP_RESPONSE = "e1ap.BearerContextSetupResponse_element"
        self.E1AP_BEARER_CONTEXT_RELEASE_COMMAND = "e1ap.BearerContextReleaseCommand_element"
        self.E1AP_BEARER_CONTEXT_RELEASE_COMPLETE = "e1ap.BearerContextReleaseComplete_element"
        self.E1AP_RESET = "e1ap.Reset_element"
        self.E1AP_RESET_ACKNOWLEDGE = "e1ap.ResetAcknowledge_element"
        self.E1AP_UE_ID = "e1ap.GNB_CU_CP_UE_E1AP_ID"
        self.E1AP_BEARER_CONTEXT_INACTIVITY_NOTIFICATION = "e1ap.BearerContextInactivityNotification_element"
