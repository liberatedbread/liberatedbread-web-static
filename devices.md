---
layout: base
title: Devices
description: Browse liberated device guides — software and hardware liberation for abandoned IoT devices.
permalink: /devices/
---

{% include header.html %}

<main id="content" class="flex-1 w-full max-w-5xl mx-auto px-4 py-10">

  <h1 class="font-serif text-3xl md:text-4xl mb-4">Liberated Devices</h1>

  <p class="text-bread-khaki/80 max-w-2xl">
    Step-by-step guides for liberating abandoned IoT devices. Every guide has been
    tested on the exact firmware version listed on its page.
  </p>

  <div class="grid grid-cols-1 md:grid-cols-2 gap-4 my-8">
    {% for device in site.data.devices.devices %}
      {% include device-card.html device=device %}
    {% endfor %}
  </div>

  <div class="lb-prose">
    <h2>Want to add a device?</h2>

    <p>
      Read the <a href="{{ '/contribute/' | relative_url }}">contribution guide</a> for
      how to submit a new liberation guide. You need to own the hardware and have
      tested every step yourself.
    </p>

    <h2>Devices we can't officially support</h2>

    <p>
      The devices listed here are ones we've tested and can support. For other
      devices, the community maintains configurable device packs using our YAML
      specification. These packs are created by community members for hardware they
      own and have permission to work with. Liberated Bread links to these packs but
      does not host or endorse them. <strong>Use common sense — these are for
      hardware you own.</strong>
    </p>

    <hr>

    <p class="text-sm text-bread-khaki/60">
      All guides verified on the firmware versions listed. If you find a guide that's
      out of date,
      <a href="https://github.com/liberatedbread/liberatedbread-web-static/issues" target="_blank" rel="noopener">open an issue</a>.
    </p>
  </div>

</main>

{% include footer.html %}
