"""
:author: Lukasz Wesolowski
:contact: lukasz.wesolowski@nokia.com
"""


class IncorrectBshNumber(Exception):
    """
    Raised when incorrect bsh number.
    """
    pass


class NodeIdNotFound(Exception):
    """
    Raised when node ID cannot be found.
    """
    pass


class DeviceHostnameNotFound(Exception):
    """
    Raised when device hostname could not be found.
    """
    pass


class CommandError(Exception):
    """
    Raised when command execution has failed.
    """
    pass
