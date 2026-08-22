const assert = require('assert');
const app = require('./index');

console.log('Running unit tests for CI pipeline...');

// Test 1: Verify app is exported as express function
assert.strictEqual(typeof app, 'function', 'App must be an Express application function');

// Test 2: Verify environment variable fallback
const defaultPort = process.env.PORT || 3000;
assert.strictEqual(typeof defaultPort, 'number' ? defaultPort : parseInt(defaultPort), 'Port should resolve cleanly');

console.log('✓ All unit tests passed successfully!');
process.exit(0);
