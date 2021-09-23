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
  let makeProps = (~to_: string, ~className: option<string>=?, ~children: React.element, ()) =>
    {
      "to": to_,
      "className": className,
      "children": children,
    }

  @module("@docusaurus/Link")
  external make: React.component<'a> = "default"
}
