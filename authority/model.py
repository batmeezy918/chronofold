"""
Authority Model & Authority Graph
==================================
Manages explicit protocol authority metadata, provenance tracking,
precedence hierarchies, conflict detection, and "I don't know" responses.
"""

from dataclasses import dataclass, asdict, field
from enum import Enum
from typing import Dict, List, Optional, Any
from agd.canonical import sha256_hash, canonical_json_dumps

class AuthorityType(str, Enum):
    EMVCO = "EMVCO"
    NETWORK = "NETWORK"
    ISSUER = "ISSUER"
    REGIONAL = "REGIONAL"
    REGULATORY = "REGULATORY"
    LAB = "LAB"
    SECONDARY_REFERENCE = "SECONDARY_REFERENCE"
    EXPERIMENTAL = "EXPERIMENTAL"

AUTHORITY_PRECEDENCE = {
    AuthorityType.EMVCO: 100,
    AuthorityType.NETWORK: 90,
    AuthorityType.REGULATORY: 80,
    AuthorityType.ISSUER: 70,
    AuthorityType.REGIONAL: 60,
    AuthorityType.LAB: 50,
    AuthorityType.SECONDARY_REFERENCE: 30,
    AuthorityType.EXPERIMENTAL: 10,
}

@dataclass
class Authority:
    authority_id: str
    authority_type: AuthorityType
    organization: str
    document_id: str
    version: str
    publication_date: str
    effective_date: str
    supersedes: Optional[str] = None
    scope: str = "GLOBAL"
    jurisdiction: str = "GLOBAL"
    network: str = "ALL"
    product: str = "ALL"
    source_uri: str = "local://authority"
    local_artifact: str = "manifest.json"
    sha256: str = ""
    provenance_status: str = "AUTHORITATIVE"
    licensing_status: str = "PERMITTED_EXCERPT"

    def to_dict(self) -> Dict[str, Any]:
        data = asdict(self)
        data["authority_type"] = self.authority_type.value
        return data

    def compute_hash(self) -> str:
        return sha256_hash(self.to_dict())

@dataclass
class AuthorityConflict:
    conflict_id: str
    source_A: Dict[str, Any]
    source_B: Dict[str, Any]
    versions: Dict[str, str]
    effective_dates: Dict[str, str]
    conflicting_fields: List[str]
    applicable_scope: str
    unresolved_status: str = "AUTHORITY_CONFLICT"

class AuthorityGraph:
    def __init__(self):
        self.nodes: Dict[str, Authority] = {}
        self.rules: Dict[str, Dict[str, Any]] = {}
        self.conflicts: List[AuthorityConflict] = []

    def register_authority(self, authority: Authority) -> str:
        if not authority.sha256:
            authority.sha256 = authority.compute_hash()
        self.nodes[authority.authority_id] = authority
        return authority.authority_id

    def add_rule(self, rule_id: str, topic: str, content: Dict[str, Any], authority_id: str):
        if authority_id not in self.nodes:
            raise ValueError(f"Authority {authority_id} not registered in graph.")

        auth = self.nodes[authority_id]

        if rule_id in self.rules:
            existing_rule = self.rules[rule_id]
            existing_auth = self.nodes[existing_rule["authority_id"]]

            # Check for conflicting content
            if existing_rule["content"] != content:
                # Resolve by precedence or emit conflict
                prec_existing = AUTHORITY_PRECEDENCE.get(existing_auth.authority_type, 0)
                prec_new = AUTHORITY_PRECEDENCE.get(auth.authority_type, 0)

                if prec_new == prec_existing:
                    conflict = AuthorityConflict(
                        conflict_id=f"CONFLICT_{rule_id}",
                        source_A=existing_auth.to_dict(),
                        source_B=auth.to_dict(),
                        versions={"source_A": existing_auth.version, "source_B": auth.version},
                        effective_dates={"source_A": existing_auth.effective_date, "source_B": auth.effective_date},
                        conflicting_fields=[k for k in content if content.get(k) != existing_rule["content"].get(k)],
                        applicable_scope=topic,
                        unresolved_status="AUTHORITY_CONFLICT"
                    )
                    self.conflicts.append(conflict)
                    return
                elif prec_new < prec_existing:
                    # Ignore lower precedence override
                    return
                # If prec_new > prec_existing, override higher precedence rule below

        rule_hash = sha256_hash({
            "rule_id": rule_id,
            "topic": topic,
            "content": content,
            "authority_id": authority_id
        })

        self.rules[rule_id] = {
            "rule_id": rule_id,
            "topic": topic,
            "content": content,
            "authority_id": authority_id,
            "authority_type": auth.authority_type.value,
            "version": auth.version,
            "effective_date": auth.effective_date,
            "rule_hash": rule_hash
        }

    def query_rule(self, rule_id: str) -> Dict[str, Any]:
        if rule_id in self.rules:
            return {
                "status": "FOUND",
                "rule": self.rules[rule_id]
            }
        return {
            "status": "UNRESOLVED",
            "message": "I don't know.",
            "reason": f"No authority in authority graph provides rule '{rule_id}'."
        }

    def get_manifest_hash(self) -> str:
        all_data = {
            "authorities": [a.to_dict() for a in sorted(self.nodes.values(), key=lambda x: x.authority_id)],
            "rules": sorted(self.rules.values(), key=lambda x: x["rule_id"]),
            "conflicts": [asdict(c) for c in self.conflicts]
        }
        return sha256_hash(all_data)
