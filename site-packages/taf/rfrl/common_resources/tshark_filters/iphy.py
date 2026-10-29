# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: DevWro1
:maintainer: 5GSWEngWro
:contact: I_TA5G_SUPPORT <I_TA5G_SUPPORT@internal.nsn.com>
"""


class Iphy(object):
    def __init__(self):
        self.UE = "iphy.ue_id"
        self.PAGING = "iphy.message.type == 0x0040"
        self.ENB = "iphy.sender.id"
