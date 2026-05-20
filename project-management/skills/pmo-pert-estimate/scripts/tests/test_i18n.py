"""Tests for the i18n module."""
import pytest

from helpers.i18n import LABELS, t


def test_t_returns_label_for_known_key_en() -> None:
    assert t("en", "fascia_bassa") == "Low Band"


def test_t_returns_label_for_known_key_it() -> None:
    assert t("it", "fascia_bassa") == "Fascia BASSA"


def test_t_falls_back_to_en_for_unknown_lang() -> None:
    assert t("xx", "fascia_bassa") == "Low Band"


def test_t_raises_for_unknown_key() -> None:
    with pytest.raises(KeyError):
        t("en", "nonexistent_key")


def test_all_keys_present_in_all_langs() -> None:
    en_keys = set(LABELS["en"].keys())
    it_keys = set(LABELS["it"].keys())
    assert en_keys == it_keys, (
        f"Key mismatch: en-it={en_keys - it_keys}, it-en={it_keys - en_keys}"
    )


def test_t_supports_format_args() -> None:
    s = t("en", "management_reserve_with_pct", pct=10)
    assert "10" in s and "Reserve" in s


def test_t_supports_format_args_it() -> None:
    s = t("it", "management_reserve_with_pct", pct=15)
    assert "15" in s


def test_sheet_titles_present_for_both_langs() -> None:
    for lang in ("en", "it"):
        for key in ("sheet_wbs", "sheet_resource_plan", "sheet_risks", "sheet_summary"):
            assert key in LABELS[lang], f"missing {key} in {lang}"


def test_resource_plan_labels_localized() -> None:
    assert t("it", "sheet_resource_plan") == "Pianificazione Risorse"
    assert t("en", "sheet_resource_plan") == "Resource Plan"


def test_capacity_overcommit_format() -> None:
    s = t("en", "rp_overcommit", wk="W3", pd=42.5, cap=40.0)
    assert "W3" in s and "42.5" in s and "40.0" in s
