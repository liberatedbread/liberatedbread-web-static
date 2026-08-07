---
layout: default
title: Shop
description: Dead smart devices going cheap, and the boards and tools that bring them back — curated buying links from Liberated Bread.
heading: Buy dead devices. Seriously.
permalink: /shop/
---

The whole premise of this site is that a "bricked" smart device is usually a
perfectly good computer whose owner gave up on it. That makes the second-hand
market a candy store: gear whose cloud died sells for a fraction of retail,
and the fix is a guide you can read for free. This page collects search links
for the dead devices worth grabbing, plus the boards and tools our guides
reach for.

**Affiliate disclosure:** links on this page may be affiliate links, meaning
Pigs Can Fly Labs LLC earns a small commission if you buy through them — at no
extra cost to you. It helps keep the guides free. We only list the kind of
gear the guides actually use, prices are whatever the store says they are, and
a plain web search will find you the same things.

{% for section in site.data.shop.sections %}
## {{ section.title }}

{{ section.blurb }}

{% for item in section.items -%}
- **{{ item.name }}** — {{ item.why | strip }}
  {%- for link in item.links %} [{{ link.label }}]({% if link.affiliate_url and link.affiliate_url != "" %}{{ link.affiliate_url }}{% else %}{{ link.url }}{% endif %}){% unless forloop.last %} ·{% endunless %}
  {%- endfor %}
  {%- if item.guide %} · [Liberation guide]({{ item.guide | relative_url }}){% endif %}
{% endfor %}
{% endfor %}

## The usual caveats

Second-hand electronics are as-is by nature: expect missing screws, mystery
firmware versions, and the occasional genuinely dead unit in an "untested"
lot. Check listings against the exact model a
[device guide]({{ '/devices/' | relative_url }}) covers before paying a
premium for one. Mains-powered devices deserve respect — every guide that
opens an enclosure starts with a de-energize step, and the
[disclaimer]({{ '/disclaimer/' | relative_url }}) applies here too: this is
for hardware you own, at your own risk.

Got a favourite source for cloud-orphaned hardware, or a board we should
list? [Tell us about it]({{ '/contribute/' | relative_url }}).
