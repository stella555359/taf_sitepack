from .relationships import relationship_to_tuple, relationship_to_dict
from .flattener import flatten


class IncludesWrapper(object):

    def __init__(self, included):
        self._included = {
            relationship_to_tuple(include): flatten(include) for include in included
        }

    def get(self, relationship):
        """
        Gets object from "included" by relationship. If not found - creates object from relationship.

        :param tuple relationship:
        :rtype: dict
        """
        return self._included.get(relationship, relationship_to_dict(relationship))
