from robot.api import logger
import datetime
from binascii import unhexlify
import re


def get_operator_certificates(cert_list):
    return [cert for cert in cert_list if cert['source'] == 'Operator']


def get_certificates_fingerprints(cert_list):
    try:
        return [cert['fingerPrint'] for cert in cert_list]
    except KeyError:
        logger.warn('Unknown certificate fingerprint.')


def delete_multiple_certificates(fingerprints, connection):
    for fingerprint in fingerprints:
        connection.delete_certificate(fingerprint=fingerprint)


def verify_ecdsa_certificates(certs_list, subject_name):
    ecdsa_certs = [cert for cert in certs_list if cert['keyPoolType'] == 'ECDSA' and cert['issuer'] == subject_name]

    if len(ecdsa_certs) > 0:
        logger.warn('Lack of ECDSA certificates')

    for cert in ecdsa_certs:
        if cert['type'] == 'TrustAnchor':
            if cert['issuedTo'] == subject_name:
                assert cert['issuedTo'] == subject_name, 'Wrong subject value'

        if cert['type'] == 'EndEntity':
            check_cert_creation_date(cert['validFrom'])


def check_cert_creation_date(valid_from_timestamp):
    valid_from_date = datetime.strptime(valid_from_timestamp, '%b %d %H:%M:%S %Y %Z').date()
    today_date = datetime.now().date()

    assert valid_from_date == today_date, 'Wrong validFrom date'


def check_if_private_perms_assured_by_cryptoagent(perms):
    perms = perms.split("\n")[1:-1]
    pattern = re.compile(".*[-r][-w][-x][-r]-[-x][-r]-[-x]")
    failures = []
    for i in perms:
        if "cryptoagent" in i or "keys.d" in i or "ssh" in i:
            if not pattern.match(i):
                failures.append(i)
    if failures == []:
        logger.warn('Permissions inappropiate in: {}')


def check_if_private_perms_list(perms):
    perms = perms.split("\n")[1:-1]
    pattern = re.compile(".*[-r][-w][-x][-r]-[-x][-r]-[-x]")
    failures = []
    for i in perms:
        if not pattern.match(i):
            failures.append(i)
    if failures == []:
        logger.warn('Permissions inappropiate in: {}')


def verify_rsa_certificates(certs_list, subject_name):
    rsa_certs = [cert for cert in certs_list if cert['keyPoolType'] == 'RSA' and cert['issuer'] == subject_name]

    if len(rsa_certs) > 0:
        logger.warn('Lack of RSA certificates')

    for cert in rsa_certs:
        if cert['type'] == 'TrustAnchor':
            if cert['issuedTo'] == subject_name:
                assert cert['issuedTo'] == subject_name, 'Wrong subject value'

        if cert['type'] == 'EndEntity':
            check_cert_creation_date(cert['validFrom'])


def verify_vendor_certificates(vendor_certs):
    certificate_full_names = ["TrustAnchor", "CertificateAuthority", "EndEntity"]
    bts_certs = []
    for cert in vendor_certs:
        for data in cert:
            if data == "type":
                bts_certs.append(cert[data])
    return set(bts_certs) == set(certificate_full_names)


def check_cert_error_alarm(alarms_info):
    for alarm in alarms_info:
        if alarm['faultName'] == 'CRL Update failure or certificate revoked':
            return True
    return False


def get_restore_vendor_certificate_error_code(error_msg):
    return error_msg[error_msg.index("ErrorCode"):]


def get_failure_reason_of_certificate(crl_list):
    for cert in crl_list:
        return cert['stateInfo']['reasoningStatus']
    return False


