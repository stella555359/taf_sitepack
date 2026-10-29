# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Rashmi R
:contact: rashmi.r@nokia.com
:maintainer: Rashmi R
:contact: rashmi.r@nokia.com
"""

from robot.libraries.BuiltIn import BuiltIn
import logging


class store(object):
    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'
    _namespace = "aliasstore"

    def __init__(self, **kwargs):
        super(store, self).__init__(**kwargs)
        self._builtin = self._create_builtin()

    def _create_builtin(self):
        return BuiltIn()

    def set_alias(self, alias, obj):
        if "::" not in alias:
            alias = "::".join([self._namespace, alias])
        self._builtin._variables["${%s}" % alias] = obj

    def get_alias_value(self, alias):
        if "::" not in alias:
            alias = "::".join([self._namespace, alias])
        value = self._builtin.get_variable_value("${%s}" % alias)
        if value is None:
            logging.warning(
                "Alias {alias!r} is not defined. "
                "Hint: After calling a create keyword, which uses an alias, you often need to set the scope"
                " of the alias, e. g. via set_suite_alias(). "
                "See https://confluence.ext.net.nokia.com/display/CV/_Collector+Concepts#id-_CollectorConcepts-"
                "AliasScopes".format(alias=alias))
        return value

    def set_suite_alias(self, alias):
        if "::" not in alias:
            alias = "::".join([self._namespace, alias])
        self._builtin.set_suite_variable("${%s}" % alias)

    def set_test_alias(self, alias):
        if "::" not in alias:
            alias = "::".join([self._namespace, alias])
        self._builtin.set_test_variable("${%s}" % alias)

    def set_global_alias(self, alias):
        if "::" not in alias:
            alias = "::".join([self._namespace, alias])
        self._builtin.set_global_variable("${%s}" % alias)

    def set_scope(self, alias, scope):
        if scope == "global":
            self.set_global_alias(alias)
        elif scope == "suite":
            self.set_suite_alias(alias)
        elif scope == "test":
            self.set_test_alias(alias)
