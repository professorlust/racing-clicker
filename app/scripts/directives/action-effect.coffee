'use strict'

angular.module('racingApp').factory 'ActionEffectPool', ($compile, $document, $rootScope, $timeout, $position, game, options) -> class ActionEffectPool
  index = 10000
  constructor: (@params={}) ->
    @lastEffect = 0
    @pool = []
    @_linker = null
    @_template = angular.element '''
            <div class="action-effect" ng-class="actionClass">
              <unit-resource ng-repeat="cost in modified track by cost.unit.name"
                             value="cost.val"
                             unit="::cost.unit"
                             ng-class="{positive: !cost.negative, negative: cost.negative}"></unit-resource>
            </div>
          '''
  linker: -> @_linker ?= $compile(@_template)
  body: $document.find('body')
  get: (data) ->
    if @pool.length
      tip = @pool.pop()
    else
      scope = $rootScope.$new()
      tip = @linker() scope, (tip) =>
        @body.append tip
    angular.extend tip.scope(), @params, data
    tip.show()
    tip
  release: (tip) ->
    tip.hide()
    @pool.push(tip)

  clearPool: ->
    for tip in @pool
      tip.remove()
    @pool = []

  handleEvent: (args) ->
    return if args?.skipEffect
    return if not options.actionEffect()
    return if new Date().getTime() - @lastEffect < 100
    @lastEffect = new Date().getTime()
    modified = for name, cost of args.costs
      unit: game.unit(name)
      val: cost
      negative: true
    if args.unitname
      modified.unshift
        unit: game.unit(args.unitname)
        val: args.twinnum
        negative: false
    @showEffect modified

  showEffect: (modified) ->
    return if not modified.length or not @button
    tip = @get
      modified: modified

    tip.css
      top: 0
      left: 0
      width: 0
      height: 0
      'z-index': index+=1
      display: 'block'
      position: 'absolute'

    position = $position.positionElements @button, tip, 'top', true
    position.top -= 25*modified.length
    position.top += 'px'
    position.left += 'px'
    position.width = 'auto'
    position.height = 'auto'
    tip.css position

    @button = false

    pool = @pool
    $timeout =>
      if @pool isnt pool
        tip.remove()
      else
        @release tip
    , 5000, false

angular.module('racingApp').factory 'actionEffectPool', ($rootScope, ActionEffectPool) ->
  actionEffectPool = new ActionEffectPool()
  $rootScope.$on 'command', (event, args) ->
    console.debug event, args
    actionEffectPool.handleEvent args
  actionEffectPool

###*
 # @ngdoc directive
 # @name racingApp.directive:action-effect
###
angular.module('racingApp').directive 'actionEffect', (actionEffectPool) ->
  priority: -1
  restrict: 'A'
  link: (scope, element, attrs) ->
    element.bind 'click', ->
      actionEffectPool.button = angular.element(element)

