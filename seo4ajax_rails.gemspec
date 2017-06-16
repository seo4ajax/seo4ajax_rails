# coding: utf-8

Gem::Specification.new do |spec|
  spec.name          = "seo4ajax_rails"
  spec.version       = "1.0.0"
  spec.authors       = ["SEO4Ajax"]
  spec.email         = ["support@seo4ajax.com"]
  spec.description   = %q{Rails middleware to integrate SEO4Ajax in your web application}
  spec.summary       = %q{Use SEO4Ajax to serve prerendered pages to bots}
  spec.homepage      = "https://github.com/seo4ajax/seo4ajax_rails"
  spec.license       = "MIT"
  spec.files         = ["lib/seo4ajax_rails.rb"]
  spec.require_paths = ["lib"]

  spec.add_dependency 'rack', '>= 0'
  spec.add_dependency 'activesupport', '>= 0'
end