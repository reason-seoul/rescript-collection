type prop = {
  title: string,
  description: string,
}

@react.component
let make = (~feature: prop) => {
  <div className="col col--4">
    <div className="text--center padding-horiz--md">
      <h3> {React.string(feature.title)} </h3> <p> {React.string(feature.description)} </p>
    </div>
  </div>
}
