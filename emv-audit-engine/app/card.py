from __future__ import annotations

import hashlib
import re
from typing import Dict, Optional

from .canonical import sha256
from .models import CardProfile, SyntheticCard


PROFILES: Dict[str, CardProfile] = {
    # Default fallback profiles
    "visa-test": CardProfile(
        profile_id="visa-test",
        scheme="VISA",
        network_family="VISA",
        pan_prefix="4",
        pan_length=16,
        issuer_name="JPMORGAN CHASE BANK N.A.",
        issuing_country_name="UNITED STATES",
        region_name="NORTH AMERICA",
        country="US",
        currency="USD",
        card_type="CREDIT",
    ),
    "mastercard-test": CardProfile(
        profile_id="mastercard-test",
        scheme="MASTERCARD",
        network_family="MASTERCARD",
        pan_prefix="5",
        pan_length=16,
        issuer_name="CITIBANK N.A.",
        issuing_country_name="UNITED STATES",
        region_name="NORTH AMERICA",
        country="US",
        currency="USD",
        card_type="CREDIT",
    ),
    "amex-test": CardProfile(
        profile_id="amex-test",
        scheme="AMERICAN_EXPRESS",
        network_family="AMEX",
        pan_prefix="37",
        pan_length=15,
        issuer_name="AMERICAN EXPRESS COMPANY",
        issuing_country_name="UNITED STATES",
        region_name="NORTH AMERICA",
        country="US",
        currency="USD",
        card_type="CREDIT",
    ),

    # Visa Official BIN Profiles
    "visa-us-chase-credit": CardProfile(
        profile_id="visa-us-chase-credit",
        scheme="VISA",
        network_family="VISA",
        pan_prefix="454313",
        pan_length=16,
        issuer_name="JPMORGAN CHASE BANK N.A.",
        issuing_country_name="UNITED STATES",
        region_name="NORTH AMERICA",
        country="US",
        currency="USD",
        card_type="CREDIT",
    ),
    "visa-uk-barclays-debit": CardProfile(
        profile_id="visa-uk-barclays-debit",
        scheme="VISA",
        network_family="VISA",
        pan_prefix="465858",
        pan_length=16,
        issuer_name="BARCLAYS BANK PLC",
        issuing_country_name="UNITED KINGDOM",
        region_name="EUROPE",
        country="GB",
        currency="GBP",
        card_type="DEBIT",
    ),
    "visa-jp-mufg-credit": CardProfile(
        profile_id="visa-jp-mufg-credit",
        scheme="VISA",
        network_family="VISA",
        pan_prefix="454100",
        pan_length=16,
        issuer_name="MUFG CARD CO. LTD.",
        issuing_country_name="JAPAN",
        region_name="ASIA PACIFIC",
        country="JP",
        currency="JPY",
        card_type="CREDIT",
    ),

    # Mastercard Official BIN Profiles (51-55 & 2221-2720)
    "mastercard-us-citi-credit": CardProfile(
        profile_id="mastercard-us-citi-credit",
        scheme="MASTERCARD",
        network_family="MASTERCARD",
        pan_prefix="541234",
        pan_length=16,
        issuer_name="CITIBANK N.A.",
        issuing_country_name="UNITED STATES",
        region_name="NORTH AMERICA",
        country="US",
        currency="USD",
        card_type="CREDIT",
    ),
    "mastercard-fr-bnp-debit": CardProfile(
        profile_id="mastercard-fr-bnp-debit",
        scheme="MASTERCARD",
        network_family="MASTERCARD",
        pan_prefix="513105",
        pan_length=16,
        issuer_name="BNP PARIBAS",
        issuing_country_name="FRANCE",
        region_name="EUROPE",
        country="FR",
        currency="EUR",
        card_type="DEBIT",
    ),
    "mastercard-2series-credit": CardProfile(
        profile_id="mastercard-2series-credit",
        scheme="MASTERCARD",
        network_family="MASTERCARD",
        pan_prefix="222100",
        pan_length=16,
        issuer_name="MASTERCARD 2-SERIES TEST ISSUER",
        issuing_country_name="UNITED STATES",
        region_name="NORTH AMERICA",
        country="US",
        currency="USD",
        card_type="CREDIT",
    ),

    # AmEx Official BIN Profiles (34 & 37)
    "amex-us-consumer": CardProfile(
        profile_id="amex-us-consumer",
        scheme="AMERICAN_EXPRESS",
        network_family="AMEX",
        pan_prefix="378282",
        pan_length=15,
        issuer_name="AMERICAN EXPRESS TRAVEL RELATED SERVICES",
        issuing_country_name="UNITED STATES",
        region_name="NORTH AMERICA",
        country="US",
        currency="USD",
        card_type="CREDIT",
    ),
    "amex-uk-corporate": CardProfile(
        profile_id="amex-uk-corporate",
        scheme="AMERICAN_EXPRESS",
        network_family="AMEX",
        pan_prefix="374242",
        pan_length=15,
        issuer_name="AMERICAN EXPRESS PAYMENT SERVICES LIMITED",
        issuing_country_name="UNITED KINGDOM",
        region_name="EUROPE",
        country="GB",
        currency="GBP",
        card_type="CREDIT",
    ),
}


