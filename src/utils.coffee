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

  list: (val, arr) ->
    if val and this[val]
      this[val]
    else
      if arr
        for name in this
          name
      else
        for key of this
          key

  normalize: (num, precision = 3) ->
    multiplier = Math.pow 10, precision
    Math.round(num * multiplier) / multiplier

  centOffset: (freq1, freq2) ->
    Math.round 1200 * Math.log(freq1 / freq2) / Math.log 2

  decimalFromCents: (cents) ->
    Math.pow 2, (cents / 100 / 12)

  ratioFromCents: (cents) ->
    utils.ratioFromNumber utils.decimalFromCents(cents)

  ratioFromNumber: (number, delineator) ->
    delin = delineator or ':'
    ratio = '0'
    numerator = undefined
    denominator = undefined

    getFractionArray = (num) ->
      hasWhole = false
      interationLimit = 1000
      accuracy = 0.001
      fractionArray = []
      if num >= 1
        hasWhole = true
        fractionArray.push Math.floor(num)
      if num - Math.floor(num) == 0
        return fractionArray
      if hasWhole
        num = num - Math.floor(num)
      decimal = num - parseInt(num, 10)
      q = decimal
      i = 0
      while Math.abs(q - Math.round(q)) > accuracy
        if i == interationLimit
          return false
        i++
        q = i / decimal
      fractionArray.push Math.round(q * num)
      fractionArray.push Math.round(q)
      fractionArray

    if number or number != Infinity
      fractionArray = getFractionArray(number)
      switch fractionArray.length
        when 1
          numerator = number
          denominator = 1
        when 2
          numerator = fractionArray[0]
          denominator = fractionArray[1]
        when 3
          numerator = fractionArray[0] * fractionArray[2] + fractionArray[1]
          denominator = fractionArray[2]
      ratio = numerator + delin + denominator
    ratio
