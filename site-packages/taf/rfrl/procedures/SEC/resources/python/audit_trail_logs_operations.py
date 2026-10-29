from datetime import datetime, timedelta
import re

from robot.api import logger


SESSION_TIME_REG = r"[0-9]{4}-[0-9]{1,2}-[0-9]{1,2}T[0-9]{1,2}:[0-9]{1,2}:[0-9]{1,2}"
SESSION_TIME_FORMAT = "%Y-%m-%dT%H:%M:%S"


class TrailLogsParser:
    """Parse audit trail logs into the list of LogMessages"""
    LOG_MSG_PREFIX = "<log xmlns="

    def __init__(self):
        self._raw_logs = []
        self.log_msgs = []

    def load(self, log_file):
        """
        Read audit trail logs output file as raw logs.
        :param log_file:    File path to the audit trail logs file
        """
        with open(log_file, 'r') as f:
            self._raw_logs = f.readlines()

    def parse(self):
        """
        Split whole output by LOG_MSG_PREFIX into separate log messages,
        represented by LogMessage object model. Expected log_msgs structure:
        [<LogMessageobject>, ...]
        """
        log_data = []
        if self._raw_logs is None:
            logger.console("Cannot parse - self._raw_logs are None, check input file with ATL logs...")
            return
        for line in self._raw_logs:
            if line.startswith(self.LOG_MSG_PREFIX):
                if log_data:
                    self.log_msgs.append(LogMessage(log_data))
                    log_data = []
            log_data.append(line)
        # add last LogMessage to log msgs
        self.log_msgs.append(LogMessage(log_data))


class LogMessage:
    """Model for single log message from audit trail logs. Each log message
    is built within the following structure:
    log
        header: string
        operations:
            operation 1: Operation
            ...
    Where Operation has the following structure
    record:
        sessionTime: string
        sessionID: number
        userName: string
    clientIPAddress: string
    operation: string
    logStatus: string
    additionalText: string

    Example:
    <log logFileName="atl.log" logType="AUDIT" NEName="MRBTS-50279" id="MRBTS-50279"
    creationTime="2021-12-13T12:13:26+01:00">
    <header>Record Log</header>
    <record sessionTime="2021-08-13T11:23:31+01:00" sessionID="344321" userName="Nemuadmin">
    <clientIPAddress>192.168.255.126</clientIPAddress>
    <operation>WebEM session establishment</operation>
    <logStatus>Success</logStatus>
    <additionalText>additionalText:SM-1011 Login as ReadWrite</additionalText>
    </record><record sessionTime="2021-12-13T10:05:11+01:00" sessionID="307457" userName="Nemuadmin">
    ...
    </log>
    """
    PARAMS = ['operation', 'logStatus', 'additionalText',
              'clientIpAddress']
    RECORD = "record"
    RECORD_PARAMS = ['sessionTime', 'sessionID', 'userName']
    HEADER = "header"
    LOG_TAG = "log xmlns="
    LOG_TAG_PARAMS = ['logFileName', 'logType', 'NEName', 'id', 'creationTime']

    def __init__(self, data):
        self.header = self.extract_header(data)
        self.log_tag = self.extract_log_tag_data(data)
        self.operations = self.extract_operations(data)

    def __str__(self):
        return str(self.header + '\n' + str([str(operation) for operation in self.operations]))

    def extract_header(self, data):
        """
        Header is expected to be placed between <header> tags
        :param data:  audit trail logs output as list of lines
        """
        for line in data:
            if '<{}>'.format(self.HEADER) in line:
                return self.filter_param(line)

    def extract_log_tag_data(self, data):
        for line in data:
            if '<{}'.format(self.LOG_TAG) in line:
                return self.extract_data_from_log_elem(line)

    def extract_data_from_log_elem(self, line):
        """
        Get params inside record as dict.
        :param line:   String with log line from raw audit trail logs output
        :return:       Dict with record params
        """
        data = {}
        for part in line.split(' '):
            for param in self.LOG_TAG_PARAMS:
                if param in part:
                    name, value = part.split('=')
                    data[name] = self.filter_record(value)
        return data

    def extract_operations(self, data):
        """
        Each operation should start with <record> tag. As record has nested values,
        it has to be parsed separately.
        :param data:  audit trail logs output as list of lines
        :return:      List of operations where single operation is dictionary with params.
                      Example: [{'record': {'sessionTime', ...}, 'additionalText': "..."}, ...]
        """
        operations = []
        operation = {}
        for line in data:
            if "<{}".format(self.RECORD) in line:
                if operation:
                    operations.append(operation)
                    operation = {}
                operation[self.RECORD] = self.extract_data_from_record(line)
            for param in self.PARAMS:
                if "<{}>".format(param) in line:
                    operation[param] = self.filter_param(line)

        # add last operation
        operations.append(operation)
        return operations

    def extract_data_from_record(self, line):
        """
        Get params inside record as dict.
        :param line:   String with log line from raw audit trail logs output
        :return:       Dict with record params
        """
        data = {}
        for part in line.split(' '):
            for param in self.RECORD_PARAMS:
                if param in part:
                    elems = part.split('=')
                    if len(elems) == 2:
                        name, value = elems
                        data[name] = self.filter_record(value)
        return data

    @staticmethod
    def filter_param(line):
        """
        Extract value between tags using regex.
        If no tags are found in line, then None is returned
        Example:
        "<additionalText>values</additionalText>" -> "values"
        :param line:   String with log line from raw audit trail logs output
        :return:       Value between tags from line
        """
        line = re.findall(r"<.*>(.*?)</.*>", line, flags=0)
        if line:
            return line[0].strip()

    @staticmethod
    def filter_record(value):
        """
        Remove all unwanted special characters from record log line.
        :param value:   Raw value of attribute of record tag
        :return:        Cleaned value
        """
        return re.sub(r"^[^\w\-+:.]+|[^\w\-+:.]+$", ' ', value).strip()


