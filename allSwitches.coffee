fs = require 'fs'

data = fs.readFileSync('real.json', 'utf8')
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


getUnhappiestIndex = (groups) ->
  lowestHappiness = Infinity
  leastHappyIndex = 0
  for group, i in groups
    if getHappiness(group) < lowestHappiness
      leastHappyIndex = i
      lowestHappiness = getHappiness(group)
  return leastHappyIndex

getUnhappiestIndices = (groups) ->
  leastHappyIndex = getUnhappiestIndex(groups)
  secondLeastIndex = 0
  secondLeastHappiness = Infinity
  for i in [0...groups.length]
    unless i is leastHappyIndex
      h = getHappiness(groups[i])
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

randomizeGroups = (groups) ->
  for i in [0...40]
    swapSpecificIndices(groups, i, Math.floor(Math.random()*40))

getMinHappiness = (groups) ->
  getHappiness(groups[getUnhappiestIndex(groups)])

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


swapSpecificIndices = (gs, i, j) ->
  temp = getAtSpecificIndex(gs, i)
  setAtSpecificIndex(gs, i, getAtSpecificIndex(gs, j))
  setAtSpecificIndex(gs, j, temp)
  return gs

getAtSpecificIndex = (gs, i) ->
  currentPos = 0
  for g in gs
    for p in g
      if i == currentPos
        return p
      else
        currentPos++

setAtSpecificIndex = (gs, i, person) ->
  currentPos = 0
  for g, j in gs
    for p, k in g
      if i == currentPos
        gs[j][k] = person
        return
      else
        currentPos++

getHappiness = (group) ->
  h = 0
  # console.log("HAPPINESS GROUP")
  # console.log(group)
  # exit
  for sourcePerson in group
    for targetPerson in group
      unless sourcePerson is targetPerson
        h += getWeight(sourcePerson, targetPerson)
  h

getAverageHappiness = (gs) ->
  return getTotalHappiness(gs) / gs.length

getTotalHappiness = (gs) ->
  sum = 0
  for g in gs
    sum += getHappiness(g)
  sum


swapUntilMaximumHappiness = (gs) ->
  averageHappiness = getTotalHappiness(gs)
  # iterations = 0
  while true
    bestSwap = [0, 0]
    bestHappinessGain = 0
    # console.log("Current total happiness is #{averageHappiness}")
    for j in [0...40]
      for k in [j+1...40]
        swapSpecificIndices(gs, j, k)
        happiness = getTotalHappiness(gs)
        if happiness - averageHappiness > bestHappinessGain
          bestHappinessGain = happiness - averageHappiness
          bestSwap = [j, k]
        swapSpecificIndices(gs, k, j)
    if bestHappinessGain > 0
      # console.log("Best happiness gain is : " + bestHappinessGain)
      swapSpecificIndices(gs, bestSwap[0], bestSwap[1])
      averageHappiness = getTotalHappiness(gs)
      # iterations++
    else
      # console.log("Best happiness gain is : " + bestHappinessGain)
      return

groups = genGroups(key for key of affinities)
console.log(groups)

cloneGroups = (groups) ->
  clonedGroups = []
  for group in groups
    clonedGroups.push([])
    for person in group
      clonedGroups[clonedGroups.length-1].push(person)
  return clonedGroups


bestHappiness = 0
bestGroup = []
for i in [0..100]
  randomizeGroups(groups)
  swapUntilMaximumHappiness(groups)
  getAverageHappiness(groups)
  if getAverageHappiness(groups) > bestHappiness
    console.log "New best happiness!"
    bestHappiness = getAverageHappiness(groups)
    bestGroup = cloneGroups(groups)
    console.log(bestHappiness)
  # console.log(getAverageHappiness(groups))

console.log("Best group was : ")
console.log(bestGroup)
console.log("Best happiness was : " + bestHappiness)
