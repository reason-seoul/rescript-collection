open Theme

@module("./index.module.css") external styles: {..} = "default"

let features: array<FeatureBlock.prop> = [
  {
    title: "Immutable Collection",
    description: "There is no mutation at all. Any function returns a new instance of it not modifying the original instance",
  },
  {
    title: "Fast and Efficient",
    description: "Based on the most recent efficient algorithms carefully choosen, it provides production-grade performance.",
  },
  {
    title: "100% Type-safe",
    description: "Thanks to ReScript type system, to make library is 100% sound. That means that if the input has correct type it will always work without bugs.",
  },
]

@react.component
let make = () => {
  <Layout title="Home" description="Homepage of ReScript Collection">
    <Hero />
    <main>
      <section className={styles["features"]}>
        <div className="container">
          <div className="row">
            {features
            ->Belt.Array.map(feature => {
              <FeatureBlock feature />
            })
            ->React.array}
          </div>
        </div>
      </section>
    </main>
  </Layout>
}

let default = make
