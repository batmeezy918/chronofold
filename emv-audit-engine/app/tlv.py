from __future__ import annotations

from dataclasses import dataclass
from typing import List


@dataclass(frozen=True)
class TLV:
    tag: str
    length: int
    value: str


def parse_tlv(data: str) -> List[TLV]:
    data = data.replace(" ", "").upper()

    result: List[TLV] = []
    offset = 0

    while offset < len(data):
        if offset + 2 > len(data):
            raise ValueError("Incomplete TLV tag")

        first = data[offset:offset + 2]
        offset += 2

        tag = first

        if (int(first, 16) & 0x1F) == 0x1F:
            while True:
                if offset + 2 > len(data):
                    raise ValueError("Incomplete multi-byte TLV tag")

                part = data[offset:offset + 2]
                offset += 2
                tag += part

                if (int(part, 16) & 0x80) == 0:
                    break

        if offset + 2 > len(data):
            raise ValueError("Incomplete TLV length")

        length_byte = int(data[offset:offset + 2], 16)
        offset += 2

        if length_byte & 0x80:
            number_of_length_bytes = length_byte & 0x7F

            if number_of_length_bytes == 0:
                raise ValueError("Indefinite length not permitted")

            end = offset + number_of_length_bytes * 2

            if end > len(data):
                raise ValueError("Incomplete long-form length")

            length = int(data[offset:end], 16)

            offset = end
        else:
            length = length_byte

        value_size = length * 2

        if offset + value_size > len(data):
            raise ValueError("TLV value exceeds buffer")

        value = data[offset:offset + value_size]

        offset += value_size

        result.append(
            TLV(
                tag=tag,
                length=length,
                value=value,
            )
        )

    return result


def encode_tlv(tag: str, value: str) -> str:
    tag = tag.replace(" ", "").upper()
    value = value.replace(" ", "").upper()

    if len(value) % 2:
        raise ValueError("TLV value must contain complete bytes")

    length = len(value) // 2

    if length < 0x80:
        encoded_length = f"{length:02X}"
    else:
        length_hex = f"{length:X}"

        if len(length_hex) % 2:
            length_hex = "0" + length_hex

        encoded_length = f"{0x80 | (len(length_hex) // 2):02X}{length_hex}"

    return tag + encoded_length + value
