# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: DevWro1
:maintainer: 5GSWEngWro
:contact: I_TA5G_SUPPORT <I_TA5G_SUPPORT@internal.nsn.com>
"""


class NasEps(object):
    def __init__(self):
        self.S1_UE_ATTACH_COMPLETE = "nas_eps.nas_msg_emm_type == 0x43"
        self.UE_INFORMATION_REQUEST_EXTENDED_SERVICE_REQ = "nas_eps.nas_msg_emm_type == 0x4c"
        self.RRC_CONNECTION_RECONFIGURATION_ACTIVATE_DEFAULT_BEARER = "nas_eps.nas_msg_esm_type == 0xc1"
        self.NAS_CPLN_SERVICE_REQUEST = "nas_eps.emm.ctrl_plane_serv_type == 0"
