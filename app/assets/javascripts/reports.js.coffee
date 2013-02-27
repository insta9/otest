# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
  jQuery(".reports #from_date, .reports #to_date").datepicker dateFormat: 'yy-mm-dd'

  # Show progress indictor when reports are loading
  jQuery("#reports_form").bind("ajax:before",->
    #TODO show progress indicator
    jQuery("#progress_indicator").show();
  ).bind("ajax:complete", ->
    #TODO hide progress indicator
    jQuery("#progress_indicator").hide();
  )
