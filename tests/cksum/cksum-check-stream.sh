#!/bin/sh
# Validate cksum --check-stream dynamic operation

# Copyright (C) 2024 Free Software Foundation, Inc.

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

. "${srcdir=.}/tests/init.sh"; path_prepend_ ./src
print_ver_ cksum

# Correct checksum
echo foo | cksum -a sha256 --check-stream b5bb9d8014a0f9b1d61e21e796d78dccdf1352f23cd32812f4850b878ae4944c > stdout 2> stderr || fail=1
grep 'foo' stdout || fail=1
echo foo | cksum -a sha256 -S b5bb9d8014a0f9b1d61e21e796d78dccdf1352f23cd32812f4850b878ae4944c > stdout 2> stderr || fail=1
grep 'foo' stdout || fail=1
echo foo | cksum -a sha256 -Sb5bb9d8014a0f9b1d61e21e796d78dccdf1352f23cd32812f4850b878ae4944c > stdout 2> stderr || fail=1
grep 'foo' stdout || fail=1
echo foo >foo
cksum -a sha256 --check-stream b5bb9d8014a0f9b1d61e21e796d78dccdf1352f23cd32812f4850b878ae4944c foo > stdout 2> stderr || fail=1
grep 'foo' stdout || fail=1
echo bar >bar
cksum -a sha256 --check-stream 7d865e959b2466918c9863afca942d0fb89d7c9ac0c99bafc3749504ded97730 bar > stdout 2> stderr || fail=1
grep 'bar' stdout || fail=1

# Correct checksum (sha512)
echo foo | cksum -a sha512 --check-stream 0cf9180a764aba863a67b6d72f0918bc131c6772642cb2dce5a34f0a702f9470ddc2bf125c12198b1995c233c34b4afd346c54a2334c350a948a51b6e8b4e6b6 > stdout 2> stderr || fail=1
grep 'foo' stdout || fail=1

# Correct checksum (base64)
echo foo | cksum -a sha256 --base64 --check-stream "tbudgBSg+bHWHiHnlteNzN8TUvI80ygS9IULh4rklEw=" > stdout 2> stderr || fail=1
grep 'foo' stdout || fail=1

# Wrong checksum (Correct length)
echo foo | cksum -a sha256 --check-stream 0000000000000000000000000000000000000000000000000000000000000000 > stdout 2> stderr && fail=1
grep 'foo' stdout && fail=1
grep 'FAILED: 0000000000000000000000000000000000000000000000000000000000000000 vs b5bb9d8014a0f9b1d61e21e796d78dccdf1352f23cd32812f4850b878ae4944c' stderr || fail=1

# Wrong checksum (Wrong length)
echo foo | cksum -a sha256 --check-stream deadbeef > stdout 2> stderr && fail=1
grep 'foo' stdout && fail=1
grep 'FAILED: deadbeef vs b5bb9d8014a0f9b1d61e21e796d78dccdf1352f23cd32812f4850b878ae4944c' stderr || fail=1

# Wrong checksum (Wrong length; Correct checksum + "0")
echo foo | cksum -a sha256 --check-stream b5bb9d8014a0f9b1d61e21e796d78dccdf1352f23cd32812f4850b878ae4944c0 > stdout 2> stderr && fail=1
grep 'foo' stdout && fail=1
grep 'FAILED: b5bb9d8014a0f9b1d61e21e796d78dccdf1352f23cd32812f4850b878ae4944c0 vs b5bb9d8014a0f9b1d61e21e796d78dccdf1352f23cd32812f4850b878ae4944c' stderr || fail=1

# Wrong checksum (base64)
echo foo | cksum -a sha256 --base64 --check-stream "Zm9vCg==" > stdout 2> stderr && fail=1
grep 'foo' stdout && fail=1
grep 'FAILED: Zm9vCg== vs tbudgBSg+bHWHiHnlteNzN8TUvI80ygS9IULh4rklEw=' stderr || fail=1

# Invalid options
echo foo | cksum -a sha256 --check-stream b5bb9d8014a0f9b1d61e21e796d78dccdf1352f23cd32812f4850b878ae4944c --ignore-missing > stdout 2> stderr && fail=1
grep 'foo' stdout && fail=1
grep -- '--check-stream and --ignore-missing are mutually exclusive' stderr || fail=1
echo foo | cksum -a sha256 --check-stream b5bb9d8014a0f9b1d61e21e796d78dccdf1352f23cd32812f4850b878ae4944c --status > stdout 2> stderr && fail=1
grep 'foo' stdout && fail=1
grep -- '--check-stream and --status are mutually exclusive' stderr || fail=1
echo foo | cksum --check-stream 3915528286 > stdout 2> stderr && fail=1
grep 'foo' stdout && fail=1
grep -- '--check-stream is not supported with the specified algorithm' stderr || fail=1
cksum -a sha256 --check-stream b5bb9d8014a0f9b1d61e21e796d78dccdf1352f23cd32812f4850b878ae4944c foo bar > stdout 2> stderr && fail=1
grep 'foo' stdout && fail=1
grep -- '--check-stream option is not supported with multiple files' stderr || fail=1

Exit $fail
