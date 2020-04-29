# install prerequisites
class dellemc_unity::install() {
  package { 'rest-client':
    ensure   => 'latest',
    provider => 'gem',
  }
}
