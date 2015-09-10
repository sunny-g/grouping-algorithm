fs = require 'fs'
# swapper = require './randomIterate.coffee'

data = fs.readFileSync('40.json', 'utf8')
data = JSON.parse(data)

techRefusals = data['technical_refusals']

personalRefusals = data['interpersonal_refusals']

affinities = data['affinities']

getPeopleRefusals = (people) ->
  refs = {}
  for person of techRefusals
    refs[person] = personalRefusals[person].concat techRefusals[person]
  return refs

getPeoplePreferences = (people) ->
  preferences = {}
  for person in people
    likes = []
    dislikes = []
    neutrals = []
    for other in people
      if other is person
        continue
      if affinities[person].indexOf(other) > -1
        likes.push(other)
      else if refusals[person].indexOf(other) > -1
        dislikes.push(other)
      else
        neutrals.push(other)
    orderedPreferences = likes.concat(neutrals).concat(dislikes)
    preferences[person] = orderedPreferences
  return preferences

getPeople = (data) ->
  (key for key of affinities)

people = getPeople(data)

refusals = getPeopleRefusals(people)

getWeight = (source, target) ->
  if affinities[source].indexOf(target) != -1
    return 1
  else if refusals[source].indexOf(target) != -1
    return -10
  else
    return 0

getGroupHappiness = (group) ->
  happiness = 0
  for person in group
    for other in group
      if person == other
        continue
      happiness += getWeight(person, other)
  return happiness

preferences = getPeoplePreferences(people)

clone = (a) ->
  JSON.parse(JSON.stringify(a))

uniqueSymmetry = (xs) ->
  xsCopy = clone(xs)
  for x, y of xsCopy
    if xs.hasOwnProperty(x)
      delete xs[y]

roommates = (people, prefs) ->
  const_prefs = clone(prefs)
  pairings = {}
  stack = clone(people)
  pairUp = () ->
    if stack.length == 0
      return
    person = stack.pop()
    if prefs[person].length == 0
      pairUp()
      return
    else
      other = prefs[person].pop()
      otherCurrentPairing = pairings[other]
      personCurrentPairing = pairings[person]
      otherPrefForCurrent = const_prefs[other].indexOf(otherCurrentPairing)
      otherPrefForPerson =  const_prefs[other].indexOf(person)
      noCurrentPairing = otherCurrentPairing == undefined
      otherPrefersPerson = otherPrefForPerson < otherPrefForCurrent

      if noCurrentPairing or otherPrefersPerson
        if personCurrentPairing != undefined
          delete pairings[personCurrentPairing]
          stack.unshift(personCurrentPairing)
        if otherCurrentPairing != undefined
          delete pairings[otherCurrentPairing]
          stack.unshift(otherCurrentPairing)
        pairings[person] = other
        pairings[other] = person
      else
        stack.push(person)
    pairUp()
  pairUp()
  return pairings

getGroupsOfTwo = (personPairings) ->
  uniqueSymmetry(personPairings)
  groups = []
  for person, pair of personPairings
    group = []
    groups.push([person, pair])
  return groups

personPairings = roommates(people, getPeoplePreferences(people))

groups = getGroupsOfTwo(personPairings)
console.log(getGroupHappiness(group)) for group in groups
exit



# pairingsCopy = clone(personPairings)
# for person, pair of pairingsCopy
  # if personPairings.hasOwnProperty(person)
    # delete personPairings[pair]
uniqueSymmetry(personPairings)


getGroupPreferences = (pairings) ->
  groupPreferences = {}
  for person, pair of pairings
    opinions = []
    for other, otherPair of pairings
      if other == person
        continue
      opinion = 0
      opinion += getWeight(person, other) + getWeight(person, otherPair)
      opinion += getWeight(pair, other)   + getWeight(pair, otherPair)
      otherPairRep = JSON.stringify([other, otherPair])
      opinions.push([otherPairRep, opinion])
    opinions.sort (a, b) ->
      if (a[1] > b[1])
        return -1
      if (a[1] < b[1])
        return 1
      return 0
    stringifiedPair = JSON.stringify([person, pair])
    groupPreferences[stringifiedPair] = (op[0] for op in opinions)
  return groupPreferences

generateGroupings = (groupPairings) ->
  groups = []
  for pair, otherPair of groupPairings
    group = []
    first = JSON.parse(pair)[0]
    second = JSON.parse(pair)[1]
    third = JSON.parse(otherPair)[0]
    fourth = JSON.parse(otherPair)[1]
    group.push(p) for p in [first, second, third, fourth]
    groups.push(group)
  return groups

groupsAndPrefs = getGroupPreferences(personPairings)
allPairings = (key for key of groupsAndPrefs)


getTotalHappiness = (groups) ->
  happiness = 0
  for group in groups
    happiness += getGroupHappiness(group)
  return happiness

pairedRoommates = roommates(allPairings, groupsAndPrefs)
uniqueSymmetry(pairedRoommates)
groups = generateGroupings(pairedRoommates)
totalHappiness = getTotalHappiness(groups)
console.log(totalHappiness)
console.log("")
# swapper(groups, 10000)
console.log(getGroupHappiness(group)) for group in groups

