# Security Policy

## Reporting a Vulnerability

We take security issues in our Home Assistant add-ons seriously. We appreciate your
efforts to responsibly disclose your findings and will make every effort to
acknowledge your contributions.

**Please do NOT open a public issue or pull request for security vulnerabilities.**

To report a security vulnerability privately, use **GitHub private vulnerability
reporting** (preferred):

- https://github.com/AmineDjeghri/ha-addons/security/advisories/new

When reporting, please include as much of the following as possible:

- A description of the vulnerability and its impact
- The affected add-on(s) and version(s)
- Steps to reproduce the issue
- Any suggested remediation (if known)

You should receive a response within **48 hours**. If you do not, please follow up
on the same channel.

## Supported Versions

Security updates are only provided for the latest released version of each add-on.
Please always use the latest version available in the add-on store.

## Disclosure Policy

- You will receive an acknowledgment of your report within 48 hours.
- We will investigate the issue and determine its impact and severity.
- We will fix the issue in a future release and credit you if you wish to be credited.
- We ask that you do not publicly disclose the vulnerability until we have published
  a fix and given the community time to update.

## Security Best Practices

- Keep your add-ons up to date.
- Do not expose add-on admin interfaces directly to the internet without a reverse
  proxy (e.g. NGINX) and proper authentication.
- Use strong, unique passwords and consider a hardware key or TOTP for your
  Home Assistant account.
