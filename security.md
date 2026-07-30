---
layout: default
title: Security Policy
description: How to report a security vulnerability in Liberated Bread. Responsible disclosure process, scope, and how to reach us privately.
heading: Security Policy
permalink: /security/
---

We take security seriously — for our infrastructure, for the devices we document, and for the people who follow our guides. If you've found a security issue, we want to hear about it.

## Responsible Disclosure

Please report security vulnerabilities **privately**, not in a public GitHub issue. We follow a coordinated disclosure process:

1. **Email us** at the address below with a description of the issue
2. We'll acknowledge your report within **72 hours** and provide an estimated timeline for a fix
3. We'll keep you updated as we work on the issue
4. Once a fix is ready, we'll coordinate a public disclosure date with you
5. We'll credit you in the disclosure (unless you prefer to remain anonymous)

**Please don't:**
- Publicly disclose the vulnerability before we've had a chance to fix it
- Exploit the vulnerability to access data beyond what's necessary to demonstrate it
- Test against other people's devices or accounts

## Scope

The following are in scope for security reports:

- The Liberated Bread static website (`liberatedbread.com`)
- The `liberatedbread-web-static` repository and its deployment pipeline
- The `liberatedbread-protocol-specs` repository
- The `liberatedbread-3d-files` repository
- Any API endpoints or backend services maintained under the Liberated Bread project

The following are **out of scope:**

- Third-party services linked from our pages (GitHub, Discord, Mastodon, Hachyderm)
- Devices documented on the site — we don't own them, maintain their firmware, or control their cloud services
- Home Assistant or any other third-party software we reference
- Denial-of-service attacks against the static site (it's served by GitHub Pages — talk to GitHub)
- Social engineering attacks

## Contact

**Email for security reports:** security (at) liberatedbread.com

We'll publish a PGP key here once our key infrastructure is set up. In the meantime, encrypted reports can be sent through GitHub's advisory system (below), or via our parent company's key — reach out through Discord for the fingerprint.

If you can't reach us at security@, try:
- **GitHub:** [Privately report a security vulnerability](https://github.com/liberatedbread/liberatedbread-web-static/security/advisories/new) through GitHub's advisory system
- **Discord:** DM a maintainer in the [Pigs Can Fly Labs server](https://www.pigscanfly.ca/discord/) — `#liberated-bread` channel

Machine-readable version: [/.well-known/security.txt](/.well-known/security.txt) ([RFC 9116](https://www.rfc-editor.org/rfc/rfc9116)).

## Bug Bounty

We don't currently run a paid bug bounty program. We're a small project from a small company. That said, we'll happily:
- Credit you publicly in the disclosure and on this page
- Send you some Liberated Bread stickers and swag (once we have them)
- Buy you a coffee (or several) if the finding is significant

## Past Advisories

None yet. When we publish a security advisory, it will be linked here and in the [GitHub Security Advisories](https://github.com/liberatedbread/liberatedbread-web-static/security/advisories) page.

---

*This policy was last updated July 2026. We'll update it as the project grows.*
