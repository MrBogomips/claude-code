"""Tests for wb_summary sheet generator — TDD (RED first)."""
import pytest
from openpyxl import Workbook

from helpers import wb_wbs, wb_risks, wb_resources, wb_summary


# ---------------------------------------------------------------------------
# Helper
# ---------------------------------------------------------------------------

def _build_all(data):
    """Create a Workbook, build WBS/Risks/Resources sheets, return (wb, infos)."""
    wb = Workbook()
    wb.remove(wb.active)  # remove default sheet

    wbs_info = wb_wbs.build(wb, data)
    resources_info = wb_resources.build(wb, data)
    risks_info = wb_risks.build(wb, data)
    return wb, wbs_info, risks_info, resources_info


# ---------------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------------

class TestBuildCreatesSheet:
    def test_build_creates_sheet(self, full_input_data):
        wb, wbs_info, risks_info, resources_info = _build_all(full_input_data)
        wb_summary.build(wb, full_input_data, wbs_info, risks_info, resources_info)
        assert "Summary" in wb.sheetnames


class TestCrossRefsToWbs:
    def test_cross_refs_to_wbs(self, full_input_data):
        """Col A of phase rows should reference WBS!B{phase_row} (phase name)."""
        wb, wbs_info, risks_info, resources_info = _build_all(full_input_data)
        wb_summary.build(wb, full_input_data, wbs_info, risks_info, resources_info)

        ws = wb["Summary"]
        phase_rows = wbs_info["phase_rows"]

        # Summary data rows start at row 2 (row 1 is header)
        for summary_row_offset, wbs_phase_row in enumerate(phase_rows):
            summary_row = 2 + summary_row_offset
            cell_a = ws.cell(row=summary_row, column=1)
            expected = f"=WBS!B{wbs_phase_row}"
            assert cell_a.value == expected, (
                f"Row {summary_row} col A: expected '{expected}', got '{cell_a.value}'"
            )

    def test_pert_effort_cross_ref(self, full_input_data):
        """Col F (PERT Effort) references WBS!H{phase_row}."""
        wb, wbs_info, risks_info, resources_info = _build_all(full_input_data)
        wb_summary.build(wb, full_input_data, wbs_info, risks_info, resources_info)

        ws = wb["Summary"]
        phase_rows = wbs_info["phase_rows"]

        for summary_row_offset, wbs_phase_row in enumerate(phase_rows):
            summary_row = 2 + summary_row_offset
            cell_f = ws.cell(row=summary_row, column=6)
            expected = f"=WBS!H{wbs_phase_row}"
            assert cell_f.value == expected, (
                f"Row {summary_row} col F: expected '{expected}', got '{cell_f.value}'"
            )


class TestDescriptionColumn:
    def test_description_column(self, full_input_data):
        """Col B contains phase descriptions as plain text from input data."""
        wb, wbs_info, risks_info, resources_info = _build_all(full_input_data)
        wb_summary.build(wb, full_input_data, wbs_info, risks_info, resources_info)

        ws = wb["Summary"]
        phases = full_input_data["phases"]

        for offset, phase in enumerate(phases):
            summary_row = 2 + offset
            cell_b = ws.cell(row=summary_row, column=2)
            assert cell_b.value == phase.get("description", ""), (
                f"Row {summary_row} col B: expected '{phase.get('description', '')}', "
                f"got '{cell_b.value}'"
            )


class TestTotalPertEffort:
    def test_total_pert_effort(self, full_input_data):
        """Summary block has total PERT effort formula (SUM of phase PERT efforts)."""
        wb, wbs_info, risks_info, resources_info = _build_all(full_input_data)
        wb_summary.build(wb, full_input_data, wbs_info, risks_info, resources_info)

        ws = wb["Summary"]
        # Find cell labeled "Total PERT Effort" and check that its adjacent formula
        # references either the local total row col F or WBS total row col H.
        found = False
        for row in ws.iter_rows():
            for cell in row:
                if cell.value and "Total PERT Effort" in str(cell.value):
                    formula_cell = ws.cell(row=cell.row, column=cell.column + 1)
                    val = str(formula_cell.value or "")
                    assert val.startswith("="), (
                        f"Expected formula for Total PERT Effort, got: {val!r}"
                    )
                    found = True
                    break
            if found:
                break
        assert found, "Label 'Total PERT Effort' not found in Summary sheet"


