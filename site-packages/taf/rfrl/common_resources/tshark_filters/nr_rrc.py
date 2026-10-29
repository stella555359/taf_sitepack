# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: DevWro1
:maintainer: 5GSWEngWro
:contact: I_TA5G_SUPPORT <I_TA5G_SUPPORT@internal.nsn.com>
"""


class NrRrc(object):
    def __init__(self):
        self.SECURITY_MODE_COMMAND = "nr-rrc.securityModeCommand_element"
        self.SECURITY_MODE_COMPLETE = "nr-rrc.securityModeComplete_element"
        self.SECURITY_MODE_FAILURE = "nr-rrc.securityModeFailure_element"
        self.RRC_SETUP = "nr-rrc.rrcSetup_element"
        self.RRC_SETUP_COMPLETE = "nr-rrc.rrcSetupComplete_element"
        self.RRC_RELEASE = "nr-rrc.rrcRelease_element"
        self.RRC_RESUME = "nr-rrc.rrcResume_element"
        self.RRC_RESUME_COMPLETE = "nr-rrc.rrcResumeComplete_element"
        self.RRC_SETUP_REQUEST = "nr-rrc.rrcSetupRequest_element"
        self.RRC_RESUME_REQUEST = "nr-rrc.rrcResumeRequest_element"
        self.RRC_RESUME_REQUEST_1 = "nr-rrc.rrcResumeRequest1_element"
        self.RRC_REJECT = "nr-rrc.rrcReject_element"
        self.UPLINK_INFORMATION_TRANSFER = "nr-rrc.ulInformationTransfer_element"
        self.DOWNLINK_INFORMATION_TRANSFER = "nr-rrc.dlInformationTransfer_element"
        self.RRC_RECONFIGURATION = "nr-rrc.rrcReconfiguration_element"
        self.RRC_RECONFIGURATION_COMPLETE = "nr-rrc.rrcReconfigurationComplete_element"
        self.RECONFIGURATION_WITH_SYNC = "nr-rrc.reconfigurationWithSync_element"
        self.RRC_MEASUREMENT_REPORT = "nr-rrc.measurementReport_element"
        self.RRC_REESTABLISHMENT = "nr-rrc.rrcReestablishment_element"
        self.RRC_REESTABLISHMENT_COMPLETE = "nr-rrc.rrcReestablishmentComplete_element"
        self.UE_CAPABILITY_ENQUIRY = "nr-rrc.ueCapabilityEnquiry_element"
        self.UE_CAPABILITY_INFORMATION = "nr-rrc.ueCapabilityInformation_element"
        self.RRC_CELL_IDENTITY = "nr-rrc.cellIdentity"
        self.CELL_BARRED = "nr-rrc.cellBarred == 0"
        self.CELL_NOT_BARRED = "nr-rrc.cellBarred == 1"
        self.MIB = "nr-rrc.mib_element"
        self.SIB1 = "nr-rrc.systemInformationBlockType1_element"
        self.SIB2 = "nr-rrc.sib2_element"
        self.SIB3 = "nr-rrc.sib3_element"
        self.SIB4 = "nr-rrc.sib4_element"
        self.SIB5 = "nr-rrc.sib5_element"
        self.EVENT_A1 = "nr-rrc.eventA1_element"
        self.EVENT_A2 = "nr-rrc.eventA2_element"
        self.EVENT_A5 = "nr-rrc.eventA5_element"
