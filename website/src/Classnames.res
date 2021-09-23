let cx = classnames =>
  classnames->Belt.Array.reduce("", (acc, classname) => {
    classname == "" ? acc : `${acc} ${classname}`
  })
