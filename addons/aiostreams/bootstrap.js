// Home Assistant bootstrap for AIOStreams.
// The upstream image is distroless (no shell), so this replaces the usual bashio
// run.sh: read the Supervisor-written options file, map it onto the env vars
// AIOStreams expects, then spawn the upstream server and forward signals.
const fs = require("fs");
const { spawn } = require("child_process");

const OPTIONS_FILE = "/data/options.json";
const SERVER = "/app/packages/server/dist/server.js";

function die(msg) {
  console.error(`[bootstrap] ERROR: ${msg}`);
  process.exit(1);
}

let opts;
try {
  opts = JSON.parse(fs.readFileSync(OPTIONS_FILE, "utf8"));
} catch (err) {
  die(`cannot read ${OPTIONS_FILE}: ${err.message}`);
}

const env = { ...process.env };

// base_url — REQUIRED public URL.
if (!opts.base_url) die("'base_url' is required — set it to the public HTTPS URL of this instance");
env.BASE_URL = opts.base_url;

// secret_key — REQUIRED, exactly 64 hex chars, immutable after first start.
if (!opts.secret_key || !/^[0-9a-fA-F]{64}$/.test(opts.secret_key)) {
  die("'secret_key' must be exactly 64 hex characters — generate one with `openssl rand -hex 32`. It CANNOT be changed after the first start.");
}
env.SECRET_KEY = opts.secret_key;

// Fixed paths / port for the addon.
env.DATABASE_URI = "sqlite:///data/db.sqlite";
env.DISK_CACHE_DIR = "/data/cache";
env.PORT = "3000";

if (opts.log_level) env.LOG_LEVEL = opts.log_level;

if (opts.auth) {
  env.AIOSTREAMS_AUTH = opts.auth;
} else {
  console.warn("[bootstrap] WARNING: 'auth' is empty — this instance will be publicly usable with NO login by anyone who can reach the URL");
}
env.AIOSTREAMS_AUTH_REQUIRED = String(opts.auth_required);

fs.mkdirSync("/data/cache", { recursive: true });

console.log(
  `[bootstrap] starting AIOStreams — base_url=${opts.base_url} port=3000 ` +
    `log_level=${opts.log_level || "default"} auth=${opts.auth ? "set" : "none"} ` +
    `auth_required=${String(opts.auth_required)} secret_key=${env.SECRET_KEY ? "set" : "unset"}`
);

const child = spawn(process.execPath, [SERVER], { stdio: "inherit", env });

for (const sig of ["SIGTERM", "SIGINT"]) {
  process.on(sig, () => child.kill(sig));
}
child.on("error", (err) => die(`failed to spawn server: ${err.message}`));
child.on("exit", (code, signal) => process.exit(code === null ? (signal ? 1 : 0) : code));
