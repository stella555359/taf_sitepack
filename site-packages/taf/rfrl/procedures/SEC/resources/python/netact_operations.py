import taf.gnb.oam.ne3s.ws as netact


def connect_using_netact(ip_address, debug, debug_log_path, netact_server_address=None,
                         netact_server_port=10000, **kwargs):
    na_instance = netact.ws()
    na_instance.configure_connection(ip_address, debug=debug, debug_log_path=debug_log_path,
                                     netact_server_address=netact_server_address,
                                     netact_server_port=netact_server_port, **kwargs)
    if 'alias' in kwargs:
        na_instance.connect(kwargs['alias'])
    else:
        na_instance.connect()
    return na_instance


def get_audit_trail_logs(na_instance, adaptation_version, path):
    return na_instance.get_audit_trail_logs(destination_path=path, adaptation_version=adaptation_version, timeout=1200)


def teardown_all_connections(na_instance):
    return na_instance.teardown_all()


def unregister_and_teardown(na_instance):
    unregister_connection(na_instance)
    teardown_all_connections(na_instance)


def unregister_connection(na_instance):
    return na_instance.unregister()
