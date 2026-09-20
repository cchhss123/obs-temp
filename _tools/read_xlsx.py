#!/usr/bin/env python3
"""
read_xlsx.py — 通用 Excel (.xlsx) 零依賴表格提取與工作表探測工具

特點：
- 僅依賴 Python 3 內建標準庫（zipfile, xml.etree.ElementTree, argparse）。
- 支援 `--list-sheets` 自動探測所有工作表（名稱與索引）。
- 自動解析字串共享池 (sharedStrings.xml) 與工作表 (sheet*.xml)。
- 支援以 GitHub-Flavored Markdown 表格格式輸出，方便 AI 與工程師比對規格。

用法：
    python read_xlsx.py <xlsx_path> [--list-sheets] [--sheet <名稱或編號>] [--output <output_path>] [--max-rows <count>]

範例：
    # 1. 探測工作簿中的所有分頁名稱
    python read_xlsx.py ./_docs/_raw_documents/規格.xlsx --list-sheets

    # 2. 讀取指定分頁並預覽 Markdown 表格
    python read_xlsx.py ./_docs/_raw_documents/規格.xlsx --sheet "WebService清單"

    # 3. 匯出至 Markdown 檔
    python read_xlsx.py ./_docs/_raw_documents/規格.xlsx -s 1 -o ./extracted_table.md
"""

import argparse
import os
import re
import sys
import xml.etree.ElementTree as ET
import zipfile


def list_sheets(xlsx_path: str) -> list[tuple[int, str, str]]:
    """列出 Excel 檔案中所有工作表的 (索引, 名稱, rId)。"""
    with zipfile.ZipFile(xlsx_path, "r") as z:
        if "xl/workbook.xml" not in z.namelist():
            raise ValueError("無效的 xlsx 檔案：未找到 xl/workbook.xml")

        wb_xml = z.read("xl/workbook.xml")
        root = ET.fromstring(wb_xml)
        ns = {
            "main": "http://schemas.openxmlformats.org/spreadsheetml/2006/main",
            "r": "http://schemas.openxmlformats.org/officeDocument/2006/relationships",
        }

        sheets = []
        for i, s in enumerate(root.iter(f"{{{ns['main']}}}sheet"), start=1):
            name = s.get("name")
            rid = s.get(f"{{{ns['r']}}}id")
            sheets.append((i, name, rid))

        return sheets


def extract_shared_strings(z: zipfile.ZipFile) -> list[str]:
    """提取 sharedStrings.xml 建立字串池。"""
    if "xl/sharedStrings.xml" not in z.namelist():
        return []

    strings = []
    sroot = ET.fromstring(z.read("xl/sharedStrings.xml"))
    ns = {"main": "http://schemas.openxmlformats.org/spreadsheetml/2006/main"}

    for si in sroot.iter(f"{{{ns['main']}}}si"):
        text = "".join(
            t.text
            for t in si.iter(f"{{{ns['main']}}}t")
            if t.text
        )
        strings.append(text)

    return strings


def find_sheet_target(z: zipfile.ZipFile, sheet_selector: str) -> str:
    """根據使用者傳入的分頁名稱或 1-based 索引找到對應的 sheet XML 路徑。"""
    sheets = list_sheets(z.filename)

    target_sheet_num = None
    if sheet_selector.isdigit():
        idx = int(sheet_selector)
        if 1 <= idx <= len(sheets):
            target_sheet_num = idx
    else:
        for idx, name, _ in sheets:
            if name.strip().lower() == sheet_selector.strip().lower():
                target_sheet_num = idx
                break

    if target_sheet_num is None:
        sheet_names = ", ".join([f"[{i}] {name}" for i, name, _ in sheets])
        raise ValueError(
            f"找不到工作表 '{sheet_selector}'。現有工作表清單：\n{sheet_names}"
        )

    # 讀取 xl/_rels/workbook.xml.rels 解析 rId 與檔案對應
    rels_path = "xl/_rels/workbook.xml.rels"
    if rels_path in z.namelist():
        rroot = ET.fromstring(z.read(rels_path))
        target_rid = sheets[target_sheet_num - 1][2]
        for rel in rroot:
            if rel.get("Id") == target_rid:
                target_file = rel.get("Target")
                if not target_file.startswith("xl/"):
                    target_file = f"xl/{target_file}"
                return target_file, sheets[target_sheet_num - 1][1]

    # fallback
    fallback_path = f"xl/worksheets/sheet{target_sheet_num}.xml"
    return fallback_path, sheets[target_sheet_num - 1][1]


def column_index_from_string(col_str: str) -> int:
    """將 Excel 欄名 (A, B, AA) 轉為 0-indexed 數字。"""
    exp = 0
    idx = 0
    for char in reversed(col_str.upper()):
        idx += (ord(char) - ord('A') + 1) * (26 ** exp)
        exp += 1
    return idx - 1


def parse_cell_ref(cell_ref: str) -> tuple[int, int]:
    """將 A1 格式解析為 (col_idx, row_idx)。"""
    match = re.match(r"([A-Za-z]+)([0-9]+)", cell_ref)
    if not match:
        return (0, 0)
    col_str, row_str = match.groups()
    return (column_index_from_string(col_str), int(row_str) - 1)


