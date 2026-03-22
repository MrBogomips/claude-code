"""Shared fixtures for pmo-pert-estimate tests."""
import json
import tempfile
from pathlib import Path

import pytest


@pytest.fixture
def sample_config():
    """Minimal valid config for Excel generation."""
    return {
        "lang": "en",
        "effort_unit": "pd",
        "duration_unit": "d",
        "primary_color": "1B4FA5",
        "currency": "EUR",
        "period_type": "biweekly",
        "start_date": "2026-04-06",
        "management_reserve_pct": 0.10,
        "avg_rate": 500,
    }


@pytest.fixture
def sample_roles():
    """Two roles: one billable, one not."""
    return [
        {"code": "SD", "name": "Senior Developer", "team": "Dev", "billable": True},
        {"code": "DEC", "name": "Contract Director", "team": "Client", "billable": False},
    ]


@pytest.fixture
def sample_phases():
    """Two phases with 1 work package each, 2 leaf activities each."""
    return [
        {
            "id": "1",
            "name": "Analysis",
            "description": "Requirements analysis",
            "best_duration": 5,
            "likely_duration": 7,
            "worst_duration": 12,
            "work_packages": [
                {
                    "id": "1.1",
                    "name": "Requirements Gathering",
                    "activities": [
                        {
                            "id": "1.1.1",
                            "name": "Stakeholder interviews",
                            "best_effort": 2,
                            "likely_effort": 3,
                            "worst_effort": 5,
                            "best_duration": 2,
                            "likely_duration": 3,
                            "worst_duration": 5,
                            "resources": ["SD"],
                            "dependencies": [],
                            "risks": ["R1"],
                            "billable": True,
                            "notes": "",
                        },
                        {
                            "id": "1.1.2",
                            "name": "Document review",
                            "best_effort": 1,
                            "likely_effort": 2,
                            "worst_effort": 4,
                            "best_duration": 1,
                            "likely_duration": 2,
                            "worst_duration": 3,
                            "resources": ["SD", "DEC"],
                            "dependencies": ["1.1.1"],
                            "risks": [],
                            "billable": True,
                            "notes": "Client docs",
                        },
                    ],
                }
            ],
        },
        {
            "id": "2",
            "name": "Implementation",
            "description": "Development phase",
            "best_duration": 10,
            "likely_duration": 14,
            "worst_duration": 20,
            "work_packages": [
                {
                    "id": "2.1",
                    "name": "Core Development",
                    "activities": [
                        {
                            "id": "2.1.1",
                            "name": "Backend services",
                            "best_effort": 5,
                            "likely_effort": 8,
                            "worst_effort": 12,
                            "best_duration": 5,
                            "likely_duration": 7,
                            "worst_duration": 10,
                            "resources": ["SD"],
                            "dependencies": ["1.1.2"],
                            "risks": ["R1", "R2"],
                            "billable": True,
                            "notes": "",
                        },
                        {
                            "id": "2.1.2",
                            "name": "PM oversight",
                            "best_effort": 2,
                            "likely_effort": 3,
                            "worst_effort": 5,
                            "best_duration": 10,
                            "likely_duration": 14,
                            "worst_duration": 20,
                            "resources": ["DEC"],
                            "dependencies": [],
                            "risks": [],
                            "billable": False,
                            "notes": "Cross-cutting",
                        },
                    ],
                }
            ],
        },
    ]


@pytest.fixture
def sample_resource_allocation():
    """Resource allocation matching sample_phases and sample_roles."""
    return [
        {"phase_id": "1", "phase_name": "Analysis", "description": "Requirements analysis", "team": "Dev", "role_code": "SD", "effort": 5},
        {"phase_id": "1", "phase_name": "Analysis", "description": "Requirements analysis", "team": "Client", "role_code": "DEC", "effort": 2},
        {"phase_id": "2", "phase_name": "Implementation", "description": "Development phase", "team": "Dev", "role_code": "SD", "effort": 8},
        {"phase_id": "2", "phase_name": "Implementation", "description": "Development phase", "team": "Client", "role_code": "DEC", "effort": 3},
    ]


@pytest.fixture
def sample_risks():
    """Two risks with different severity."""
    return [
        {
            "id": "R1",
            "description": "Key resource unavailable",
            "category": "Organizational",
            "affected_phases": ["1", "2"],
            "probability": 3,
            "impact": 4,
            "strategy": "Mitigate",
            "mitigation": "Cross-train team members",
            "owner": "SD",
            "contingency_effort": 3,
        },
        {
            "id": "R2",
            "description": "Requirements change mid-project",
            "category": "External",
            "affected_phases": ["2"],
            "probability": 4,
            "impact": 3,
            "strategy": "Accept",
            "mitigation": "Budget for change requests",
            "owner": "DEC",
            "contingency_effort": 5,
        },
    ]


@pytest.fixture
def sample_targets():
    """Expected effort/duration targets for reconciliation testing."""
    return {"expected_effort": 25, "expected_duration": 20}


@pytest.fixture
def full_input_data(sample_config, sample_roles, sample_phases, sample_resource_allocation, sample_risks, sample_targets):
    """Complete input data matching the JSON schema."""
    return {
        "config": sample_config,
        "roles": sample_roles,
        "phases": sample_phases,
        "resource_allocation": sample_resource_allocation,
        "risks": sample_risks,
        "targets": sample_targets,
    }


@pytest.fixture
def tmp_xlsx(tmp_path):
    """Returns a path for a temporary .xlsx file."""
    return tmp_path / "test_output.xlsx"


@pytest.fixture
def input_json_path(tmp_path, full_input_data):
    """Writes full_input_data to a temp JSON file and returns the path."""
    p = tmp_path / "excel-input.json"
    p.write_text(json.dumps(full_input_data, indent=2))
    return p
