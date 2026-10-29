from selenium import webdriver
from selenium.webdriver.common.by import By
from robot.api import logger
from pexpect import pxssh
import time
import re


def check_mass_popup(driver):
    driver.find_element_by_xpath("//h4[@title='Access Restrictions Alert']")
    driver.quit()


def log_to_webem(username, password):
    profileF = webdriver.FirefoxProfile()
    profileF.accept_untrusted_certs = True
    driver = webdriver.Firefox(firefox_profile=profileF)
    driver.get("https://192.168.255.129")
    username_field = driver.find_element_by_id("login-username")
    password_field = driver.find_element_by_id("login-password")
    username_field.send_keys(username)
    password_field.send_keys(password)
    login = driver.find_element(By.XPATH, '//span[text()="Login"]')
    login.click()
    time.sleep(10)
    return driver


def get_counter_measurements(dictionary):
    if type(list(dictionary.values())[0]) is not dict:
        return dictionary
    return get_counter_measurements(list(dictionary.values())[0])


def prepare_list_from_console(console_output, split_param="\r\n"):
    list_from_console_output = console_output.split(split_param)
    try:
        list_from_console_output.remove("/etc/swanctl/rsa/enbKey.pem")
    except Exception:
        print("/etc/ipsec.d/private/enbKey.pem is not on list")
    return list_from_console_output


def perform_ssh_event(hostname, username, event, password=None, ssh_key=None, auto_logout=False, idle_time=None,
                      close_conn=True, log_output=True):
    """
    Execute command by ssh using pxssh library.
    :param hostname:        ip host address, i.e. 192.168.255.129
    :param username:        i.e. toor4nsn
    :param event:           string with command to execute
    :param password:        i.e. oZPS0POrRieRtu
    :param ssh_key:         File path of ssh private key
    :param auto_logout:     Boolean indicates if auto logout is expected
    :param idle_time:       Int stores seconds needed for reach auto logout (applicable only when auto logout is set)
    :param close_conn:      Boolean indicates if connection will be closed or not
    :param log_output:      Boolean indicates if cmd output should be logged or not
    :return:                ssh connection if close_conn is False, None otherwise
    """
    assert ssh_key or password, "At least password or path to private ssh key must be provided!"
    s = pxssh.pxssh()
    if password:
        logger.console("SSH login with hostname={}, username={}, password={}".format(hostname, username, password))
        s.login(hostname, username, password, auto_prompt_reset=False, original_prompt=r" >")
    else:
        logger.console("SSH login with hostname={}, username={}, ssh_key={}".format(hostname, username, ssh_key))
        s.login(hostname, username, ssh_key=ssh_key, auto_prompt_reset=False, original_prompt=r" >")
    s.sendline(event)
    if log_output:
        s.prompt()
        logger.console("Executed event output: {}".format(s.before))
    if auto_logout:
        logger.console("Wait for auto logout for {}s inactivity...".format(idle_time))
        time.sleep(int(idle_time))
    else:
        logger.console("SSH logout")
        s.logout()
    if not close_conn:
        return s
    s.close()


def check_icmp_rules(output, option, interface):
    ipv4_egress_accepted = ["EGRESS_DEST_UNREACHABLE", "EGRESS_ECHO_REQUEST", "EGRESS_ECHO_RESPONSE",
                            "EGRESS_TIME_EXCEEDED", "EGRESS_PARAMETER_PROBLEM"]

    ipv4_ingress_accepted = ["INGRESS_DEST_UNREACHABLE", "INGRESS_ECHO_REQUEST", "INGRESS_ECHO_RESPONSE",
                             "INGRESS_TIME_EXCEEDED", "INGRESS_PARAMETER_PROBLEM"]

    ipv6_egress_accepted = ["V6EGRESS_DEST_UNREACHABLE", "V6EGRESS_ECHO_REQUEST", "V6EGRESS_ECHO_RESPONSE",
                            "V6EGRESS_TIME_EXCEEDED", "V6EGRESS_PARAMETER_PROBLEM", "V6EGRESS_PACKET_2BIG",
                            "EGRESS_NDP_CHAIN", "EGRESS_MLD_CHAIN"]

    ipv6_ingress_accepted = ["V6INGRESS_DEST_UNREACHABLE", "V6INGRESS_ECHO_REQUEST", "V6INGRESS_ECHO_RESPONSE",
                             "V6INGRESS_TIME_EXCEEDED", "V6INGRESS_PARAMETER_PROBLEM", "V6INGRESS_PACKET_2BIG",
                             "INGRESS_NDP_CHAIN", "INGRESS_MLD_CHAIN"]

    if option == "egress" and interface == "ipv4":
        check_icmp_rules_by_type(output, ipv4_egress_accepted)
    elif option == "egress" and interface == "ipv6":
        check_icmp_rules_by_type(output, ipv6_egress_accepted)
    elif option == "ingress" and interface == "ipv4":
        check_icmp_rules_by_type(output, ipv4_ingress_accepted)
    elif option == "ingress" and interface == "ipv6":
        check_icmp_rules_by_type(output, ipv6_ingress_accepted)


def check_icmp_rules_by_type(output, rules):
    for rule in rules:
        assert "accept" in re.search(".*chain\\s(" + rule + "\\s{.+?})", output).group(0), \
            "Rule {} should be accepted".format(rule)