def read_sheet_data(xlsx_path: str, sheet_selector: str, max_rows: int = 100) -> tuple[str, list[list[str]]]:
    """讀取指定工作表，返回 (分頁名稱, 格式化後的二維字串矩陣)。"""
    with zipfile.ZipFile(xlsx_path, "r") as z:
        strings = extract_shared_strings(z)
        sheet_file, sheet_name = find_sheet_target(z, sheet_selector)

        if sheet_file not in z.namelist():
            raise FileNotFoundError(f"找不到工作表檔案: {sheet_file}")

        sheet_root = ET.fromstring(z.read(sheet_file))
        ns = {"main": "http://schemas.openxmlformats.org/spreadsheetml/2006/main"}

        grid = []
        for row in sheet_root.iter(f"{{{ns['main']}}}row"):
            row_dict = {}
            for c in row.iter(f"{{{ns['main']}}}c"):
                ref = c.get("r")
                col_idx = 0
                if ref:
                    col_idx, _ = parse_cell_ref(ref)

                v = c.find(f"{{{ns['main']}}}v")
                t = c.get("t")
                val = ""
                if v is not None and v.text is not None:
                    if t == "s":
                        try:
                            val = strings[int(v.text)]
                        except (IndexError, ValueError):
                            val = v.text
                    else:
                        val = v.text
                elif t == "inlineStr":
                    # 處理 inline string
                    is_node = c.find(f"{{{ns['main']}}}is")
                    if is_node is not None:
                        val = "".join(is_node.itertext())

                val = val.replace("\r\n", " ").replace("\n", " ").strip()
                row_dict[col_idx] = val

            if row_dict and any(row_dict.values()):
                max_c = max(row_dict.keys())
                row_cells = [row_dict.get(c, "") for c in range(max_c + 1)]
                grid.append(row_cells)

            if max_rows > 0 and len(grid) >= max_rows:
                break

        return sheet_name, grid


def to_markdown_table(grid: list[list[str]]) -> str:
    """將二維陣列轉為 GitHub Flavored Markdown 表格。"""
    if not grid:
        return "（無資料）"

    max_cols = max(len(row) for row in grid)
    # 補齊各列長度
    normalized = [row + [""] * (max_cols - len(row)) for row in grid]

    header = normalized[0]
    separator = ["---"] * max_cols
    rows = normalized[1:]

    lines = []
    lines.append("| " + " | ".join(c.replace("|", "\\|") for c in header) + " |")
    lines.append("| " + " | ".join(separator) + " |")
    for r in rows:
        lines.append("| " + " | ".join(c.replace("|", "\\|") for c in r) + " |")

    return "\n".join(lines)


def main():
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    if hasattr(sys.stderr, "reconfigure"):
        sys.stderr.reconfigure(encoding="utf-8", errors="replace")

    parser = argparse.ArgumentParser(
        description="通用 Excel (.xlsx) 零依賴表格提取工具"
    )
    parser.add_argument("xlsx_path", help="要解析的 .xlsx 檔案路徑")
    parser.add_argument(
        "-l",
        "--list-sheets",
        action="store_true",
        help="列出工作簿中的所有分頁名稱與編號",
    )
    parser.add_argument(
        "-s",
        "--sheet",
        default="1",
        help="要讀取的工作表名稱或編號（預設 1 即第一個分頁）",
    )
    parser.add_argument(
        "-o", "--output", help="輸出 Markdown 表格檔案路徑（選填）"
    )
    parser.add_argument(
        "-m",
        "--max-rows",
        type=int,
        default=100,
        help="讀取上限列數（預設 100，設為 0 讀取全部）",
    )

    args = parser.parse_args()

    if not os.path.exists(args.xlsx_path):
        print(f"❌ 錯誤: 找不到檔案 {args.xlsx_path}", file=sys.stderr)
        sys.exit(1)

    try:
        if args.list_sheets:
            sheets = list_sheets(args.xlsx_path)
            print(f"📊 工作簿分頁清單 ({args.xlsx_path}):")
            print("--------------------------------------------------")
            for idx, name, rid in sheets:
                print(f"  [{idx}] {name} (ID: {rid})")
            print("--------------------------------------------------")
            print("提示：可使用 -s <編號或名稱> 提取指定分頁。")
            return

        sheet_name, grid = read_sheet_data(
            args.xlsx_path, args.sheet, max_rows=args.max_rows
        )
        md_table = to_markdown_table(grid)

        print(f"✅ 成功讀取工作表: [{sheet_name}] (共 {len(grid)} 列)")

        if args.output:
            out_dir = os.path.dirname(args.output)
            if out_dir and not os.path.exists(out_dir):
                os.makedirs(out_dir, exist_ok=True)
            with open(args.output, "w", encoding="utf-8") as f:
                f.write(f"# 表格提取：{sheet_name}\n\n{md_table}\n")
            print(f"💾 已成功寫入目標檔案: {args.output}")
        else:
            print("\n" + md_table)

    except Exception as e:
        print(f"❌ 錯誤: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
