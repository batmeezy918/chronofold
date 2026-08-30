from __future__ import annotations

from typing import List

from .models import APDUFrame, SyntheticCard


SELECT_VISA = "00A4040007A0000000031010"
SELECT_MC = "00A4040007A0000000041010"
SELECT_AMEX = "00A4040008A000000025010801"


def select_apdu(card: SyntheticCard) -> str:
    if card.scheme == "VISA":
        return SELECT_VISA

    if card.scheme == "MASTERCARD":
        return SELECT_MC

    if card.scheme == "AMERICAN_EXPRESS":
        return SELECT_AMEX

    raise ValueError(f"Unsupported synthetic scheme: {card.scheme}")


def build_trace(card: SyntheticCard) -> List[APDUFrame]:
    select = select_apdu(card)

    aid = {
        "VISA": "A0000000031010",
        "MASTERCARD": "A0000000041010",
        "AMERICAN_EXPRESS": "A000000025010801",
    }[card.scheme]

    fci = "6F00"

    return [
        APDUFrame(
            seq=1,
            direction="C→R",
            command=select,
            response="",
            status_word="",
            meaning="SELECT synthetic payment application",
        ),
        APDUFrame(
            seq=2,
            direction="R→C",
            command="",
            response=fci,
            status_word="9000",
            meaning=f"Return synthetic FCI for AID {aid}",
        ),
        APDUFrame(
            seq=3,
            direction="C→R",
            command="80A80000028300",
            response="",
            status_word="",
            meaning="GET PROCESSING OPTIONS",
        ),
        APDUFrame(
            seq=4,
            direction="R→C",
            command="",
            response="770A82020000940408010100",
            status_word="9000",
            meaning="Return synthetic processing options",
        ),
    ]
