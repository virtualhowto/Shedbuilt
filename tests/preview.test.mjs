import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';

const html = fs.readFileSync(new URL('../web-lab/Shedbuilt-lab-standalone.html', import.meta.url), 'utf8');
const stack = fs.readFileSync(new URL('../infra/stack.preview.yml', import.meta.url), 'utf8');
const dockerfile = fs.readFileSync(new URL('../infra/Dockerfile.preview', import.meta.url), 'utf8');

test('standalone browser engineering lab has parseable JavaScript', () => {
  const scripts = [...html.matchAll(/<script(?:\s[^>]*)?>([\s\S]*?)<\/script>/g)];
  assert.ok(scripts.length >= 1, 'expected embedded standalone JavaScript');
  for (const [, source] of scripts) new vm.Script(source, { filename: 'Shedbuilt-lab-standalone.html' });
});

test('browser lab retains build and simulated-race controls', () => {
  for (const id of ['track', 'methods', 'build', 'release', 'reset', 'speed', 'distance', 'axle-state']) {
    assert.match(html, new RegExp(`id="${id}"`));
  }
});

test('preview deployment requires Authentik middleware and has no game service', () => {
  assert.match(stack, /shedbuilt-preview\.middlewares=\$\{SHEDBUILT_AUTH_MIDDLEWARE:\?/);
  assert.doesNotMatch(stack, /^\s+game:\s*$/m);
  assert.doesNotMatch(stack, /^\s+ports:\s*$/m);
  assert.match(stack, /read_only:\s*true/);
  assert.match(stack, /shedbuilt-preview\.rule=Host/);
});

test('preview image serves standalone laboratory with embedded commit ID', () => {
  assert.match(dockerfile, /COPY web-lab\/Shedbuilt-lab-standalone\.html/);
  assert.match(dockerfile, /version\.json/);
  assert.match(dockerfile, /BUILD_SHA/);
});
