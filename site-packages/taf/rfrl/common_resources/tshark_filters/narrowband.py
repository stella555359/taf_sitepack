# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: DevWro1
:maintainer: 5GSWEngWro
:contact: I_TA5G_SUPPORT <I_TA5G_SUPPORT@internal.nsn.com>
"""


class Narrowband(object):
    def __init__(self):
        self.RRC_CONNECTION_REJECT_NB = "lte-rrc.rrcConnectionReject_r13_element"
        self.MIB_NB = "lte-rrc.BCCH_BCH_Message_NB_element"
        self.DL_S1_INTERFACE_NB_DATA_FILTER = "s1ap.procedureCode == 11"
        self.RRC_PAGING_NB = "lte-rrc.pagingRecordList_r13 == 1"
        self.SIB1_NB = "lte-rrc.BCCH_DL_SCH_Message_NB_element && lte-rrc.c1==1"
        self.SIB2_NB = "lte-rrc.sib2_r13_element"
        self.SIB3_NB = "lte-rrc.sib3_r13_element"
        self.CELL_BARRED_NB = "lte-rrc.cellBarred_r13 == 0"
        self.CELL_NOT_BARRED_NB = "lte-rrc.cellBarred_r13 == 1"
        self.DL_UU_INTERFACE_NB_DATA_FILTER = "lte-rrc.DL_DCCH_Message_NB_element"
        self.EXTENDED_WAIT_TIME_NB = "lte-rrc.extendedWaitTime_r13"
        self.RRC_CONNECTION_RELEASE_NB = "lte-rrc.rrcConnectionRelease_r13_element"
        self.RRC_CONNECTION_SETUP_COMPLETE_NB = "lte-rrc.rrcConnectionSetupComplete_r13_element"
        self.NARROWBAND_SRS = "lte-rrc.srs_Bandwidth == 3"
        self.RESELECTION_ALLOWED_NB = "lte-rrc.intraFreqReselection_r13 == 0"
