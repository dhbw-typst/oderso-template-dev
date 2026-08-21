#let default-value = metadata((kind: "oderso-default"))

/// Recusively adds `addition` to `base`. Largely copied from #link("https://github.com/touying-typ/touying/blob/a8abe0d832024038c4174d9bb8182f202bde1209/src/utils.typ#L42-L61")[touying]. Base is modified and returned. -> dictionary
#let merge-config(
  /// The base dictionary. Will be modified -> dictionary
  base,
  /// The dictionary to merge into base -> dictionary
  addition,
) = {
  for key in addition.keys() {
    if (
      key in base
        and type(base.at(key)) == dictionary
        and type(addition.at(key)) == dictionary
    ) {
      base.insert(key, merge-config(base.at(key), addition.at(key)))
    } else {
      base.insert(key, addition.at(key))
    }
  }

  return base
}

/// Recusively adds `additions` to `base`. Largely copied from #link("https://github.com/touying-typ/touying/blob/a8abe0d832024038c4174d9bb8182f202bde1209/src/utils.typ#L42-L61")[touying]. Base is modified and returned. -> dictionary
#let merge-configs(
  /// The base dictionary. -> dictionary
  base,
  /// The dictionaries to merge into base -> dictionary
  ..additions,
) = {
  for addition in additions.pos() {
    base = merge-config(base, addition)
  }
  return base
}

/// Returns a copy of the provided dict but only with entries that do not have the value of `default`. Largely copied from #link("https://github.com/touying-typ/touying/blob/a8abe0d832024038c4174d9bb8182f202bde1209/src/utils.typ#L42-L61")[touying]. -> dictionary
#let get-dict-without-default(dict) = {
  let new-dict = (:)
  for (key, value) in dict.pairs() {
    if value != default-value {
      new-dict.insert(key, value)
    }
  }
  return new-dict
}

#let get-config(path, default, config) = {
  if path == "" or path == none {
    return config
  }

  let first-dot = path.position(".")
  if first-dot == none {
    if path in config.keys() {
      return config.at(path)
    } else {
      return default
    }
  } else {
    let this-key = path.slice(0, first-dot)
    let rest-key = path.slice(first-dot + 1)
    if this-key in config.keys() {
      return get-config(rest-key, default, config.at(this-key))
    }
  }
}

/// Evaluates a linguify string as markup content at call site.
/// Used throughout the template to render localised strings.
/// -> content
#let linguify-content(..args) = {
  context eval(linguify-raw(..args), mode: "markup")
}
