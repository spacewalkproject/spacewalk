$(function() {
  var actionChainId = $(".action-chain").data("action-chain-id");

  // handle clik on title label
  $("#label-link").click(function(){
    $("#label-link").hide();
    $("#label-input").show().focus();
    setUnsavedData();
    return false;
  });

  // handle clik on +/- icons
  $(".system-list-show-hide").click(function() {
    var sortOrder = $(this).closest(".group").data("sort-order");
    var listId = "system-list-" + sortOrder;
    var list = $("#" + listId);

    // change icon
    $("#system-list-show-hide-" + sortOrder + " i").toggleClass("fa-plus-square fa-minus-square")

    // if needed, load list via Ajax
    if (list.is(":empty")) {
      ActionChainEntriesRenderer.renderAsync(
        actionChainId,
        sortOrder,
        makeAjaxCallback(listId, false)
      );
    }
    else {
      list.fadeToggle();
    }
    return false;
  });

  // handle click on "delete action chain"
  $("#delete-action-chain").click(function (event, target) {
    clearUnsavedData();
    return false;
  });

  // handle click on "delete action" (that is: delete an action chain
  // entry group)
  $(".delete-group").click(function (event, target) {
    var group = $(this).closest(".group");

    group.fadeOut(400, renumberGroups).addClass("deleted");
    return false;
  });

  // handle click on "delete system" (that is: delete an action chain
  // entry)
  $(".group").on("click", ".delete-entry", function (event, target) {
    li = $(this).closest("li");
    ul = $(this).closest("ul");
    var group = ul.closest(".group");

    if (ul.find("li:visible").size() == 1) {
      group.fadeOut(400, renumberGroups).addClass("deleted");
    }
    else {
      li.fadeOut(400, function() {
        updateSystemCounter(ul, group.data("sort-order"));
      }).addClass("deleted");
    }
    return false;
  });

  // handle click on save changes
  $("#save").click(function(){
    save(function onSuccess(text) {
      $("#error-message").hide();
      $("#success-message").text(text).fadeIn();

      $("#label-link-text").text($("#label-input").val());
      $("#label-link").show();
      $("#label-input").hide();
      clearUnsavedData();
    });
    return false;
  });

  // handle click on cancel
  $("#cancel").click(function() {
    clearUnsavedData();
    location.reload();
  });

  // handle click on save and schedule
  $("#save-and-schedule").click(function() {
    save(function onSuccess(result) {
      clearUnsavedData();
      $("form.schedule").submit();
    });
    return false;
  });

  // handle drag and drop
  $(".action-chain").sortable({
    cursor: "move",
    update: renumberGroups
  });

  // save changes on Action Chain via AJAX
  function save(onSuccess) {
    var newLabel = $("#label-input").val();
    var deletedEntries = $(".entry.deleted").map(function(i, element) {
      return $(element).data("entry-id");
    }).get();
    var deletedSortOrders = $(".group.deleted").map(function(i, element) {
      return $(element).data("sort-order");
    }).get();
    var reorderedSortOrders = $(".group:not(.deleted)").map(function(i, element) {
      return $(element).data("sort-order");
    }).get();

    ActionChainSaveAction.save(
      actionChainId,
      newLabel,
      deletedEntries,
      deletedSortOrders,
      reorderedSortOrders,
      {
        callback: function(resultString) {
          var result = $.parseJSON(resultString);
          if (result.success) {
            $(".entry.deleted").remove();
            $(".group.deleted").remove();
            $(".group").each(function(i, element){
              $(element).data("sort-order", i);
            });
            onSuccess(result.text);
          }
          else {
            $("#success-message").hide();
            $("#error-message").text(result.text).fadeIn();
          }
        },
        errorHandler: function(message) {
          alert("Unexpected error, changes reverted. Please check server logs.");
          clearUnsavedData();
          location.reload();
        }
      }
    );
  }

  function renumberGroups(){
    $(".group:visible").each(function(index, element) {
      $(element).find(".counter").text(index + 1);
    });
    setUnsavedData();
  }

  function updateSystemCounter(ul, sortOrder) {
    var count = ul.find("li:visible").size();
    $("#system-counter-" + sortOrder).text(count);
    if (count == 1) {
      $("#singular-label-" + sortOrder).show();
      $("#plural-label-" + sortOrder).hide();
    }
    setUnsavedData();
  }

  function setUnsavedData() {
    window.onbeforeunload = function(){ return $("#before-unload").text(); };
  }

  function clearUnsavedData() {
    window.onbeforeunload = null;
  }
});
