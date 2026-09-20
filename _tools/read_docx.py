#!/usr/bin/env python3
"""
read_docx.py — 通用 Word (.docx) 非結構化文件零依賴提取工具

特點：
- 僅依賴 Python 3 內建標準庫（zipfile, xml.etree.ElementTree, argparse）。
- 跨平台支援 Windows / Linux / macOS，無須安裝 python-docx 或 LibreOffice。
- 專為 AI 助手或工程師從原始規格書提取結構化純文字/Markdown 設計。

用法：
    python read_docx.py <docx_path> [--output <output_path>] [--preview <count>]

範例：
    # 預覽前 30 段內容
    python read_docx.py ./_docs/_raw_documents/規格書.docx

    # 完整提取並儲存至 Markdown / 暫存文字檔
    python read_docx.py ./_docs/_raw_documents/規格書.docx -o ./extracted_spec.md
"""

import argparse
import os
import sys
import xml.etree.ElementTree as ET
import zipfile


def extract_docx_text(docx_path: str) -> list[str]:
    """從 docx 壓縮結構中提取 word/document.xml 的所有段落文字。"""
    if not os.path.exists(docx_path):
        raise FileNotFoundError(f"找不到檔案: {docx_path}")

    try:
        with zipfile.ZipFile(docx_path, "r") as z:
            if "word/document.xml" not in z.namelist():
                raise ValueError("無效的 docx 檔案：未找到 word/document.xml")

            xml_content = z.read("word/document.xml")
            root = ET.fromstring(xml_content)

            ns = {
                "w": "http://schemas.openxmlformats.org/wordprocessingml/2006/main"
            }
            paragraphs = []

            for p in root.iter(f"{{{ns['w']}}}p"):
                # 提取該段落中所有 w:t 節點文字
                p_text = "".join(
                    node.text
                    for node in p.iter(f"{{{ns['w']}}}t")
                    if node.text
                )
                if p_text.strip():
                    paragraphs.append(p_text.strip())

            return paragraphs
    except zipfile.BadZipFile:
        raise ValueError(f"檔案格式損壞或非有效 zip/docx: {docx_path}")


def main():
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    if hasattr(sys.stderr, "reconfigure"):
        sys.stderr.reconfigure(encoding="utf-8", errors="replace")

    parser = argparse.ArgumentParser(
        description="通用 Word (.docx) 零依賴純文字提取工具"
    )
    parser.add_argument("docx_path", help="要解析的 .docx 檔案路徑")
    parser.add_argument(
        "-o", "--output", help="輸出純文字或 Markdown 檔案路徑（選填）"
    )
    parser.add_argument(
        "-p",
        "--preview",
        type=int,
        default=50,
        help="終端機預覽段落數量（預設 50，設為 0 則顯示全部）",
    )

    args = parser.parse_args()

    try:
        paragraphs = extract_docx_text(args.docx_path)
        total_p = len(paragraphs)
        print(f"✅ 成功解析: {args.docx_path}")
        print(f"📊 提取段落總數: {total_p} 段\n")

        content = "\n\n".join(paragraphs)

        if args.output:
            out_dir = os.path.dirname(args.output)
            if out_dir and not os.path.exists(out_dir):
                os.makedirs(out_dir, exist_ok=True)
            with open(args.output, "w", encoding="utf-8") as f:
                f.write(content)
            print(f"💾 已成功寫入目標檔案: {args.output}")
        else:
            limit = total_p if args.preview == 0 else min(args.preview, total_p)
            print(f"--- 內容預覽 (前 {limit} 段) ---")
            for i, p in enumerate(paragraphs[:limit], start=1):
                print(f"[{i}] {p}")
            if total_p > limit:
                print(f"\n... (尚有 {total_p - limit} 段未顯示，可使用 -o 參數輸出完整內容)")

    except Exception as e:
        print(f"❌ 錯誤: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
