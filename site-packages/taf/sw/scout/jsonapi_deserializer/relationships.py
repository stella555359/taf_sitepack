def relationship_to_tuple(relationship):
    """
    :param dict relationship:
    :rtype: tuple
    """
    return relationship['type'], relationship['id']


def relationship_to_dict(relationship):
    """
    :param tuple relationship:
    :rtype: dict
    """
    return {
        'type': relationship[0],
        'id': relationship[1]
    }
