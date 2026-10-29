# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: DevWro1
:maintainer: 5GSWEngWro
:contact: I_TA5G_SUPPORT <I_TA5G_SUPPORT@internal.nsn.com>
"""


class XNAP(object):
    def __init__(self):
        self.XNAP = "xnap."
        self.XN_SETUP_REQUEST = self.XNAP + "XnSetupRequest_element"
        self.XN_SETUP_RESPONSE = self.XNAP + "XnSetupResponse_element"
        self.XN_SETUP_FAILURE = self.XNAP + "XnSetupFailure_element"
        self.XN_NG_RAN_NODE_CONFIGURATION_UPDATE_ACKNOWLEDGE =\
            self.XNAP + "NGRANNodeConfigurationUpdateAcknowledge_element"
        self.XNAP_HANDOVER_REQUEST = self.XNAP + "HandoverRequest_element"
        self.XNAP_HANDOVER_REQUEST_ACK = self.XNAP + "HandoverRequestAcknowledge_element"
        self.XNAP_SN_STATUS_TRANSFER = self.XNAP + "SNStatusTransfer_element"
        self.XNAP_UE_CONTEXT_RELEASE = self.XNAP + "UEContextRelease_element"
