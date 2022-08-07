project('libvalentine', 'vala', 'c',
  version: '0.5')

dependencies = [
  dependency('glib-2.0'),
  dependency('gobject-2.0'),
  dependency('gio-2.0'),
  dependency('gee-0.8'),
]

pkgconfig = import('pkgconfig')

PKGCONFIG_DEPS = ['glib-2.0', 'gobject-2.0', 'gio-2.0', 'gee-0.8']
API_VERSION = '0.5'
vapidir = get_option('datadir') / 'vala' / 'vapi'

add_project_arguments(['--enable-experimental'], language: 'vala')

g_ir_compiler = find_program('g-ir-compiler', required: false)

subdir('src')

if get_option('enable_tests')
  subdir('tests')
endif