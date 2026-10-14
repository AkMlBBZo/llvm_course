import sys
import re
from collections import Counter
import argparse

LINE_RE = re.compile(r"^\s*(\S+)\s*<-\s*(\S+)\s*$")

def read_ops(path):
    with open(path, "r", encoding="utf-8", errors="replace") as f:
        for line in f:
            m = LINE_RE.match(line)
            if m:
                yield (m.group(1), m.group(2))

def pattern_to_str(window):
    return " ; ".join(f"{u} <- {o}" for u, o in window)

def analyze(path, max_len=5, top_n=30, min_len=1, output=None):
    counters = {L: Counter() for L in range(min_len, max_len + 1)}

    print(f"[+] start (len {min_len}..{max_len})...",
          file=sys.stderr)

    buf = []
    processed = 0
    for user, operand in read_ops(path):
        buf.append((user, operand))
        if len(buf) > max_len:
            buf.pop(0)
        for L in range(min_len, min(len(buf), max_len) + 1):
            counters[L][tuple(buf[-L:])] += 1
        processed += 1
        if processed % 5_000_000 == 0:
            print(f"    ... processed {processed:,} lines", file=sys.stderr)

    print(f"[+] total lines: {processed:,}", file=sys.stderr)

    out = sys.stdout if output is None else open(output, "w", encoding="utf-8")

    for L in range(min_len, max_len + 1):
        counter = counters[L]
        print(f"\n===== {L} "
              f"(uniq: {len(counter):,}) =====", file=out)
        for pat, cnt in counter.most_common(top_n):
            print(f"{cnt:>12,}  {pattern_to_str(pat)}", file=out)

    if output is not None:
        out.close()

def main():
    p = argparse.ArgumentParser()
    p.add_argument("log", help="путь к лог-файлу")
    p.add_argument("--top", type=int, default=30)
    p.add_argument("-o", "--output", default=None)
    args = p.parse_args()

    analyze(args.log, max_len=5, top_n=args.top, min_len=1, output=args.output)

if __name__ == "__main__":
    main()