def generate_certificate_file(file_name):
    HEX_DATA = '30820cc102010330820c8706092a8648' \
               '86f70d010701a0820c7804820c743082' \
               '0c703082072706092a864886f70d0107' \
               '06a0820718308207140201003082070d' \
               '06092a864886f70d010701301c060a2a' \
               '864886f70d010c0106300e04086b502c' \
               '3c195e17b702020800808206e0ba7187' \
               '659c5d20a30bc4de2541150c150ce96a' \
               '2c85c628708f887e7d5194e7dcf260a0' \
               '6b3828afb369862123c107a1c0a72e5b' \
               '098114b2703dbb945b07590ab58cf3d2' \
               '99a18203537829bb8b490697d7cf1030' \
               'f18d6b6aa808206758344b00f43b21dd' \
               'a53ce69e0169b27f295621d97bcf61ff' \
               '99f03abbd77aecd11f79a88dd379ba17' \
               '849fd69caff4a1e51e7452d9fe60c965' \
               'ad2a30d1c659f00950ea1a4d0640dbd1' \
               'f0c3da7a7f9fd3ad9e217bc2bd961aff' \
               '0efe7bee4aeedf2be00d143ea8e0ac07' \
               '6e2cdc8c98909ab31e45bb25322a884c' \
               '7682b7283925a6a60b088ab4f14c1fc2' \
               '2fb7b88f4e902a55cecb43be2a3f5299' \
               'c8ece441c06b46b071d2172dc35b392c' \
               'ceaf37f63093fb21c09b280329b47db4' \
               '3b39b120bc5344852f156df7b00ea797' \
               'bd0a51db926e7cd4142da3f60852621f' \
               'cd3e67ab2360a71929064a86b8d85511' \
               '8bff04443c1863683920e8a5f5e15cbf' \
               'b26fda6ed81fcda227ed749759f710e9' \
               'c8bf2498742700c8bdc7792c26253738' \
               '9aca8bfb32f926cc3fcc76a26a7fa850' \
               'd6916a3f68f35a9a384a6d23ad76fb7d' \
               'd63ae57dc1eb43b4749888bce848616c' \
               '88e08c3b9f437340937d4f4aee8b2899' \
               '59377de53db70b36a73fcf020a2e5613' \
               'fea4811ab7365705dd23a9f846b1c78f' \
               '7ea9fa3e8ce432617f5b6f8aabc5dde4' \
               '63d75ac898231c2861b06997f7448a91' \
               'cdfc5990e98a90b2682757298c83117f' \
               '29f5377445c013a297482a54813f60cd' \
               '739e94442b8f5f7adad6455882f17850' \
               'b418c9e4590aa0640387517ac97f0ca5' \
               '849708e4b147219a84ca1b9941153a31' \
               '68e7f638c08732a8f3fb885bef65c18f' \
               '171222df5976d3c7eaea1f97210237c0' \
               '80fa90472e7915d93ded6008f45ba968' \
               '74a345548f0cd1e26e6e848befc9c1ad' \
               '8db2886c3c8be075a1ba959da6351be8' \
               'e895cc2fd3946c75d21aa5770ee26aaf' \
               'd7b9f0eba722edf44ee1202063877aa5' \
               'c916f0ae6d34a242e9616f93ddc0dc1b' \
               '5c4ef91c5e0d3b23c2687e915436d7c9' \
               '774e83ccc5cb0773b33b0c18845153a3' \
               '88f65ce47bfc7bd826447b79dc747260' \
               'f06abea3d7a894e7809580c5d28d7032' \
               '672f6ac82880ec9c258250877d28e092' \
               '08a6ddcb5287ab3332a50a8ab00859e5' \
               'c6d9d0e72371407f8232da1d6cf1ff20' \
               '8db86ec77eb76d2796e68fb2c219e957' \
               '06db6440b10b0393c03495b58fefa1ad' \
               '78ddf2b8dcc21aa095922fbf6fcc9056' \
               '41690114744d072519403bcf9a4c05c0' \
               'c9a1a3b65dd49210e12c4756d52c01a6' \
               '9ec1f5cba15b4216bdb942174b16935a' \
               '2c9e393a1f745b2647b4f7b9e99b6e84' \
               '377165efe2e66a970f1cb794e98d6660' \
               '9ea1cb5781ad7ed3a1640acf28aab097' \
               '4a7a2ffd7398ff66bbd25f180ebf1a47' \
               'c91b2e686463be5259768f46fb6378c9' \
               '8078f6922ad1ab19b21f6d6f63a4a939' \
               '1b215993cb0b39515ba9147f1a3c0226' \
               'a7ca4efe95f5d36aa85bb28feca20245' \
               '205e649bf1d2a7e410b322e6a929f82a' \
               '45f6c9f8685d7dfb26be6fbdf9a07d65' \
               '65bdd86e528f0a508bb9e83c75c3a082' \
               '4fe434a60b22dbe0313a868daba2fba7' \
               '4c65944a4e090703fa928a33ea643606' \
               '7d85453f6a8cadd121ba3743613b23b1' \
               '2921c408a73edbed3726348e6bd93f20' \
               'ac23cb438a59a3417ace8347a48dede1' \
               '0ceffb48e232a0b6a7a81d442634ff75' \
               'ccffbb98c5c25660398e985090ff1db8' \
               '5d1252634df6f5eddfc30e8dfe5da5e4' \
               '7ff4d3d9a8715b2154f38ce85c5771db' \
               '6e2a97fdcb84a9da7cdc8ccb605e0527' \
               '2bc3a4d04f4cd2793a5aa65881f2a9e2' \
               'cb67bb54b17c748a49d1d93b3f8696e1' \
               'ea48b05f6fa48e91d13bc885a4437c4e' \
               'cb2b1ecf1be5bc2272a32ed58457f5ea' \
               '3a2fd662e7cce5d3baba116b918cd525' \
               'b81f6de78da3f077fc5d65f547cad710' \
               'bfe7a190d5e66549f301b47141140ea6' \
               '500c431b03486308e7e4310ad7ab4c0e' \
               '5fdbd811d8685b225befeb902770a683' \
               '16f504e71fe0173818bad927ef72b646' \
               'f4d7cd521a1744e5940d7ff907f107c1' \
               'c86918a028ad199f64e007aec371f8da' \
               '389d32fbb17721561f50473633cc8d1c' \
               '29d93c9e049f6f977f213f6ae73d540e' \
               'b4129a1a5e00ed5219c3aed2b185f3ef' \
               '5a6fd9bfb77b8abb5f3d45ff8162fec7' \
               '3253f0b6cf3144746e6c85e6c3d228f2' \
               'd6c08db94c27129a54092398f8ab25b4' \
               '2444562cc729fa186ac6c0d03a3eaf47' \
               '50b62e766be7e4a3c40d3ce67f1d011e' \
               '69ff5ce7050609f71583d90f9402d882' \
               '301f2acb86a4653b1864c83eafb0e4eb' \
               '24e4db065702585839bc83937d299ffe' \
               'f5b900dd094d55a73fef5a82cf2e4c0f' \
               'a075a15f2cef0923b4f6568a1415e4c6' \
               '777d3f12e4369211d0effd46974fec07' \
               '4117e31c51ac8f0a1436f3b224f8efed' \
               'b7cc9dc3ed6a7da0990969483bc4a7ef' \
               'cfb82ad5184683ffc9d688a6dd631d17' \
               '1e83bc4b0c8c5289daaaa29bfe02bb3f' \
               'ec1d00d5f080c4320620e9bbe0468d51' \
               'd840457e6c5af39174ed3433de308205' \
               '4106092a864886f70d010701a0820532' \
               '0482052e3082052a30820526060b2a86' \
               '4886f70d010c0a0102a08204ee308204' \
               'ea301c060a2a864886f70d010c010330' \
               '0e04082ee75e3e4bd21e440202080004' \
               '8204c822b55c10dae56676838a77b32b' \
               'f0b0e717f5636805e951447cf56252e9' \
               '8418a60d40bf80896a6a9e6aa638085f' \
               '89c423a66d3eb987ce3f61f35ccd1fbc' \
               '6f982b479dc2a00310d3529871de457f' \
               '8dea696c8a1922c4463a6bc87837f810' \
               'faa4d23b1144bf6adbdbea978f293660' \
               '6f8043135eb4de8b539f8b854cea1f24' \
               '51821098194d3a30cd49873a79489fdc' \
               '641093827aa25b15259eb783f5c06472' \
               '8d903c88d7c6ea2a01bb54d4815911f2' \
               'ee656ae449cb030c9a707c44c1b08f9d' \
               '0cbb453ab1a6fc5127d7a979eafadb38' \
               'c39a93e2b63148e0432ab0bdfeea7499' \
               'a4cd187873ad2086ef3892db469ed6cf' \
               'f0b6739984059b8139dc3e3aaf46aff0' \
               'fce468ebea476ac379683c5c8f3f6782' \
               '14b6510875a77c0de62ba7b903c6b71f' \
               '19986a4f0288a0caa6d28583fabd8ed8' \
               '21ee4d68deab7f72122aaf2c2f6c6b86' \
               '14c616b38afe6224a93168d1cb634726' \
               '6fc9eaf0865e4fa3aef470ee88a3c85d' \
               'fc8368c1a613917c7abce1a6e7a31e9a' \
               'ba5d7d10d77e1735e8460cec5cc56fca' \
               '597dfaaa1fedfe605fa073d61ee9d3d4' \
               '18ae79de205881380206cf77d06c1d95' \
               '3b0a4ad19619a02ce5be0bce0676e65c' \
               'a685990f09c457ef055276c8398f0ce6' \
               '6b8c299315e9b5650f8fcdf6704dfc08' \
               'bdfa41f00079f828679790815f3dc2e8' \
               '36fffcb7690c04193ee91daba3d1f4bb' \
               '74f2d354f1faebb0a836a038aa8b11be' \
               '327f9a4fa1b1091680d925b4ebc7f12a' \
               'c26d61cafb69a10223c3f7ee2589016d' \
               '18848cbbd64a928298fde07e629a7e72' \
               '4418bfa109a4b7dc659e0536f5a2e1aa' \
               'dbd13c84aaecb5474b0e956743d531bd' \
               '41f8758d7a9672b7ae4ceb1357fd865e' \
               'f4e8e7a359bbb0dd400e01e387c8d722' \
               '990fb492bd4b8cad054903e184bc9fe5' \
               '934058e2085c0b5a1a913354244fab14' \
               'd48e3c494549b35499dd333d9d0668c2' \
               'ac9c35fdc86473767014f402e04c1f60' \
               '890699164ce23bf26e1aeb1a59400d23' \
               '501a5ff1fd9729bd26b632de74056fab' \
               '4252b638c404fb7030e0aec35f471c1a' \
               'dde4c1f85d4c87a034543ac244e37aba' \
               'caf66c968bd9de34a931e4586746a24f' \
               'fbc5e00ff70b0c11c8734b5f223ad583' \
               '4bf2876132037de668882ca507fda10c' \
               '16db74b37b338fc16f096cdb5866897b' \
               '5cbf4939e2c9222559f820d0df8ee841' \
               'c40f739fa41dbfd3b865985451ab5cca' \
               '011f617b26a8d4c76b70965ad8c4899c' \
               '2495678f1ee92de79b1cbe697e983d85' \
               '9e3ca9de8a50a9be457ff3ccf89aca76' \
               '66c5d9ed6c59c36129d1f4fe60c95aed' \
               '0b9f24e9d2194c664530520836208cd2' \
               '698ac91d3dc5555712d3ad694a2f27f5' \
               '062bc819a32e7088780b927a9b6dc63c' \
               'c9f8365cc129278eca014f0a5c499fbf' \
               'e71c2efd24b3975942e269ae5f78020f' \
               '18ff99e226f15ad4f157785764575be9' \
               '6ffdd4096aa303b717863ab1e078ccd7' \
               '291b06708ea7509c11317d28799d7f9f' \
               'de3b7b668cd153ae9c915779d705c92e' \
               'f76054fc2e37c4acfde06fe7e7e9b856' \
               '97218b79ad81bd745de48280071efab0' \
               '027b77a3596e8414f606e171b7d92758' \
               '7003b85ca68136d0db022f462e845bae' \
               '34dfdf18752bf8e59c934b70cc9e9f64' \
               '9ac59c50eec7e27be1f54bcfbe19858d' \
               '4d7712b0929ce7e9495aca9fdb29b154' \
               '31de8dfe5c58c6c6055a759b99baa7fd' \
               '5a4d39ca325bad005bcc2e8039f9a3fe' \
               '34267c62d8e399490a567787d6904a17' \
               '8c8fa18ea6d5beccce3d483125302306' \
               '092a864886f70d010915311604149821' \
               'ffb5894769ebe21178d74ecf1e7426a7' \
               'eea230313021300906052b0e03021a05' \
               '00041418595170adb3924017f3c9304c' \
               'db51b9aa2b3ec90408bc29c2dd7fbafe' \
               '4302020800'
    binary_data = unhexlify(HEX_DATA)
    with open(file_name, 'wb') as file_out:
        file_out.write(binary_data)


