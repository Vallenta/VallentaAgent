# Third-party notices

VallentaAgent is built with the open-source Rust components listed below. Each remains under
the license of its own authors, which governs that component and prevails over the
[VallentaAgent license](LICENSE) for it.

Components offered under more than one license are taken under the MIT license. `lldb-server`,
which the agent supervises, is not part of this software: it is installed from the target
distribution's own packages and is covered by that distribution's terms.

## Components

| Component | Version | License |
|---|---|---|
| `anstream` | 1.0.0 | MIT |
| `anstyle` | 1.0.14 | MIT |
| `anstyle-parse` | 1.0.0 | MIT |
| `anstyle-query` | 1.1.5 | MIT |
| `block-buffer` | 0.10.4 | MIT |
| `cfg-if` | 1.0.4 | MIT |
| `clap` | 4.6.6 | MIT |
| `clap_builder` | 4.6.6 | MIT |
| `clap_derive` | 4.6.4 | MIT |
| `clap_lex` | 1.1.0 | MIT |
| `colorchoice` | 1.0.5 | MIT |
| `cpufeatures` | 0.2.17 | MIT |
| `crypto-common` | 0.1.7 | MIT |
| `digest` | 0.10.7 | MIT |
| `errno` | 0.3.14 | MIT |
| `generic-array` | 0.14.7 | MIT |
| `getrandom` | 0.2.17 | MIT |
| `heck` | 0.5.0 | MIT |
| `hmac` | 0.12.1 | MIT |
| `is_terminal_polyfill` | 1.70.2 | MIT |
| `itoa` | 1.0.18 | MIT |
| `lazy_static` | 1.5.0 | MIT |
| `libc` | 0.2.189 | MIT |
| `log` | 0.4.33 | MIT |
| `matchers` | 0.2.0 | MIT |
| `memchr` | 2.8.3 | MIT |
| `nu-ansi-term` | 0.50.3 | MIT |
| `once_cell` | 1.21.4 | MIT |
| `pin-project-lite` | 0.2.17 | MIT |
| `ppv-lite86` | 0.2.21 | MIT |
| `proc-macro2` | 1.0.107 | MIT |
| `quote` | 1.0.47 | MIT |
| `rand` | 0.8.7 | MIT |
| `rand_chacha` | 0.3.1 | MIT |
| `rand_core` | 0.6.4 | MIT |
| `regex-automata` | 0.4.18 | MIT |
| `regex-syntax` | 0.8.11 | MIT |
| `serde` | 1.0.229 | MIT |
| `serde_core` | 1.0.229 | MIT |
| `serde_derive` | 1.0.229 | MIT |
| `serde_json` | 1.0.151 | MIT |
| `sha2` | 0.10.9 | MIT |
| `sharded-slab` | 0.1.7 | MIT |
| `signal-hook` | 0.3.18 | MIT |
| `signal-hook-registry` | 1.4.8 | MIT |
| `smallvec` | 1.15.2 | MIT |
| `strsim` | 0.11.1 | MIT |
| `subtle` | 2.6.1 | BSD-3-Clause |
| `syn` | 2.0.119 | MIT |
| `syn` | 3.0.3 | MIT |
| `thread_local` | 1.1.10 | MIT |
| `tracing` | 0.1.44 | MIT |
| `tracing-attributes` | 0.1.31 | MIT |
| `tracing-core` | 0.1.36 | MIT |
| `tracing-log` | 0.2.0 | MIT |
| `tracing-subscriber` | 0.3.23 | MIT |
| `typenum` | 1.20.1 | MIT |
| `unicode-ident` | 1.0.24 | MIT and Unicode-3.0 |
| `utf8parse` | 0.2.2 | MIT |
| `zerocopy` | 0.8.56 | MIT |
| `zmij` | 1.0.23 | MIT |

## Copyright notices

MIT-licensed components that state a copyright holder state these:

```
Copyright (c) 2006-2009 Graydon Hoare
Copyright (c) 2010 The Rust Project Developers
Copyright (c) 2014 Alex Crichton
Copyright (c) 2014 Benjamin Sago
Copyright (c) 2014 Chris Wong
Copyright (c) 2014 Paho Lurie-Gregg
Copyright (c) 2014 The Rust Project Developers
Copyright (c) 2015 Andrew Gallant
Copyright (c) 2015 Bartłomiej Kamiński
Copyright (c) 2015 Danny Guo
Copyright (c) 2015 The Rust Project Developers
Copyright (c) 2016 Joe Wilm
Copyright (c) 2016 The Rust Project Developers
Copyright (c) 2017 Artyom Pavlov
Copyright (c) 2017 tokio-jsonrpc developers
Copyright (c) 2018 The Servo Project Developers
Copyright (c) 2018-2019 The RustCrypto Project Developers
Copyright (c) 2018-2024 The rust-random Project Developers
Copyright (c) 2019 Eliza Weisman
Copyright (c) 2019 The CryptoCorrosion Contributors
Copyright (c) 2019 Tokio Contributors
Copyright (c) 2020-2025 The RustCrypto Project Developers
Copyright (c) 2021 RustCrypto Developers
Copyright (c) Individual contributors
Copyright (c) The Rust Project Developers
Copyright 2018 Developers of the Rand project
Copyright 2023 The Fuchsia Authors
```

## MIT License

```
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
```

## BSD 3-Clause License

Applies to `subtle`.

```
Copyright (c) 2016-2017 Isis Agora Lovecruft, Henry de Valence. All rights reserved.
Copyright (c) 2016-2024 Isis Agora Lovecruft. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

1. Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its
contributors may be used to endorse or promote products derived from
this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
```

## Unicode License v3

Applies to the character tables in `unicode-ident`, which are used while building the agent.

```
UNICODE LICENSE V3

COPYRIGHT AND PERMISSION NOTICE

Copyright © 1991-2023 Unicode, Inc.

NOTICE TO USER: Carefully read the following legal agreement. BY
DOWNLOADING, INSTALLING, COPYING OR OTHERWISE USING DATA FILES, AND/OR
SOFTWARE, YOU UNEQUIVOCALLY ACCEPT, AND AGREE TO BE BOUND BY, ALL OF THE
TERMS AND CONDITIONS OF THIS AGREEMENT. IF YOU DO NOT AGREE, DO NOT
DOWNLOAD, INSTALL, COPY, DISTRIBUTE OR USE THE DATA FILES OR SOFTWARE.

Permission is hereby granted, free of charge, to any person obtaining a
copy of data files and any associated documentation (the "Data Files") or
software and any associated documentation (the "Software") to deal in the
Data Files or Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, and/or sell
copies of the Data Files or Software, and to permit persons to whom the
Data Files or Software are furnished to do so, provided that either (a)
this copyright and permission notice appear with all copies of the Data
Files or Software, or (b) this copyright and permission notice appear in
associated Documentation.

THE DATA FILES AND SOFTWARE ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY
KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT OF
THIRD PARTY RIGHTS.

IN NO EVENT SHALL THE COPYRIGHT HOLDER OR HOLDERS INCLUDED IN THIS NOTICE
BE LIABLE FOR ANY CLAIM, OR ANY SPECIAL INDIRECT OR CONSEQUENTIAL DAMAGES,
OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS,
WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION,
ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THE DATA
FILES OR SOFTWARE.

Except as contained in this notice, the name of a copyright holder shall
not be used in advertising or otherwise to promote the sale, use or other
dealings in these Data Files or Software without prior written
authorization of the copyright holder.
```
