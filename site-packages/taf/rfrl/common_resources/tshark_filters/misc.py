# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: DevWro1
:maintainer: 5GSWEngWro
:contact: I_TA5G_SUPPORT <I_TA5G_SUPPORT@internal.nsn.com>
"""


class Misc(object):
    def __init__(self):
        self.DEFAULT_S1_MME_SCTP = "sctp"
        self.SCTP_INIT = "sctp.chunk_type == init"
        self.SCTP_INIT_CREDIT = "sctp.init_credit"
        self.SCTP_INIT_CREDIT_ACKNOWLEDGE = "sctp.initack_credit"
        self.DEFAULT_UU_LESS_1000 = "less 1000"
        self.S1_X2_INTERFACE = "eth3"
        self.UU_INTERFACE = "eth4"
        self.DEFAULT_ENB_LMP = "dst port not 51000"
        self.DEFAULT_LOOPBACK = "(sctp || udp) && less 1000"
