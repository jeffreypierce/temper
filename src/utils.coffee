utils =
  type: (obj) ->
    if obj == undefined or obj == null
      return false
    classType = {
      '[object Number]': 'number'
      '[object String]': 'string'
      '[object Array]': 'array',
      '[object Object]': 'object'
    }
    classType[toString.call(obj)]

  normalize: (num, precision = 3) ->
    multiplier = Math.pow(10, precision)
    Math.round(num * multiplier) / multiplier

  list:(val, arr)->
    if val and this[val]
      this[val]
    else
      if arr
        for name in this
          name
      else
        for key of this
          key

  centOffset: (freq1, freq2) ->
    Math.round(1200 * Math.log(freq1 / freq2) / Math.log 2)

  ratioFromCents: (cents) ->
    Math.pow(2, (cents / 100 / 12))

  stepRatio: Math.log Math.pow(2, 1 / 12)



