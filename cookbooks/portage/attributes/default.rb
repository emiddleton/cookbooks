case platform
when "gentoo"
  # paths & directories
  set[:portage][:make_conf] = "/etc/make.conf"
  set[:portage][:confdir] = "/etc/portage"
  set[:portage][:portdir] = "/usr/portage"
  set[:portage][:distdir] = "#{set[:portage][:portdir]}/distfiles"
  set[:portage][:pkgdir] = "#{set[:portage][:portdir]}/packages/${ARCH}"
  default[:portage][:profile] = "#{set[:portage][:portdir]}/profiles/default/linux/x86/10.0"

  # compiler settings
  default[:portage][:CFLAGS] = "-O2 -pipe -mno-tls-direct-seg-refs"
  default[:portage][:CXXFLAGS] = "${CFLAGS}"

  # build-time flags
  default[:portage][:USE] = []

  # advanced masking
  default[:portage][:ACCEPT_KEYWORDS] = nil

  # mirror settings
  default[:portage][:MIRRORS] = %w(
    http://ftp.iij.ad.jp/pub/linux/gentoo/
  )

  # advanced features
  default[:portage][:OPTS] = []
  default[:portage][:MAKEOPTS] = "-j1"

  # language support
  default[:portage][:LINGUAS] = %w(en)
else
  raise "This cookbook is Gentoo-only"
end
