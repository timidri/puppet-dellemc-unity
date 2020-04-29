# @summary Install prerequisites for the module
##
# @example
#   include dellemc_unity::install
#
class dellemc_unity::install() {
  package { 'rubygems':
    ensure => present,
  }
  package { 'rest-client':
    ensure   => 'latest',
    provider => 'gem',
    require  => Package['rubygems'],
  }
}
