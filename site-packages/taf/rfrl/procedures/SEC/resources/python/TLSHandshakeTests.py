import xml.etree.ElementTree as ET
from robot.api import logger
from robot.errors import ExecutionFailed


class XMLPcapAnalyzer(object):
    """Library for analyzing PCAP converted to XML"""
    CLIENT_HELLO = '1'

    def __init__(self):
        self.root = None

    def get_all_client_hello_packets(self):
        """Get packets with Client Hello message"""
        for idx, packet in enumerate(self.root.findall('packet')):
            for handshake_type in packet.findall('.//*[@name="tls.handshake.type"]'):
                if handshake_type.get('show') == self.CLIENT_HELLO:
                    yield Packet(packet, idx)

    def get_all_packets(self):
        """Get all packets from pcap"""
        for idx, packet in enumerate(self.root.findall('packet')):
            yield Packet(packet, idx)

    def get_packet_by_frame_number(self, frame_number):
        for packet in self.get_all_packets():
            if packet.frame_number == frame_number:
                return packet

    def get_packet_by_index(self, packet_idx):
        """Get nth packet from pcap"""
        for idx, packet in enumerate(self.root.findall('packet')):
            if idx == packet_idx:
                return Packet(packet, idx)

    def load_xml_file(self, xml_filepath):
        """
        Method for initializing instance with path to XML file
        """
        self.root = ET.parse(xml_filepath).getroot()


class TLSHandshakeTests(XMLPcapAnalyzer):
    TLS_HANDSHAKE_MESSAGES = {
        'Client Hello': '1',
        'Server Hello': '2',
        'Certificate': '11',
        'Server Key Exchange': '12',
        'Server Hello Done': '14',
        'Change Cipher Spec': '20',
        'Application Data': '23'
    }

    def __init__(self):
        super(TLSHandshakeTests, self).__init__()

    def test_if_application_data_is_present(self, frame_number):
        current_frame = self.get_packet_by_frame_number(frame_number)
        current_packet = self.get_packet_by_index(current_frame.idx)
        if self.TLS_HANDSHAKE_MESSAGES['Application Data'] in current_packet.content_type:
            logger.info(current_packet, also_console=True)
            return
        raise ExecutionFailed('Application Data not found')

    def test_tls_handshake_process(self):
        """
        Test if pcap file contains all TLS1.3 Handshake messages in given order:
        Client Hello (1) -> Server Hello (2) -> Change Cipher Spec (20) -> Application Data (23)

        Messages have to be located in the same or adjacent packet.

        In case of test success, dictionary with wanted TLS packets is printed to the console.
        ExecutionFailure exception is raised in case of test failure.
        """

        tls_handshake_msgs = {
            'Client Hello': False,
            'Server Hello': False,
            'Change Cipher Spec': False,
            'Application Data': False
        }

        client_hello_packets = self.get_all_client_hello_packets()
        for packet in client_hello_packets:
            current_packet = packet
            tls_handshake_msgs['Client Hello'] = current_packet
            tls_handshake_msgs['Server Hello'] = self.get_subsequent_tls_handshake_packet(current_packet,
                                                                                          msg_type='Server Hello')

            if tls_handshake_msgs['Server Hello']:
                current_packet = tls_handshake_msgs['Server Hello']
                tls_handshake_msgs['Change Cipher Spec'] = \
                    self.get_subsequent_tls_handshake_packet(current_packet, msg_type='Change Cipher Spec')

            if tls_handshake_msgs['Change Cipher Spec']:
                current_packet = tls_handshake_msgs['Change Cipher Spec']
                tls_handshake_msgs['Application Data'] = self.check_app_data(current_packet)

            if all([value for value in tls_handshake_msgs.values()]):
                logger.info('All TLS Handshake messages found.\n', also_console=True)
                logger.info(tls_handshake_msgs, also_console=True)
                return
            else:
                for key in tls_handshake_msgs:
                    tls_handshake_msgs[key] = False

        logger.error('Unable to find all TLS Handshake messages.')
        raise ExecutionFailed('Unable to find all TLS Handshake messages.')

    def test_tls12_handshake_process(self):
        """
        Test if pcap file contains all TLS1.2 Handshake messages in given order:
        Client Hello (1) -> Server Hello (2) -> Certificate (11) -> Server Key Exchange (12) ->
        Server Hello Done (14) -> Application Data (23)

        Messages have to be located in the same or adjacent packet.

        In case of test success, dictionary with wanted TLS packets is printed to the console.
        ExecutionFailure exception is raised in case of test failure.
        """
        tls12_handshake_msgs = {
            'Client Hello': False,
            'Server Hello': False,
            'Certificate': False,
            'Server Key Exchange': False,
            'Server Hello Done': False,
            'Application Data': False
        }

        client_hello_packets = self.get_all_client_hello_packets()
        for packet in client_hello_packets:
            current_packet = packet
            tls12_handshake_msgs['Client Hello'] = current_packet
            tls12_handshake_msgs['Server Hello'] = self.get_subsequent_tls_handshake_packet(current_packet,
                                                                                            msg_type='Server Hello')

            if tls12_handshake_msgs['Server Hello']:
                current_packet = tls12_handshake_msgs['Server Hello']
                tls12_handshake_msgs['Certificate'] = \
                    self.get_subsequent_tls_handshake_packet(current_packet, msg_type='Certificate')

            if tls12_handshake_msgs['Certificate']:
                current_packet = tls12_handshake_msgs['Certificate']
                tls12_handshake_msgs['Server Key Exchange'] = \
                    self.get_subsequent_tls_handshake_packet(current_packet, msg_type='Server Key Exchange')

            if tls12_handshake_msgs['Server Key Exchange']:
                current_packet = tls12_handshake_msgs['Server Key Exchange']
                tls12_handshake_msgs['Server Hello Done'] = \
                    self.get_subsequent_tls_handshake_packet(current_packet, msg_type='Server Hello Done')

            if tls12_handshake_msgs['Server Hello Done']:
                current_packet = tls12_handshake_msgs['Server Hello Done']
                tls12_handshake_msgs['Application Data'] = self.check_app_data(current_packet)

            if all([value for value in tls12_handshake_msgs.values()]):
                logger.info('All TLS Handshake messages found.\n', also_console=True)
                logger.info(tls12_handshake_msgs, also_console=True)
                return
            else:
                for key in tls12_handshake_msgs:
                    tls12_handshake_msgs[key] = False

            logger.error('Unable to find all TLS Handshake messages.')
            raise ExecutionFailed('Unable to find all TLS Handshake messages.')

    def get_subsequent_tls_handshake_packet(self, packet, msg_type):
        """Check if current or next packet contains subsequent message to message of given type of TLS Handshake.
        Returns packet object with found message type or False if message not found.
        """
        next_packet = self.get_packet_by_index(packet_idx=packet.idx + 1)
        if self.TLS_HANDSHAKE_MESSAGES[msg_type] in self.get_corresponding_field_value(packet, msg_type):
            return packet
        elif self.TLS_HANDSHAKE_MESSAGES[msg_type] in self.get_corresponding_field_value(next_packet, msg_type):
            return next_packet
        return False

    @staticmethod
    def get_corresponding_field_value(packet, msg_type):
        """Get specific packet field depending on message type"""
        if msg_type in ['Client Hello', 'Server Hello', 'Certificate', 'Server Key Exchange', 'Server Hello Done']:
            return packet.handshake_type
        elif msg_type in ['Change Cipher Spec', 'Application Data']:
            return packet.content_type
        else:
            raise ValueError('Invalid message type.')

    def check_app_data(self, packet):
        """
        Check if there is application data packets until next Client Hello message.
        Returns application data packet if found or False if not found.
        """
        current_packet = packet
        while self.TLS_HANDSHAKE_MESSAGES['Client Hello'] not in current_packet.handshake_type:
            if self.TLS_HANDSHAKE_MESSAGES['Application Data'] in current_packet.content_type:
                return current_packet
            current_packet = self.get_packet_by_index(current_packet.idx + 1)
        return False


