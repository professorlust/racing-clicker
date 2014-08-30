'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:StatisticsCtrl
 # @description
 # # StatisticsCtrl
 # Controller of the swarmApp
###
angular.module('swarmApp').controller 'StatisticsCtrl', ($scope, session, statistics, game, $interval, options) ->
  $scope.listener = statistics
  $scope.session = session
  $scope.stats = session.statistics
  $scope.game = game

  # TODO: this chunk is copypasted from unitlist.coffee. move it to header, so
  # it's only pasted in one place, and account for options-changes.
  #
  # fps may change in options menu, but we destroy the interval upon loading the options menu, so no worries
  animatePromise = $interval (=>$scope.game.tick()), options.fpsSleepMillis()
  $scope.$on '$destroy', =>
    $interval.cancel animatePromise

  # http://stackoverflow.com/questions/13262621
  utcdoy = (ms) ->
    t = moment.utc(ms)
    "#{parseInt(t.format 'DDD')-1}d #{t.format 'H\\h mm:ss.SSS'}"

  $scope.unitStats = (unit) ->
    ustats = _.clone $scope.stats.byUnit?[unit?.name]
    if ustats?
      ustats.elapsedFirstStr = utcdoy ustats.elapsedFirst
    return ustats
  $scope.hasUnitStats = (unit) -> !!$scope.unitStats unit
  $scope.showStats = (unit) -> $scope.hasUnitStats(unit) or (!unit.isBuyable() and unit.isVisible())

  $scope.upgradeStats = (upgrade) ->
    ustats = $scope.stats.byUpgrade[upgrade.name]
    if ustats?
      ustats.elapsedFirstStr = utcdoy ustats.elapsedFirst
    return ustats
  $scope.hasUpgradeStats = (upgrade) -> !!$scope.upgradeStats upgrade