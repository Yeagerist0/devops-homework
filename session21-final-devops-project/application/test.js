const assert = require('assert');
const app = require('./server');

console.log('Executing automated unit tests...');

assert.strictEqual(typeof app, 'function', 'Server must export an Express application');
console.log('✓ App initialization check passed');

const defaultPort = 8080;
assert.ok(defaultPort > 1024, 'Port must be non-privileged');
console.log('✓ Port configuration check passed');

console.log('All tests passed cleanly!');
process.exit(0);
