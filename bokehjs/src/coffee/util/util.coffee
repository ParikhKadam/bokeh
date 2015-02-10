define [
  "underscore"
  "sprintf"
  "numeral"
], (_, sprintf, Numeral) ->

  _format_number = (number) ->
    # will get strings for categorical types, just pass back
    if _.isString(number)
      return number
    if Math.floor(number) == number
      return sprintf("%d", number)
    if Math.abs(number) > 0.1 and Math.abs(number) < 1000
      return sprintf("%0.3f", number)
    return sprintf("%0.3e", number)

  replace_placeholders = (string, data_source, i, x, y, vx, vy, sx, sy) ->
    string = string.replace /(^|[^\$])\$(\w+)/g, (match, prefix, name) =>
      replacement = switch name
        when "index" then "#{i}"
        when "x"     then "#{_format_number(x)}"
        when "y"     then "#{_format_number(y)}"
        when "vx"    then "#{vx}"
        when "vy"    then "#{vy}"
        when "sx"    then "#{sx}"
        when "sy"    then "#{sy}"
      if replacement? then "#{prefix}#{replacement}" else match

    string = string.replace /(^|[^@])@(?:(\w+)|{([^{}]+)})(?:{([^{}]+)})?/g, (match, prefix, name, long_name, format) =>
      name = if long_name? then long_name else name
      column = data_source.get_column(name)
      replacement =
        if not column?
          "#{name} unknown"
        else
          string = column[i]
          if format?
            Numeral.format(string, format)
          else if _.isNumber(string)
            _format_number(string)
          else
            string
      "#{prefix}#{replacement}"

    return string

  return {replace_placeholders: replace_placeholders}
