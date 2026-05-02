# Octo-Fiesta Home Assistant Addon

HA Addon for [Octo-Fiesta](https://github.com/V1ck3s/octo-fiesta)

## Installation
1. Add this addon repository to Home Assistant (https://github.com/aminedjeghri/ha-addons)
2. Install the "Octo-Fiesta" addon
3. Configure your settings (see below)
4. Start the addon

## Configuration

### Basic Setup

The addon comes with default settings pointing to a local Navidrome server on port 4533. You can override environment variables:

**Required:**
- `Subsonic__Url`: URL to your Navidrome server (default: `http://localhost:4533`)

### Advanced Configuration

For advanced configuration options, edit the addon environment variables:

1. Go to Addon Settings
2. Under "Environment Variables", add or modify the environment variables as needed

See [Octo-Fiesta Documentation](https://github.com/V1ck3s/octo-fiesta/wiki) for detailed configuration options.

## Usage

### Connecting Your Client

Point your Subsonic-compatible client to:
```
http://YOUR_HA_IP:8080
```

Use the same credentials as your Navidrome server.

