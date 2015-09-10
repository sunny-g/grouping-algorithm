fs = require 'fs'
# swapper = require './randomIterate.coffee'

data = fs.readFileSync('40.json', 'utf8')
data = JSON.parse(data)

LIKE = 1
NEUTRAL = 0
DISLIKE = -1

techRefusals = data['technical_refusals']

personalRefusals = data['interpersonal_refusals']

affinities = data['affinities']

getPeopleRefusals = (people) ->
  refs = {}
  for person of techRefusals
    refs[person] = personalRefusals[person].concat techRefusals[person]
  return refs

groupPreferencesFromRatings = (groups, ratings) ->
  preferences = {}
  ratings = getRatings(groups)
  for group, ratedGroups of ratings
    orderedGroups = []
    groupTuples = []
    for ratedGroup, rating of ratedGroups
      groupTuples.push([ratedGroup, rating])
    groupTuples.sort (a, b) ->
      if (a[1] < b[1])
        return 1
      if (a[1] > b[1])
        return -1
      return 0
    preferences[group] = (a[0] for a in groupTuples)
  return preferences

getRatings = (groups) ->
  ratings = {}
  for group in groups
    ratings[JSON.stringify(group)] = {}
    for person in group
      for otherGroup in groups
        rating = 0
        if otherGroup == group
          continue
        for otherPerson in otherGroup
          rating += getWeight(person, otherPerson)
        ratings[JSON.stringify(group)][JSON.stringify(otherGroup)] = rating
  return ratings

getPeople = (data) ->
  ([key] for key of affinities)

people = getPeople(data)


refusals = getPeopleRefusals(people)

getWeight = (source, target) ->
  if affinities[source].indexOf(target) != -1
    return LIKE
  else if refusals[source].indexOf(target) != -1
    return DISLIKE
  else
    return NEUTRAL

getGroupHappiness = (group) ->
  happiness = 0
  for person in group
    for other in group
      if person == other
        continue
      happiness += getWeight(person, other)

  return happiness

clone = (a) ->
  JSON.parse(JSON.stringify(a))

uniqueSymmetry = (xs) ->
  xsCopy = clone(xs)
  for x, y of xsCopy
    if xs.hasOwnProperty(x)
      delete xs[y]

roommates = (groups) ->
  # const_prefs = clone(prefs)
  pairings = {}
  # console.log(groups)
  # exit
  stack = (JSON.stringify(group) for group in clone(groups))
  ratings = getRatings(groups)
  prefs = groupPreferencesFromRatings(groups)
  pairUp = () ->
    if stack.length == 0
      return
    person = stack.pop()
    # console.log(person)
    if prefs[person].length == 0
      pairUp()
      return
    else
      other = prefs[person].pop()
      otherCurrentPairing = pairings[other]
      personCurrentPairing = pairings[person]
      otherPrefForCurrent = ratings[other][otherCurrentPairing]
      otherPrefForPerson = ratings[other][person]
      noCurrentPairing = otherCurrentPairing == undefined
      otherPrefersPerson = otherPrefForPerson > otherPrefForCurrent

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
  console.log("PAIRINGS")
  console.log(pairings)
  console.log("FINAL")
  console.log(getGroupsFromPairings(pairings))
  return getGroupsFromPairings(pairings)

getGroupsFromPairings = (pairings) ->
  uniqueSymmetry(pairings)
  groups = []
  for group, otherGroup of pairings
    combinedGroup = []
    for person in JSON.parse(group)
      combinedGroup.push(person)
    for otherPerson in JSON.parse(otherGroup)
      combinedGroup.push(otherPerson)
    groups.push(combinedGroup)
  return groups

console.log("BEFORE")
groups = roommates(people)
console.log("GROUPS")
console.log(groups)
# exit


# groups = getGroupsOfTwo(personPairings)

getGroupPreferences = (groups) ->
  groupPreferences = {}
  for group in groups
    opinions = []
    for otherGroup in groups
      if otherGroup == group
        continue
      opinion = 0
      opinion += getWeight(group[0], otherGroup[0])
      opinion += getWeight(group[0], otherGroup[1])
      opinion += getWeight(group[1], otherGroup[1])
      opinion += getWeight(group[1], otherGroup[0])
      otherPairRep = JSON.stringify([otherGroup[0], otherGroup[1]])
      opinions.push([otherPairRep, opinion])
    opinions.sort (a, b) ->
      if (a[1] > b[1])
        return -1
      if (a[1] < b[1])
        return 1
      return 0
    stringifiedPair = JSON.stringify([group[0], group[1]])
    groupPreferences[stringifiedPair] = (op[0] for op in opinions)
  return groupPreferences


groupsAndPrefs = getGroupPreferences(groups)

getTotalHappiness = (groups) ->
  happiness = 0
  for group in groups
    happiness += getGroupHappiness(group)
  return happiness

finalGroups = roommates(groups, groupsAndPrefs)
# totalHappiness = getTotalHappiness(groups)
# console.log(totalHappiness)
# console.log("")
# swapper(groups, 10000)
# console.log(groups)
console.log(getGroupHappiness(group)) for group in finalGroups

pairedPeople = []
for group in finalGroups
  for person in group
    pairedPeople.push(person)

console.log("PEOPLE")
console.log(people)

allPeople = []
for singleGroup in people
  allPeople.push(singleGroup[0])

loners = []
for person in allPeople
  if pairedPeople.indexOf(person) == -1
    loners.push(person)

console.log(loners)
console.log(getGroupHappiness([ 'Kelly Garner', 'Paul Hall', 'Angelo Bassetti', 'Grace Gin' ]))