class Packet:
    """
    Parser for XML packets.
    Class fields contain common packet's attributes. Feel free to add more in similar way.
    """

    def __init__(self, packet, packet_idx):
        """
        @param packet:       XML Element with tag "packet"
        @param packet_idx:   Index of packet object in list of all packets in XML file
        """
        self.idx = packet_idx
        self.frame_number = packet.find('proto').find('field').get('show')
        self.description = self._get_desc(packet)
        self.handshake_type = self._get_handshake_type(packet)
        self.content_type = self._get_content_type(packet)
        self.cipher_suites = self._get_cipher_suites(packet)

    def __repr__(self):
        return 'PACKET {}\nFrame number: {}\nPacket info: {}\n\n'.format(self.idx, self.frame_number, self.description)

    @staticmethod
    def _get_cipher_suites(packet):
        return [p.get('show') for p in packet.findall('.//*[@name="tls.handshake.ciphersuite"]')]

    @staticmethod
    def _get_content_type(packet):
        content_type = packet.findall('.//*[@name="tls.record.content_type"]')
        opaque_type = packet.findall('.//*[@name="tls.record.opaque_type"]')
        fields_list = content_type + opaque_type
        return [p.get('show') for p in fields_list]

    @staticmethod
    def _get_desc(packet):
        return [p.get('showname')
                for p in packet.find('.//proto[@name="tls"]').findall('.//field[@name="tls.record"]')]

    @staticmethod
    def _get_handshake_type(packet):
        return [p.get('show') for p in packet.findall('.//*[@name="tls.handshake.type"]')]
