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
    var group = $(this).closest(".group");
    var list = group.find(".system-list");
    var icon = group.find(".system-list-show-hide i");

    // change icon
    icon.toggleClass("fa-plus-square fa-minus-square");

    var listId = list.attr("id");
    var sortOrder = group.data("sort-order");
    // if needed, load list via Ajax
    if (list.is(":empty")) {
      ActionChainEntriesRenderer.renderAsync(
        actionChainId,
        sortOrder,
        makeRendererHandler(listId, false)
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
        updateSystemCounter(ul, group);
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

  // handle exit without save
  $(window).on("beforeunload", function() {
    if ($.unsaved == true) {
      return $("#before-unload").text();
    }
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
      makeAjaxHandler(function(resultString) {
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
        function(message) {
          clearUnsavedData();
        }
      )
    );
  }

  function renumberGroups(){
    $(".group:visible").each(function(index, element) {
      $(element).find(".counter").text(index + 1);
    });
    setUnsavedData();
  }

  function updateSystemCounter(ul, group) {
    var count = ul.find("li:visible").size();
    group.find(".system-counter").text(count);
    if (count == 1) {
      group.find(".singular-label").show();
      group.find(".plural-label").hide();
    }
    setUnsavedData();
  }

  function setUnsavedData() {
    $.unsaved = true;
    $("#action-chain-save-input").fadeIn();
  }

  function clearUnsavedData() {
    $.unsaved = false;
    $("#action-chain-save-input").fadeOut();
  }
});