def read_file(_file):
    """
    :param _file:  String with log file path
    :return:       List of log lines
    """
    with open(_file, 'r') as f:
        return f.readlines()


def clean_trail_logs(raw_trail_logs_data):
    """
    Remove all unwanted chars which may be present in raw trail logs output
    :param raw_trail_logs_data:         List of lines of raw trail logs
    :return:                            Lines which do not contain unwanted chars
    """
    unwanted_non_ascii_chars = ["\x00", ]
    return [line for line in raw_trail_logs_data
            if all(_ not in line for _ in unwanted_non_ascii_chars)]


def save_file(data, output="Cleaned_logs.txt"):
    """
    :param data:    List of string lines
    :param output:  File path to output file
    :return:        Saved output file path
    """
    with open(output, 'w') as f:
        f.writelines(data)
    return output


def recreate_trail_logs_with_filtering(trail_log_file, output_file):
    """
    Open raw trail log file, clean the content and save as a new file.
    :param trail_log_file:  raw trail log file
    :return:                File path to filtered trail log file
    """
    lines = read_file(trail_log_file)
    lines = clean_trail_logs(lines)
    new_log_file = save_file(lines, output=output_file)
    return new_log_file


def filter_trail_logs_for_date(trail_log_file, logs_age_in_s, output="filtered_cleaned_logs.txt"):
    """
    Filter atl logs by logs age - select only records which are not older than logs_age_in_s
    (current time is the time measurement starting point).
    For example, if logs_age_ins_s=900, then it's expected that filtered output of atl logs
    will store only such records which are not older than 15 min (60*15).
    :param trail_log_file:  File path to the cleaned atl logs
    :param logs_age_in_s:   Max allowed logs age in seconds
    :param output:          File path to the atl filtered logs
    :return:                File path to the atl filtered logs
    """
    date_dt = datetime.now() - timedelta(seconds=int(logs_age_in_s))
    filtered_lines = []
    log_should_be_copied = False
    with open(trail_log_file, 'r') as f:
        lines = f.readlines()

    for line in lines:
        if "sessionTime" in line:
            parts = re.findall(SESSION_TIME_REG, line)
            if len(parts) > 0:
                session_time = parts[0]
                session_time_dt = datetime.strptime(session_time, SESSION_TIME_FORMAT)
                if session_time_dt >= date_dt and not log_should_be_copied:
                    logger.console("Session time: {} younger than {}s, start copying from this log entry...".format(
                        session_time, logs_age_in_s))
                    log_should_be_copied = True
        if log_should_be_copied or line.startswith("<log xmlns=") or line.startswith("<header>"):
            filtered_lines.append(line)

    save_file(filtered_lines, output=output)
    return output


def check_atl_logs(atl_logs_file, exp_operation, exp_mrbts_id, additional_text="", log_status="Success"):
    """
    Verify exp_operation presence in atl logs.
    :param atl_logs_file:       File path to the logs with atl file (exp. cleaned version which are not
                                                                     include other irrelevant log msgs)
    :param exp_operation:       Expected operation string (may be substring also)
    :param exp_mrbts_id:        MRBTS id integer
    :param additional_text:     Expected additional text of operation ((may be substring also)
    """
    parser = TrailLogsParser()
    parser.load(atl_logs_file)
    parser.parse()
    for log_msg in parser.log_msgs:
        for operation in log_msg.operations:
            if exp_operation in str(operation.get('operation', "")) \
                    and str(exp_mrbts_id) in str(log_msg.log_tag.get('id', "")) \
                    and additional_text in str(operation.get('additionalText', "")) \
                    and log_status in str(operation.get('logStatus', "")):
                logger.console("Exp: operation found: {}, additional text: {}, log status: {} <>"
                               "Act: operation found: {}".format(exp_operation, additional_text,
                                                                 log_status, operation))
                assert True
                return
    assert False, "No operation: {} with additional_text: {} and log_status: {} found in atl logs!".format(
        exp_operation, additional_text, log_status)


def check_if_operation_is_not_present_in_atl_logs(atl_logs_file, unwanted_operation, additional_text=""):
    """
    Verify unwanted_operation is not present in atl logs.
    :param atl_logs_file:       File path to the logs with atl file (exp. cleaned version which are not
                                                                     include other irrelevant log msgs)
    :param unwanted_operation: Unwanted operation string (may be substring also)
    """
    parser = TrailLogsParser()
    parser.load(atl_logs_file)
    parser.parse()
    for log_msg in parser.log_msgs:
        for operation in log_msg.operations:
            if unwanted_operation in str(operation.get('operation', "")) \
                    and additional_text in str(operation.get('additionalText', "")):
                assert False, "Unwanted operation: {} with additional_text: {} found in atl logs!".format(
                    unwanted_operation, additional_text)
    logger.console("No operation: {} with additional text: {} found in atl logs!".format(unwanted_operation,
                                                                                         additional_text))
    assert True