def luhn_valid(pan: str) -> bool:
    if not pan.isdigit():
        return False

    total = 0
    parity = len(pan) % 2

    for i, char in enumerate(pan):
        digit = int(char)

        if i % 2 == parity:
            digit *= 2
            if digit > 9:
                digit -= 9

        total += digit

    return total % 10 == 0


def luhn_check_digit(body: str) -> str:
    for c in "0123456789":
        if luhn_valid(body + c):
            return c
    raise ValueError("Invalid body for Luhn check digit calculation")


def deterministic_digits(seed: str, count: int) -> str:
    result = ""
    counter = 0

    while len(result) < count:
        digest = hashlib.sha256(
            f"{seed}:{counter}".encode("utf-8")
        ).hexdigest()

        for char in digest:
            if char.isdigit():
                result += char

                if len(result) == count:
                    break

        counter += 1

    return result


def match_profile_by_prefix(partial: str) -> Optional[CardProfile]:
    if not partial or not partial.isdigit():
        return None

    best_match: Optional[CardProfile] = None
    best_len = 0

    for profile in PROFILES.values():
        prefix = profile.pan_prefix
        if partial.startswith(prefix) and len(prefix) > best_len:
            best_match = profile
            best_len = len(prefix)

    return best_match


def normalize_partial_pan(
    profile: CardProfile,
    partial: str | None,
    seed: str,
) -> str:

    partial = partial or profile.pan_prefix

    if not partial.isdigit():
        raise ValueError("Synthetic PAN input must contain digits only")

    if len(partial) > profile.pan_length - 1:
        raise ValueError(
            f"Partial PAN must contain at most "
            f"{profile.pan_length - 1} digits"
        )

    if not partial.startswith(profile.pan_prefix):
        if not partial[0:len(profile.pan_prefix)] == profile.pan_prefix:
            raise ValueError(
                f"PAN does not match synthetic {profile.scheme} profile prefix {profile.pan_prefix}"
            )

    body_length = profile.pan_length - 1

    remaining = body_length - len(partial)

    body = partial + deterministic_digits(
        seed=f"{seed}:{partial}:{profile.profile_id}",
        count=remaining,
    )

    check = luhn_check_digit(body)

    pan = body + check

    if len(pan) != profile.pan_length:
        raise AssertionError("PAN length invariant violated")

    if not luhn_valid(pan):
        raise AssertionError("Luhn invariant violated")

    return pan


def mask_pan(pan: str) -> str:
    if len(pan) <= 10:
        return "*" * len(pan)

    return pan[:6] + "*" * (len(pan) - 10) + pan[-4:]


def build_card(
    profile_id: str | None,
    partial_pan: str | None,
    seed: str,
    cardholder_name: str = "TEST USER",
    expiry_month: int = 12,
    expiry_year: int = 30,
) -> SyntheticCard:

    matched_profile: Optional[CardProfile] = None

    if partial_pan:
        matched_profile = match_profile_by_prefix(partial_pan)

    if profile_id and profile_id in PROFILES:
        if matched_profile and profile_id in ("visa-test", "mastercard-test", "amex-test"):
            profile = matched_profile
        else:
            profile = PROFILES[profile_id]
    elif matched_profile:
        profile = matched_profile
    elif profile_id in PROFILES:
        profile = PROFILES[profile_id]
    else:
        profile = PROFILES["visa-test"]

    pan = normalize_partial_pan(
        profile=profile,
        partial=partial_pan,
        seed=seed,
    )

    card_id = sha256({
        "profile": profile.profile_id,
        "pan": pan,
        "seed": seed,
    })[:32]

    card = SyntheticCard(
        card_id=card_id,
        profile_id=profile.profile_id,
        scheme=profile.scheme,
        pan=pan,
        masked_pan=mask_pan(pan),
        expiry_month=expiry_month,
        expiry_year=expiry_year,
        cardholder_name=cardholder_name,
        service_code=profile.service_code,
        issuer_name=profile.issuer_name,
        issuing_country_name=profile.issuing_country_name,
        region_name=profile.region_name,
        country=profile.country,
        currency=profile.currency,
        card_type=profile.card_type,
        display={
            "scheme": profile.scheme,
            "pan": pan,
            "maskedPan": mask_pan(pan),
            "expiry": f"{expiry_month:02d}/{expiry_year:02d}",
            "cardholder": cardholder_name,
            "serviceCode": profile.service_code,
            "issuerName": profile.issuer_name,
            "issuingCountry": profile.issuing_country_name,
            "region": profile.region_name,
            "cardType": profile.card_type,
            "synthetic": True,
        },
    )

    return card
