#!/usr/bin/env python3
"""
probe_health.py — 通用端點健康檢查與延遲探測工具

特點：
- 僅依賴 Python 3 內建標準庫（urllib.request, urllib.error, ssl, time, argparse）。
- 支援探測多個 URL（API、後台 Web、測試環境端點）。
- 輸出回應狀態碼、延遲時間 (ms) 及詳細連線錯誤，方便 AI 於多 Repo 部署前後進行冒煙驗證。

用法：
    python probe_health.py <url1> [<url2> ...] [--timeout <seconds>] [--insecure]

範例：
    # 探測單一或多個服務端點
    python probe_health.py http://10.11.12.176/admin/ http://10.11.12.176/api/health

    # 設定超時時間與忽略自簽憑證檢查
    python probe_health.py https://api.internal.corp/ping -t 3 --insecure
"""

import argparse
import ssl
import sys
import time
import urllib.error
import urllib.request


def probe_url(url: str, timeout: float = 5.0, insecure: bool = False) -> tuple[bool, int, float, str]:
    """探測指定 URL，回傳 (成功與否, HTTP 狀態碼, 耗時毫秒, 錯誤/訊息)。"""
    context = None
    if insecure:
        context = ssl._create_unverified_context()

    req = urllib.request.Request(
        url,
        headers={"User-Agent": "Antigravity-HealthProbe/1.0"}
    )

    start_time = time.time()
    try:
        with urllib.request.urlopen(req, timeout=timeout, context=context) as response:
            elapsed_ms = (time.time() - start_time) * 1000
            return (True, response.getcode(), elapsed_ms, "OK")
    except urllib.error.HTTPError as e:
        elapsed_ms = (time.time() - start_time) * 1000
        # HTTP 狀態碼 (4xx, 5xx) 仍視為收到回應
        return (e.code < 500, e.code, elapsed_ms, f"HTTP Error {e.code}: {e.reason}")
    except urllib.error.URLError as e:
        elapsed_ms = (time.time() - start_time) * 1000
        return (False, 0, elapsed_ms, f"連線失敗: {e.reason}")
    except Exception as e:
        elapsed_ms = (time.time() - start_time) * 1000
        return (False, 0, elapsed_ms, f"異常: {str(e)}")


def main():
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    if hasattr(sys.stderr, "reconfigure"):
        sys.stderr.reconfigure(encoding="utf-8", errors="replace")

    parser = argparse.ArgumentParser(
        description="通用端點健康檢查與延遲探測工具"
    )
    parser.add_argument("urls", nargs="+", help="要探測的 URL 清單")
    parser.add_argument(
        "-t", "--timeout", type=float, default=5.0, help="連線逾時秒數（預設 5.0 秒）"
    )
    parser.add_argument(
        "--insecure", action="store_true", help="忽略 SSL 憑證驗證（測試自簽名憑證時適用）"
    )

    args = parser.parse_args()

    print("==================================================")
    print("📡 服務端點健康檢查探針 (Health Probe)")
    print("==================================================")

    all_passed = True
    for url in args.urls:
        success, code, elapsed_ms, msg = probe_url(
            url, timeout=args.timeout, insecure=args.insecure
        )
        status_icon = "🟢" if success else "🔴"
        code_str = str(code) if code > 0 else "N/A"

        print(f"{status_icon} [{code_str}] ({elapsed_ms:6.1f} ms) {url}")
        if not success:
            print(f"   ↳ ⚠️ {msg}")
            all_passed = False

    print("==================================================")
    if all_passed:
        print("🎉 所有探測端點皆正常回應！")
        sys.exit(0)
    else:
        print("❌ 部分端點回應異常，請檢查服務或網絡連線。")
        sys.exit(1)


if __name__ == "__main__":
    main()