class TestTotalBillableEffort:
    def test_total_billable_effort(self, full_input_data):
        """Summary block references WBS billable PERT total column S."""
        wb, wbs_info, risks_info, resources_info = _build_all(full_input_data)
        wb_summary.build(wb, full_input_data, wbs_info, risks_info, resources_info)

        ws = wb["Summary"]
        wbs_total_row = wbs_info["total_row"]
        expected_formula = f"=WBS!S{wbs_total_row}"

        found = False
        for row in ws.iter_rows():
            for cell in row:
                if cell.value == expected_formula:
                    found = True
                    break
            if found:
                break
        assert found, (
            f"Expected formula '{expected_formula}' not found in Summary sheet"
        )


class TestBillableRatio:
    def test_billable_ratio(self, full_input_data):
        """Summary block has a 'Billable Ratio' label with a division formula."""
        wb, wbs_info, risks_info, resources_info = _build_all(full_input_data)
        wb_summary.build(wb, full_input_data, wbs_info, risks_info, resources_info)

        ws = wb["Summary"]
        found = False
        for row in ws.iter_rows():
            for cell in row:
                if cell.value and "Billable Ratio" in str(cell.value):
                    formula_cell = ws.cell(row=cell.row, column=cell.column + 1)
                    val = str(formula_cell.value or "")
                    assert val.startswith("="), (
                        f"Expected formula for Billable Ratio, got: {val!r}"
                    )
                    assert "/" in val, (
                        f"Expected division in Billable Ratio formula, got: {val!r}"
                    )
                    found = True
                    break
            if found:
                break
        assert found, "Label 'Billable Ratio' not found in Summary sheet"


class TestSigmaTotal:
    def test_sigma_total(self, full_input_data):
        """σ Total Duration uses SQRT(SUMPRODUCT(K{s}:K{e},K{s}:K{e})) formula."""
        wb, wbs_info, risks_info, resources_info = _build_all(full_input_data)
        wb_summary.build(wb, full_input_data, wbs_info, risks_info, resources_info)

        ws = wb["Summary"]
        found = False
        for row in ws.iter_rows():
            for cell in row:
                if cell.value and "σ Total" in str(cell.value):
                    formula_cell = ws.cell(row=cell.row, column=cell.column + 1)
                    val = str(formula_cell.value or "")
                    assert "SQRT" in val.upper(), (
                        f"Expected SQRT in sigma formula, got: {val!r}"
                    )
                    assert "SUMPRODUCT" in val.upper(), (
                        f"Expected SUMPRODUCT in sigma formula, got: {val!r}"
                    )
                    found = True
                    break
            if found:
                break
        assert found, "Label 'σ Total' not found in Summary sheet"


class TestCI68:
    def test_ci_68(self, full_input_data):
        """CI 68% has lower and upper bounds: total_pert ∓ σ."""
        wb, wbs_info, risks_info, resources_info = _build_all(full_input_data)
        wb_summary.build(wb, full_input_data, wbs_info, risks_info, resources_info)

        ws = wb["Summary"]
        lower_found = False
        upper_found = False

        for row in ws.iter_rows():
            for cell in row:
                val = str(cell.value or "")
                if "CI 68%" in val and "Lower" in val:
                    formula_cell = ws.cell(row=cell.row, column=cell.column + 1)
                    fval = str(formula_cell.value or "")
                    assert fval.startswith("=") and "-" in fval, (
                        f"CI 68% Lower formula expected subtraction, got: {fval!r}"
                    )
                    lower_found = True
                if "CI 68%" in val and "Upper" in val:
                    formula_cell = ws.cell(row=cell.row, column=cell.column + 1)
                    fval = str(formula_cell.value or "")
                    assert fval.startswith("=") and "+" in fval, (
                        f"CI 68% Upper formula expected addition, got: {fval!r}"
                    )
                    upper_found = True

        assert lower_found, "Label 'CI 68% Lower' not found in Summary sheet"
        assert upper_found, "Label 'CI 68% Upper' not found in Summary sheet"


