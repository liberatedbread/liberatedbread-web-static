---
layout: default
title: Device Specs
description: Machine-readable protocol specifications for liberated IoT devices — BLE, WiFi and hub-attached, served as YAML and JSON.
permalink: /device-specs/
---

{%- comment -%}
  This file lives at the repository ROOT, not inside device-specs/, on purpose.

  device-specs/ is a git subtree of liberatedbread-protocol-specs. Every path
  under that prefix is replaced wholesale by `script/update-subtree`, so a page
  committed inside it would either be clobbered by the next pull or turn every
  pull into a merge conflict. A root-level file with `permalink: /device-specs/`
  serves the same URL and is untouched by subtree operations.

  It also has to exist. Upstream's README used to be rendered here by
  jekyll-readme-index; _config.yml now turns that plugin off (see the comment
  there for why), which would otherwise leave /device-specs/ a 404 while the
  spec files underneath it stayed live.

  The listing below is generated from the files actually present in the
  subtree, never from a hand-maintained list, so a subtree pull that adds,
  renames or removes a spec is reflected here with no edit to this file.
{%- endcomment -%}

Machine-readable protocol specifications for the devices we document — Bluetooth
LE, WiFi and hub-attached. Each spec describes one device's protocol in a single
YAML file: its services and characteristics, the command encodings, and what
each value means.

These are published for anyone building against the hardware, and they are
consumed directly by tooling rather than read as prose. They are **not**
liberation guides — for those, see [the device catalogue]({{ '/devices/' | relative_url }}).

## Schema and index

| File | What it is |
| --- | --- |
| [`schema.json`]({{ '/device-specs/schema.json' | relative_url }}) | JSON Schema every spec below validates against |
| [`index.json`]({{ '/device-specs/index.json' | relative_url }}) | Generated manifest of all specs — the machine entry point |
| [`examples/example-bulb.yaml`]({{ '/device-specs/examples/example-bulb.yaml' | relative_url }}) | Minimal annotated example to write a new spec from |

## Device specifications

{% assign specs = site.static_files
   | where_exp: "f", "f.path contains '/device-specs/devices/'"
   | sort: "name" -%}

{{ specs | size }} device specifications:

<ul>
{%- for spec in specs %}
  <li><a href="{{ spec.path | relative_url }}"><code>{{ spec.basename }}</code></a></li>
{%- endfor %}
</ul>

## Where these come from

The specs are maintained in
[liberatedbread-protocol-specs](https://github.com/liberatedbread/liberatedbread-protocol-specs)
and vendored into this site so they are served from a stable URL under
`liberatedbread.com`. That repository is the place to file corrections or
propose a new device — a change made here would be overwritten by the next
sync.

Alongside the specs, the subtree carries the cleanroom research notes the
protocol work was derived from. Those are served in raw Markdown at
`/device-specs/research-notes/<device>.md`; the rendered, cross-linked versions
live upstream, where their links resolve.

Every spec is produced under the project's cleanroom rules: from observation of
traffic to and from hardware the author owns, and from published documentation —
never from vendor firmware or decompiled application code.
