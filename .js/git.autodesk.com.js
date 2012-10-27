/**
 * 1) Use http://defunkt.io/dotjs/
 * 2) Install this into ~/.js/github.com.js
 * 3) Enjoy a button to edit any file on a pull request (some restrictions may apply, void where prohibited)
 *
 * Note: this will replace the "View file @ ...", which I find pretty useless (and it's contained in the edit mode,
 * anyway). However, if you want to look at files where you don't have access to edit them, this will suck.
 */

function getBranch() {
  return $($('.pull-description .commit-ref')[1]).text().trim()
}

function updateButtons() {
  var branch = getBranch()
  if (!branch) return // couldn't get a branch? NOT A PULL REQUEST
  $('.actions .minibutton').each(function(i, el) {
    el = $(el)
    el.attr('href', el.attr('href').replace(/blob\/[a-z0-9]+/, 'edit/' + branch))
    el.html('Edit file @ <code>' + branch + '</code>')
  })
}

$(function() {
  updateButtons()
})
