fs = require 'fs'

data = fs.readFileSync('40.json', 'utf8')
data = JSON.parse(data)

techRefusals = data['technical_refusals']

personalRefusals = data['interpersonal_refusals']

affinities = data['affinities']

refusals = {}

for person of techRefusals
  refusals[person] = personalRefusals[person].concat techRefusals[person]
getWeight = (source, target) ->
  if affinities[source].indexOf(target) != -1
    return 1
  else if refusals[source].indexOf(target) != -1
    return -10
  else
    return 0

happiness = (group) ->
  h = 0
  for sourcePerson in group
    for targetPerson in group
      unless sourcePerson is targetPerson
        h += getWeight(sourcePerson, targetPerson)
  h
      

getUnhappiestIndex = (groups) ->
  lowestHappiness = Infinity
  leastHappyIndex = 0
  for group, i in groups
    if happiness(group) < lowestHappiness
      leastHappyIndex = i
      lowestHappiness = happiness(group)
  return leastHappyIndex

getUnhappiestIndices = (groups) ->
  leastHappyIndex = getUnhappiestIndex(groups)
  secondLeastIndex = 0
  secondLeastHappiness = Infinity
  for i in [0...groups.length]
    unless i is leastHappyIndex
      h = happiness(groups[i])
      if (h < secondLeastHappiness)
        secondLeastIndex = i
        secondLeastHappiness = h
  return [leastHappyIndex, secondLeastIndex]


genGroups = (people) ->
  groups = []
  currentGroup = []
  i = 1
  for person in people
    currentGroup.push(person)
    if i % 4 is 0
      groups.push(currentGroup)
      currentGroup = []
      i = 0
    i++
  return groups

getMinHappiness = (groups) ->
  happiness(groups[getUnhappiestIndex(groups)])

swapUnhappiest = (groups, minH) ->
  indices = getUnhappiestIndices(groups)
  first = indices[0]
  second = indices[1]
  firstI = Math.floor(Math.random()*groups[first].length)
  secondI = Math.floor(Math.random()*groups[second].length)
  firstTemp = groups[first][firstI]
  secondTemp = groups[second][secondI]
  groups[first][firstI] = groups[second][secondI]
  groups[first][firstI]
  groups[second][secondI] = firstTemp
  if (getMinHappiness(groups) > minH)
    true
  else
    groups[first][firstI] = firstTemp
    groups[second][secondI] = secondTemp
    false

groups = genGroups(key for key of affinities)


console.log(groups)
# console.log(getMinHappiness(groups))
i = 0

swapUnhappiestFor = (gs, n) ->
  minHappiness = getMinHappiness(gs)
  console.log("OLD MIN HAPPINESS : " + minHappiness)
  console.log
  groups = gs
  while n > 0
    # console.log("ONCE")
    if swapUnhappiest(gs, minHappiness)
      minHappiness = getMinHappiness(gs)
      console.log("NEW MIN HAPPINESS : " + minHappiness)
    else
      null
    n--
  return gs
console.log(groups)

module.exports = swapUnhappiestFor
