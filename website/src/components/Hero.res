open Classnames
open Docusaurus

@module("./Hero.module.css") external styles: {..} = "default"

@react.component
let make = () => {
  let {siteConfig} = useDocusaurusContext()

  <header className={cx(["hero", "hero--primary", styles["heroBanner"]])}>
    <div className="container">
      <h1 className="hero__title">
        <span className="color--primary"> {React.string("ReScript")} </span>
        {React.string(" Collection")}
      </h1>
      <p className="hero__subtitle"> {React.string(siteConfig.tagline)} </p>
      <div className={styles["buttons"]}>
        <Link className="button button--secondary button--lg" to_="/docs/intro">
          {React.string("See Documentation")}
        </Link>
      </div>
    </div>
  </header>
}
