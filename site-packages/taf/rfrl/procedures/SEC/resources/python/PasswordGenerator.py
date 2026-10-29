import random
import string


class PasswordGenerator:
    def __init__(self):
        self.non_alphanumeric_characters = "!#$%&()*+,-.;=?@[]_~/"
        self.non_acceptable_chars = [
            0x00,
            0x01,
            0x02,
            0x03,
            0x04,
            0x05,
            0x06,
            0x07,
            0x08,
            0x09,
            0x0A,
            0x0B,
            0x0C,
            0x0D,
            0x0E,
            0x0F,
            0x10,
            0x11,
            0x12,
            0x13,
            0x14,
            0x15,
            0x16,
            0x17,
            0x18,
            0x19,
            0x1A,
            0x1B,
            0x1C,
            0x1D,
            0x1E,
            0x1F,
            0x20,
            0x7F,
            0x3C,
            0x3E,
            0x22,
            0x7B,
            0x7D,
            0x7C,
            0x5C,
            0x5E,
            0x60,
            0x3A,
        ]
        self.min_allowed_password_length = 8
        self.max_allowed_password_length = 128

    def _get_random_digit(self, count):
        """Provide random digit."""
        return "".join([random.choice(string.digits) for _ in range(count)])

    def _get_random_upper_case_letter(self, count):
        """Provide random upper case letter."""
        return "".join([random.choice(string.ascii_uppercase) for _ in range(count)])

    def _get_random_lower_case_letter(self, count):
        """Provide random lower case letter."""
        return "".join([random.choice(string.ascii_lowercase) for _ in range(count)])

    def _get_random_non_alphanumerical_character(self, count):
        """Provide random acceptable non-alphanumeric character."""
        return "".join(
            [random.choice(self.non_alphanumeric_characters) for _ in range(count)]
        )

    def _get_random_disallowed_character(self, count):
        """Provide random non-acceptable symbol."""
        return "".join(
            [chr(random.choice(self.non_acceptable_chars)) for _ in range(count)]
        )

    def _check_no_two_same_characters_consecutively(self, password):
        reference = password[0]
        for character in password[1:]:
            if character == reference:
                return True
            else:
                reference = character
        return False

    def _generate_password(
        self,
        allowed_characters,
        must_have_characters,
        min_length=8,
        max_length=128,
        valid=True,
    ):
        password_length = random.randint(min_length, max_length)
        allowed_characters_list = list(allowed_characters)
        must_have_characters_list = list(must_have_characters)
        if password_length < len(must_have_characters_list):
            must_have_characters_list = must_have_characters_list[:password_length]
        password = "".join(
            random.sample(must_have_characters_list, len(must_have_characters_list))
        )
        password_length -= len(must_have_characters)
        password += "".join(
            [random.choice(allowed_characters_list) for _ in range(password_length)]
        )
        password = "".join(random.sample(list(password), len(list(password))))
        if valid:
            while self._check_no_two_same_characters_consecutively(password):
                password = "".join(random.sample(list(password), len(list(password))))
        return password

    def get_valid_password(self):
        allowed_characters = (
            string.ascii_letters + string.digits + self.non_alphanumeric_characters
        )
        must_have_characters = (
            self._get_random_digit(count=2)
            + self._get_random_lower_case_letter(count=1)
            + self._get_random_upper_case_letter(count=1)
            + self._get_random_non_alphanumerical_character(count=1)
        )
        return self._generate_password(
            allowed_characters=allowed_characters,
            must_have_characters=must_have_characters,
        )

    def get_too_long_password(self):
        allowed_characters = (
            string.ascii_letters + string.digits + self.non_alphanumeric_characters
        )
        must_have_characters = (
            self._get_random_digit(count=2)
            + self._get_random_lower_case_letter(count=1)
            + self._get_random_upper_case_letter(count=1)
            + self._get_random_non_alphanumerical_character(count=1)
        )
        return self._generate_password(
            allowed_characters=allowed_characters,
            must_have_characters=must_have_characters,
            min_length=129,
            max_length=256,
            valid=False,
        )

    def get_too_short_password(self):
        allowed_characters = (
            string.ascii_letters + string.digits + self.non_alphanumeric_characters
        )
        must_have_characters = (
            self._get_random_digit(count=2)
            + self._get_random_lower_case_letter(count=1)
            + self._get_random_upper_case_letter(count=1)
            + self._get_random_non_alphanumerical_character(count=1)
        )
        return self._generate_password(
            allowed_characters=allowed_characters,
            must_have_characters=must_have_characters,
            min_length=1,
            max_length=7,
            valid=False,
        )

    def get_only_one_digit_password(self):
        allowed_characters = string.ascii_letters + self.non_alphanumeric_characters
        must_have_characters = (
            self._get_random_digit(count=1)
            + self._get_random_lower_case_letter(count=1)
            + self._get_random_upper_case_letter(count=1)
            + self._get_random_non_alphanumerical_character(count=1)
        )
        return self._generate_password(
            allowed_characters=allowed_characters,
            must_have_characters=must_have_characters,
            valid=False,
        )

    def get_no_digit_password(self):
        allowed_characters = string.ascii_letters + self.non_alphanumeric_characters
        must_have_characters = (
            self._get_random_lower_case_letter(count=1)
            + self._get_random_upper_case_letter(count=1)
            + self._get_random_non_alphanumerical_character(count=1)
        )
        return self._generate_password(
            allowed_characters=allowed_characters,
            must_have_characters=must_have_characters,
            valid=False,
        )

    def get_no_upper_case_password(self):
        allowed_characters = (
            string.ascii_lowercase + string.digits + self.non_alphanumeric_characters
        )
        must_have_characters = (
            self._get_random_digit(count=2)
            + self._get_random_lower_case_letter(count=1)
            + self._get_random_non_alphanumerical_character(count=1)
        )
        return self._generate_password(
            allowed_characters=allowed_characters,
            must_have_characters=must_have_characters,
        )

    def get_no_lower_case_password(self):
        allowed_characters = (
            string.ascii_uppercase + string.digits + self.non_alphanumeric_characters
        )
        must_have_characters = (
            self._get_random_digit(count=2)
            + self._get_random_upper_case_letter(count=1)
            + self._get_random_non_alphanumerical_character(count=1)
        )
        return self._generate_password(
            allowed_characters=allowed_characters,
            must_have_characters=must_have_characters,
        )

    def get_with_disallowed_character_password(self):
        allowed_characters = (
            string.ascii_letters + string.digits + self.non_alphanumeric_characters
        )
        must_have_characters = (
            self._get_random_digit(count=2)
            + self._get_random_lower_case_letter(count=1)
            + self._get_random_upper_case_letter(count=1)
            + self._get_random_non_alphanumerical_character(count=1)
            + self._get_random_disallowed_character(count=1)
        )
        return self._generate_password(
            allowed_characters=allowed_characters,
            must_have_characters=must_have_characters,
        )

    def get_two_same_characters_consecutively_password(self):
        allowed_characters = (
            string.ascii_letters + string.digits + self.non_alphanumeric_characters
        )
        must_have_characters = (
            self._get_random_digit(count=2)
            + self._get_random_lower_case_letter(count=1)
            + self._get_random_upper_case_letter(count=1)
            + self._get_random_non_alphanumerical_character(count=1)
        )
        password = self._generate_password(
            allowed_characters=allowed_characters,
            must_have_characters=must_have_characters,
        )
        while not self._check_no_two_same_characters_consecutively(password):
            password = "".join(random.sample(list(password), len(list(password))))
        return password

    def get_contains_username_in_straight_form_password(self, username):
        allowed_characters = (
            string.ascii_letters + string.digits + self.non_alphanumeric_characters
        )
        must_have_characters = (
            self._get_random_digit(count=2)
            + self._get_random_lower_case_letter(count=1)
            + self._get_random_upper_case_letter(count=1)
            + self._get_random_non_alphanumerical_character(count=1)
        )
        password = self._generate_password(
            allowed_characters=allowed_characters,
            must_have_characters=must_have_characters,
            max_length=self.max_allowed_password_length - len(username),
        )
        index_insert_position = random.randint(0, len(password))
        password = (
            password[:index_insert_position]
            + username
            + password[index_insert_position:]
        )
        return password

    def get_contains_username_in_reversed_form_password(self, username):
        allowed_characters = (
            string.ascii_letters + string.digits + self.non_alphanumeric_characters
        )
        must_have_characters = (
            self._get_random_digit(count=2)
            + self._get_random_lower_case_letter(count=1)
            + self._get_random_upper_case_letter(count=1)
            + self._get_random_non_alphanumerical_character(count=1)
        )
        password = self._generate_password(
            allowed_characters=allowed_characters,
            must_have_characters=must_have_characters,
            max_length=self.max_allowed_password_length - len(username),
        )
        index_insert_position = random.randint(0, len(password))
        password = (
            password[:index_insert_position]
            + username[::-1]
            + password[index_insert_position:]
        )
        return password

    def get_no_special_character_password(self):
        allowed_characters = string.ascii_letters + string.digits
        must_have_characters = (
            self._get_random_digit(count=2)
            + self._get_random_lower_case_letter(count=1)
            + self._get_random_upper_case_letter(count=1)
        )
        return self._generate_password(
            allowed_characters=allowed_characters,
            must_have_characters=must_have_characters,
        )

    def get_custom_length_password(self, length):
        allowed_characters = (
            string.ascii_letters + string.digits + self.non_alphanumeric_characters
        )
        must_have_characters = (
            self._get_random_digit(count=2)
            + self._get_random_lower_case_letter(count=1)
            + self._get_random_upper_case_letter(count=1)
            + self._get_random_non_alphanumerical_character(count=1)
        )
        return self._generate_password(
            allowed_characters=allowed_characters,
            must_have_characters=must_have_characters,
            min_length=length,
            max_length=length,
        )