def get_cert_validity(cert_list, sw_release_name, fingerprint=None):
    if not cert_list:
        logger.error("Following cert list is empty: " + str(cert_list))
    if fingerprint:
        cert_position = -1
        for i, cert in enumerate(cert_list):
            try:
                if cert['fingerPrint'] == fingerprint:
                    cert_position = int(i)
            except ValueError as e:
                raise ValueError("There is no fingerprint field in record: " + str(cert)) from e
        if cert_position == -1:
            logger.error("There is no cert with following fingeprint: " + str(fingerprint))
    else:
        cert_position = 0
    try:
        cert_valid_date = cert_list[cert_position]['validTo']
    except ValueError as e:
        raise ValueError("There's no field validTo for:" + str(cert_list) + " at position " + str(cert_position)) from e

    try:
        if 'SBTS24R1' in sw_release_name or 'SBTS23R4' in sw_release_name or 'SBTS23R3' in sw_release_name:
            cert_valid_date = datetime.datetime.strptime(cert_valid_date, "%b %d %H:%M:%S %Y %Z")
            cert_valid_month = cert_valid_date.month
            cert_valid_year = cert_valid_date.year
            cert_valid_day = cert_valid_date.day
            cert_valid_hour = cert_valid_date.hour
            cert_valid_min = cert_valid_date.minute
            cert_valid_sec = cert_valid_date.second
        else:
            cert_valid_date = datetime.datetime.fromisoformat(cert_valid_date)
            cert_valid_month = cert_valid_date.month
            cert_valid_year = cert_valid_date.year
            cert_valid_day = cert_valid_date.day
            cert_valid_hour = cert_valid_date.hour
            cert_valid_min = cert_valid_date.minute
            cert_valid_sec = cert_valid_date.second
    except ValueError as e:
        raise ValueError("There is an issue with conversion following date " + str(cert_valid_date)) from e

    cert_valid_datetime = datetime.datetime(cert_valid_year,
                                            cert_valid_month,
                                            cert_valid_day,
                                            cert_valid_hour,
                                            cert_valid_min,
                                            cert_valid_sec,
                                            tzinfo=datetime.timezone.utc)
    current_time = datetime.datetime.now(datetime.timezone.utc)
    cert_diff = (cert_valid_datetime - current_time).days
    return cert_diff


