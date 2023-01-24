type docusaurusSiteConfig = {
  title: string,
  tagline: string,
  url: string,
  baseUrl: string,
  organizationName: string,
  projectName: string,
}

type docusaurusContext = {siteConfig: docusaurusSiteConfig}

@module("@docusaurus/useDocusaurusContext")
external useDocusaurusContext: unit => docusaurusContext = "default"

module Link = {
  type props = {
    @as("to") to_: string,
    children: React.element,
    className?: string,
  }

  @module("@docusaurus/Link")
  external make: React.component<props> = "default"
}