class TestCI95:
    def test_ci_95(self, full_input_data):
        """CI 95% has lower and upper bounds: total_pert ∓ 2*σ."""
        wb, wbs_info, risks_info, resources_info = _build_all(full_input_data)
        wb_summary.build(wb, full_input_data, wbs_info, risks_info, resources_info)

        ws = wb["Summary"]
        lower_found = False
        upper_found = False

        for row in ws.iter_rows():
            for cell in row:
                val = str(cell.value or "")
                if "CI 95%" in val and "Lower" in val:
                    formula_cell = ws.cell(row=cell.row, column=cell.column + 1)
                    fval = str(formula_cell.value or "")
                    assert fval.startswith("=") and "2" in fval, (
                        f"CI 95% Lower formula expected '2', got: {fval!r}"
                    )
                    lower_found = True
                if "CI 95%" in val and "Upper" in val:
                    formula_cell = ws.cell(row=cell.row, column=cell.column + 1)
                    fval = str(formula_cell.value or "")
                    assert fval.startswith("=") and "2" in fval, (
                        f"CI 95% Upper formula expected '2', got: {fval!r}"
                    )
                    upper_found = True

        assert lower_found, "Label 'CI 95% Lower' not found in Summary sheet"
        assert upper_found, "Label 'CI 95% Upper' not found in Summary sheet"


class TestContingencyCrossRef:
    def test_contingency_cross_ref(self, full_input_data):
        """Summary references =Risks!L{total_contingency_row}."""
        wb, wbs_info, risks_info, resources_info = _build_all(full_input_data)
        wb_summary.build(wb, full_input_data, wbs_info, risks_info, resources_info)

        ws = wb["Summary"]
        expected = f"=Risks!L{risks_info['total_contingency_row']}"
        found = False
        for row in ws.iter_rows():
            for cell in row:
                if cell.value == expected:
                    found = True
                    break
            if found:
                break
        assert found, (
            f"Expected formula '{expected}' not found in Summary sheet"
        )


class TestReserveCrossRef:
    def test_reserve_cross_ref(self, full_input_data):
        """Summary references =Risks!L{reserve_row}."""
        wb, wbs_info, risks_info, resources_info = _build_all(full_input_data)
        wb_summary.build(wb, full_input_data, wbs_info, risks_info, resources_info)

        ws = wb["Summary"]
        expected = f"=Risks!L{risks_info['reserve_row']}"
        found = False
        for row in ws.iter_rows():
            for cell in row:
                if cell.value == expected:
                    found = True
                    break
            if found:
                break
        assert found, (
            f"Expected formula '{expected}' not found in Summary sheet"
        )


class TestAdjustedPert:
    def test_adjusted_pert(self, full_input_data):
        """Adjusted PERT Effort = PERT + Contingency + Reserve."""
        wb, wbs_info, risks_info, resources_info = _build_all(full_input_data)
        wb_summary.build(wb, full_input_data, wbs_info, risks_info, resources_info)

        ws = wb["Summary"]
        found = False
        for row in ws.iter_rows():
            for cell in row:
                if cell.value and "Adjusted PERT" in str(cell.value):
                    formula_cell = ws.cell(row=cell.row, column=cell.column + 1)
                    val = str(formula_cell.value or "")
                    assert val.startswith("="), (
                        f"Expected formula for Adjusted PERT, got: {val!r}"
                    )
                    # Should sum three things (two '+' signs or a SUM)
                    assert val.count("+") >= 2 or "SUM" in val.upper(), (
                        f"Adjusted PERT should add three components, got: {val!r}"
                    )
                    found = True
                    break
            if found:
                break
        assert found, "Label 'Adjusted PERT' not found in Summary sheet"


class TestEffortByTeam:
    def test_effort_by_team(self, full_input_data):
        """Summary has per-team effort rows referencing Resources sheet subtotals."""
        wb, wbs_info, risks_info, resources_info = _build_all(full_input_data)
        wb_summary.build(wb, full_input_data, wbs_info, risks_info, resources_info)

        ws = wb["Summary"]
        total_effort_col = resources_info["total_effort_col"]

        for team, subtotal_row in resources_info["team_subtotal_rows"].items():
            expected_formula = f"=Resources!{total_effort_col}{subtotal_row}"
            found = False
            for row in ws.iter_rows():
                for cell in row:
                    if cell.value == expected_formula:
                        found = True
                        break
                if found:
                    break
            assert found, (
                f"Expected formula '{expected_formula}' for team '{team}' "
                f"not found in Summary sheet"
            )
