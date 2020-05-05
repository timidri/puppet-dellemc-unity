# @summary Install prerequisites for the module
##
# @example
#   include dellemc_unity::install
#
class dellemc_unity::install() {
  # note: tested on CentOS 7 only
  $packages = ['rubygems', 'ruby-devel', 'gcc', 'gcc-c++']

  package { $packages:
    ensure => present,
  }

  package { 'rest-client':
    ensure   => 'latest',
    provider => 'puppet_gem',
    require  => Package[$packages],
  }
}
