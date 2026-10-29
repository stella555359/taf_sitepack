import xml.etree.ElementTree as et


def get_certificate_records(xml_path, element='showname'):
    records = []
    tree = et.parse(xml_path)
    root = tree.getroot()
    for record in root.findall('./packet/proto[@name="tls"]'
                               '/field[@name="tls.record"]'):
        records.append(record.get(element))
    return records


def get_certificate_signature_elements(xml_path, element='showname'):
    signature_elements = []
    tree = et.parse(xml_path)
    root = tree.getroot()
    for signature_element in root.findall('./packet/proto[@name="tls"]'
                                          '/field[@name="tls.record"]'
                                          '/field[@name="tls.handshake"]'
                                          '/field[@name="tls.handshake.certificates"]'
                                          '/field[@name="tls.handshake.certificate"]'
                                          '/field[@name="x509af.signedCertificate_element"]'
                                          '/field[@name="x509af.signature_element"]'):
        signature_elements.append(signature_element.get(element))
    return signature_elements


def find_certificate_in_extracted_pcap(xml_path, element='showname'):
    certificates = []
    tree = et.parse(xml_path)
    root = tree.getroot()
    for certificate in root.findall('./packet/proto[@name="tls"]'
                                    '/field[@name="tls.record"]'
                                    '/field[@name="tls.handshake"]/'
                                    'field[@name="tls.handshake.certificates"]'
                                    '/field[@name="tls.handshake.certificate"]'):
        certificates.append(certificate.get(element))
    return certificates


def get_nms_status(nms_list, manager_id):
    """Get NMS status based on Manager ID"""
    for nms in nms_list:
        for manager in nms['managerInfo']:
            if manager['managerId'] == manager_id:
                return nms['oamTlsStatus']


def get_certificates_from_tls_handshake(xml_path, element='showname'):
    certificates = []
    tree = et.parse(xml_path)
    root = tree.getroot()
    for certificate in root.findall('./packet/proto[@name="tls"]'
                                    '/field[@name="tls.record"]'
                                    '/field[@name="tls.handshake"]/'
                                    'field[@name="tls.handshake.certificates"]'
                                    '/field[@name="tls.handshake.certificate"]'):
        certificates.append(certificate.get(element))
    return certificates


def find_ciphersuites(xml_path, element='showname'):
    ciphersuites = []
    tree = et.parse(xml_path)
    root = tree.getroot()
    for ciphersuite in root.findall('./packet/proto[@name="tls"]'
                                    '/field[@name="tls.record"]'
                                    '/field[@name="tls.handshake"]'
                                    '/field[@name="tls.handshake.ciphersuite"]'):
        ciphersuites.append(ciphersuite.get(element))
    return ciphersuites
