$(function() {
  // load existing action chain data
  var combobox = $("#action-chain");
  var actionChains = combobox.data("existing-action-chains");

  // init widget
  combobox.select2({
    width: "20em",
    data: actionChains,
    createSearchChoice: ifNotFound,
    maximumInputLength: 256,
    initSelection: function (element, callback) { callback(actionChains[0]); }
  });

  // init initial selection
  combobox.select2("val", actionChains[0].id);

  // select radio button when combobox has focus
  combobox.on("select2-focus", function(event) {
    $("#schedule-by-action-chain").prop("checked", true);
  });

  // returns a new search choice if term is new
  function ifNotFound(term, data) {
    var matchingChoices = $(data).filter(function() {
      return this.text.localeCompare(term) == 0;
    });

    if (matchingChoices.length == 0) {
      var sanitizedTerm = term.replace(/[',]/g, "");
      return {id: sanitizedTerm, text: sanitizedTerm};
    }
  }
});
