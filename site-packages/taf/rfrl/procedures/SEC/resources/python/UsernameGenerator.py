import random
import string


class UsernameGenerator:
    def __init__(self):
        self.non_alphanumeric_characters = "!#$%&()*+,-.;=?@[]_~/"
        self.disallowed_characters = [
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
        self.min_allowed_username_length = 4
        self.max_allowed_username_length = 16

    def _get_random_disallowed_character(self, count):
        """Provide random non-acceptable symbol."""
        return "".join(
            [chr(random.choice(self.disallowed_characters)) for _ in range(count)]
        )

    def _generate_username(
        self, allowed_characters, must_have_characters, min_length=4, max_length=16
    ):
        username_length = random.randint(min_length, max_length)
        allowed_characters_list = list(allowed_characters)
        must_have_characters_list = list(must_have_characters)
        if username_length < len(must_have_characters_list):
            must_have_characters_list = must_have_characters_list[:username_length]
        username = "".join(
            random.sample(must_have_characters_list, len(must_have_characters_list))
        )
        username_length -= len(must_have_characters)
        username += "".join(
            [random.choice(allowed_characters_list) for _ in range(username_length)]
        )
        username = "".join(random.sample(list(username), len(list(username))))
        return username

    def get_valid_username(self):
        allowed_characters = (
            string.ascii_letters + string.digits + self.non_alphanumeric_characters
        )
        must_have_characters = str()
        return self._generate_username(
            allowed_characters=allowed_characters,
            must_have_characters=must_have_characters,
        )

    def get_too_short_username(self):
        allowed_characters = (
            string.ascii_letters + string.digits + self.non_alphanumeric_characters
        )
        must_have_characters = str()
        return self._generate_username(
            allowed_characters=allowed_characters,
            must_have_characters=must_have_characters,
            min_length=1,
            max_length=3,
        )

    def get_too_long_username(self):
        allowed_characters = (
            string.ascii_letters + string.digits + self.non_alphanumeric_characters
        )
        must_have_characters = str()
        return self._generate_username(
            allowed_characters=allowed_characters,
            must_have_characters=must_have_characters,
            min_length=17,
            max_length=25,
        )

    def get_with_disallowed_character_username(self):
        allowed_characters = (
            string.ascii_letters + string.digits + self.non_alphanumeric_characters
        )
        must_have_characters = self._get_random_disallowed_character(count=1)
        return self._generate_username(
            allowed_characters=allowed_characters,
            must_have_characters=must_have_characters
        )