def check_add_cert_validity(add_cert_validity):
    valid_threshold = str(30)
    if int(add_cert_validity) < int(valid_threshold):
        if int(add_cert_validity) < 2:
            logger.error("Validity of End Entity cert from P12 file is less than 1 day. Please use a new one "
                         + "with validity at least" + valid_threshold + " days.")
        else:
            logger.warn("Validity of End Entity cert from P12 file (" + str(add_cert_validity) + " days) "
                        + "is below threshold (" + valid_threshold + " days). Please use (commit in repo) "
                        + "a newer cert.")


def check_certs_validity(add_cert_validity, bts_cert_validity):
    return int(add_cert_validity) < int(bts_cert_validity)


def check_fault_in_alarm_list(alarm_list, fault_id_expected):
    for alarm in alarm_list:
        fault_id_present = alarm['faultId']
        if str(fault_id_present) == str(fault_id_expected):
            return True
    return False


def get_bts_certificate_names(cert_name_element):
    bts_certificates = cert_name_element.partition("commonName=")[2]
    bts_certificates = list(bts_certificates.split(','))
    return bts_certificates


def get_list_of_params_for_crldpconfig_object(insta):
    params_list = [
        {"parameterName": "primaryCRLDP", "operation": "update", "value":
            "http://{}:8080/crl-as-der/currentcrl-3295210.crl?id=3295210".format(insta)},
        {"parameterName": "crldpconfigId", "operation": "update", "value": 1}
    ]
    return params_list
