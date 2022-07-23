test_sources = [
  'tests.vala',
  'collector.vala'
]

test('cvs', executable ('cvs-test', test_sources, dependencies: valentine_dep), env: ['G_TEST_SRCDIR=' + meson.current_source_dir()])