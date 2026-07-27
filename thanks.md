---
layout: base
title: Thanks for Subscribing
description: You're on the Liberated Bread newsletter list. We'll let you know when we launch.
permalink: /thanks/
sitemap: false
---

{% include header.html %}

<main id="content" class="flex-1 flex items-center justify-center px-4 py-16">
  <div class="max-w-xl text-center">
    <h1 class="font-serif text-3xl md:text-4xl mb-4">You're on the list! 🍞</h1>

    <p class="text-lg text-bread-khaki mb-4">
      Thanks for subscribing. We'll let you know when Liberated Bread launches — new
      device guides, project updates, and freshly freed hardware.
    </p>

    <p class="text-bread-khaki/70 mb-8">
      One more step: check your inbox for a confirmation email and click the link
      inside. Nothing is sent to you until you confirm. If it isn't there in a few
      minutes, check your spam folder.
    </p>

    <a href="{{ '/' | relative_url }}"
       class="inline-block px-6 py-3 rounded bg-bread-accent hover:bg-bread-accent-bright text-bread-base font-semibold no-underline transition-colors">
      <span aria-hidden="true">&larr;</span> Back to Liberated Bread
    </a>
  </div>
</main>

{% include footer.html %}
